{
  pkgs,
  lib,
  ...
}: let
  # Community plugins, pinned. Referenced from config.kdl via file:/home/maike/.config/zellij/plugins/<name>.
  plugins = {
    # Status bar (replaces compact-bar via layouts/zjstatus.kdl)
    "zjstatus.wasm" = pkgs.fetchurl {
      url = "https://github.com/dj95/zjstatus/releases/download/v0.23.0/zjstatus.wasm";
      hash = "sha256-4AaQEiNSQjnbYYAh5MxdF/gtxL+uVDKJW6QfA/E4Yf8=";
    };
    # Fuzzy tab switcher (Alt r)
    "room.wasm" = pkgs.fetchurl {
      url = "https://github.com/rvcas/room/releases/download/v1.2.1/room.wasm";
      hash = "sha256-kLSDpAt2JGj7dYYhYFh6BfvtzVwTrcs+0jHwG/nActE=";
    };
    # Keybinding cheatsheet (Alt g) - maybe remove
    "zellij_forgot.wasm" = pkgs.fetchurl {
      url = "https://github.com/karimould/zellij-forgot/releases/download/0.4.2/zellij_forgot.wasm";
      hash = "sha256-MRlBRVGdvcEoaFtFb5cDdDePoZ/J2nQvvkoyG6zkSds=";
    };
    # Switch sessions from inside zellij without nesting (used by noren/zjp)
    "zellij-switch.wasm" = pkgs.fetchurl {
      url = "https://github.com/mostafaqanbaryan/zellij-switch/releases/download/0.2.1/zellij-switch.wasm";
      hash = "sha256-7yV+Qf/rczN+0d6tMJlC0UZj0S2PWBcPDNq1BFsKIq4=";
    };
  };

  # Auto-start wrapper used by nushell/fish/zsh: names the session after the
  # current directory and attaches (live), resurrects (dead) or creates it.
  # Consults noren so [[session]]/[[wildcard]] rules in ~/.config/noren/
  # config.toml provide per-project names, layouts and startup commands;
  # falls back to the old basename logic if noren is unavailable. A local
  # .zellij.kdl still wins over a configured layout.
  zellij-autostart = pkgs.writeShellScriptBin "zellij-autostart" ''
    [ -n "$ZELLIJ" ] && exit 0
    LAYOUT=""
    STARTUP=""
    if command -v noren >/dev/null 2>&1 && resolved=$(noren resolve "$PWD" 2>/dev/null); then
      eval "$resolved"
      name=$(noren name-for "$PWD" 2>/dev/null)
    fi
    if [ -z "''${name:-}" ]; then
      if [ "$PWD" = "$HOME" ]; then
        name="home"
      else
        name=$(basename "$PWD" | tr -c 'a-zA-Z0-9._\n-' '-' | sed 's/^-*//')
      fi
    fi
    [ -n "$name" ] || name="session"
    # Publish the resolved session name for anything that needs to know the
    # current session but doesn't have ZELLIJ_SESSION_NAME in its env (notably
    # the zjstatus command_pin widget, whose subprocess env is opaque).
    mkdir -p "$HOME/.local/state/zellij"
    printf %s "$name" > "$HOME/.local/state/zellij/current-session" 2>/dev/null || true
    if zellij list-sessions -s 2>/dev/null | grep -qxF -- "$name"; then
      exec zellij attach "$name"
    fi
    # Fresh session: fire the configured startup command once it exists
    # (best effort, detached — the exec below replaces this shell).
    if [ -n "$STARTUP" ]; then
      (sleep 1; zellij --session "$name" run -c -- sh -c "$STARTUP" >/dev/null 2>&1) &
    fi
    if [ -f "$PWD/.zellij.kdl" ]; then
      exec zellij --session "$name" --new-session-with-layout "$PWD/.zellij.kdl"
    elif [ -n "$LAYOUT" ] && [ -f "$HOME/.config/zellij/layouts/$LAYOUT.kdl" ]; then
      exec zellij --session "$name" --new-session-with-layout "$HOME/.config/zellij/layouts/$LAYOUT.kdl"
    else
      exec zellij --session "$name"
    fi
  '';

  # Structural preview of a session's saved layout (or any layout .kdl).
  # Parses just enough KDL to render a compact tab -> pane-split tree with
  # each leaf pane's name / running command / focus marker. Used by zjp and
  # zjp2 fzf previews so the picker shows workspace shape at a glance
  # instead of raw KDL config text. Python stdlib only.
  zellij-layout-preview = pkgs.writers.writePython3Bin "zellij-layout-preview" {
    flakeIgnore = ["E501" "W503" "E203" "E265"];
  } (builtins.readFile ../../../ressources/scripts/zellij-layout-preview/main.py);

  # Fuzzy session picker with a preview of each session's saved layout
  # (tabs, cwds, running commands). Outside zellij it attaches/resurrects;
  # inside it switches the current client in place (no nesting) via the
  # zellij-switch plugin. Bound to Alt s inside zellij.
  zjp = pkgs.writeShellScriptBin "zjp" ''
    sel=$(zellij list-sessions -n 2>/dev/null | fzf \
      --preview "${zellij-layout-preview}/bin/zellij-layout-preview {1} 2>/dev/null || echo '(no saved layout)'" \
      --preview-window=right,60%)
    [ -n "$sel" ] || exit 0
    name=$(printf '%s' "$sel" | awk '{print $1}')
    [ -n "$name" ] || exit 0
    if [ -n "$ZELLIJ" ]; then
      exec zellij pipe --plugin "file:$HOME/.config/zellij/plugins/zellij-switch.wasm" -- "--session $name"
    else
      exec zellij attach --create "$name"
    fi
  '';

  # Interactive session rename, launched as a floating pane from the session
  # keybind mode (Ctrl g -> o -> r). Renaming pins the session (see reaper).
  zellij-rename-session = pkgs.writeShellScriptBin "zellij-rename-session" ''
    [ -n "$ZELLIJ" ] || { echo "not inside a zellij session"; exit 1; }
    printf 'Rename session "%s" to: ' "$ZELLIJ_SESSION_NAME"
    read -r new
    if [ -n "$new" ]; then
      zellij action rename-session "$new"
      zunpin "$ZELLIJ_SESSION_NAME" >/dev/null 2>&1
      zpin "$new" >/dev/null 2>&1
      export ZELLIJ_SESSION_NAME="$new"
      # Keep the pin-indicator fallback file in sync.
      mkdir -p "$HOME/.local/state/zellij"
      printf %s "$new" > "$HOME/.local/state/zellij/current-session" 2>/dev/null || true
    fi
    zellij action close-pane
  '';

  # Pinned sessions survive window close as live background sessions; the
  # reaper kills unpinned ones once no client is attached (grace period),
  # leaving a resurrectable corpse. Manual naming (sn / rename keybind) pins.
  zpin = pkgs.writeShellScriptBin "zpin" ''
    pin_file="$HOME/.local/state/zellij/pinned"
    mkdir -p "$(dirname "$pin_file")"
    name="''${1:-$ZELLIJ_SESSION_NAME}"
    [ -n "$name" ] || { echo "usage: zpin [session-name] (or run inside zellij)"; exit 1; }
    grep -qxF -- "$name" "$pin_file" 2>/dev/null || echo "$name" >> "$pin_file"
    echo "pinned: $name"
  '';

  zunpin = pkgs.writeShellScriptBin "zunpin" ''
    pin_file="$HOME/.local/state/zellij/pinned"
    name="''${1:-$ZELLIJ_SESSION_NAME}"
    [ -n "$name" ] || { echo "usage: zunpin [session-name] (or run inside zellij)"; exit 1; }
    [ -f "$pin_file" ] || exit 0
    grep -vxF -- "$name" "$pin_file" > "$pin_file.tmp" 2>/dev/null || true
    mv "$pin_file.tmp" "$pin_file"
    echo "unpinned: $name"
  '';

  # sn <new-name>: rename the current session AND pin it (manually named
  # sessions are meant to persist - the user's "lock" semantics).
  sn = pkgs.writeShellScriptBin "sn" ''
    [ -n "$1" ] || { echo "usage: sn <new-name>"; exit 1; }
    [ -n "$ZELLIJ" ] || { echo "not inside a zellij session"; exit 1; }
    old="$ZELLIJ_SESSION_NAME"
    zellij action rename-session "$1" || exit 1
    zunpin "$old" >/dev/null 2>&1
    zpin "$1"
    # Keep the pin-indicator fallback file in sync.
    mkdir -p "$HOME/.local/state/zellij"
    printf %s "$1" > "$HOME/.local/state/zellij/current-session" 2>/dev/null || true
  '';

  # cd hook helper: when entering a directory that has a session (live or
  # saved), offer to switch/restore. Exit 3 = user declined (shells remember
  # the decline per directory for the shell's lifetime).
  zellij-cd-attach = pkgs.writeShellScriptBin "zellij-cd-attach" ''
    [ -n "$ZELLIJ" ] || exit 0
    [ "$PWD" = "$HOME" ] && exit 0
    name=$(basename "$PWD" | tr -c 'a-zA-Z0-9._\n-' '-' | sed 's/^-*//')
    [ -n "$name" ] || exit 0
    [ "$name" = "$ZELLIJ_SESSION_NAME" ] && exit 0
    line=$(zellij list-sessions -n 2>/dev/null | awk -v n="$name" '$1 == n {print; exit}')
    [ -n "$line" ] || exit 0
    case "$line" in
      *EXITED*) verb="Restore saved" ;;
      *) verb="Attach to running" ;;
    esac
    printf '%s zellij session "%s" for this directory? [y/N] ' "$verb" "$name" > /dev/tty
    read -r ans < /dev/tty || exit 3
    case "$ans" in
      y | Y | yes | Yes) ;;
      *) exit 3 ;;
    esac
    if [ "$verb" = "Restore saved" ]; then
      # bring the dead session back detached, then move this client over
      zellij attach --create-background "$name" >/dev/null 2>&1
      sleep 0.3
    fi
    exec zellij pipe --plugin "file:$HOME/.config/zellij/plugins/zellij-switch.wasm" -- "--session $name"
  '';

  # Reaper (systemd user timer): implements the detach/quit middleground.
  # - unpinned live sessions with no attached client for >30min get killed
  #   (they stay resurrectable via their serialized layout)
  # - exited sessions are deleted after 14 days
  # - orphaned serialization cache dirs are pruned after 14 days
  zellij-reaper = pkgs.writeShellScriptBin "zellij-reaper" ''
    export PATH=${lib.makeBinPath [pkgs.zellij pkgs.coreutils pkgs.gnugrep pkgs.gawk pkgs.findutils]}:$PATH
    grace_minutes=30
    retention_days=14
    pin_file="$HOME/.local/state/zellij/pinned"
    state_dir="$HOME/.local/state/zellij/reaper"
    info="$HOME/.cache/zellij/contract_version_1/session_info"
    mkdir -p "$state_dir"
    now=$(date +%s)

    # 1) kill unpinned, clientless live sessions after the grace period
    zellij list-sessions -n 2>/dev/null | grep -v "EXITED" | while read -r line; do
      name="''${line%% *}"
      [ -n "$name" ] || continue
      if grep -qxF -- "$name" "$pin_file" 2>/dev/null; then
        rm -f "$state_dir/$name"
        continue
      fi
      clients=$(ZELLIJ_SESSION_NAME="$name" zellij action list-clients 2>/dev/null | tail -n +2 | grep -c .)
      if [ "$clients" -gt 0 ]; then
        rm -f "$state_dir/$name"
        continue
      fi
      if [ -f "$state_dir/$name" ]; then
        first=$(cat "$state_dir/$name")
        if [ $(((now - first) / 60)) -ge "$grace_minutes" ]; then
          zellij kill-session "$name" >/dev/null 2>&1
          rm -f "$state_dir/$name"
        fi
      else
        echo "$now" > "$state_dir/$name"
      fi
    done

    # 2) delete exited sessions whose last serialization is older than retention
    zellij list-sessions -n 2>/dev/null | grep "EXITED" | while read -r line; do
      name="''${line%% *}"
      [ -d "$info/$name" ] || continue
      if find "$info/$name" -maxdepth 0 -mtime +"$retention_days" | grep -q .; then
        zellij delete-session "$name" >/dev/null 2>&1
      fi
    done

    # 3) prune cache dirs zellij no longer lists (version-migration orphans)
    listed=$(zellij list-sessions -s 2>/dev/null)
    for d in "$info"/*/; do
      [ -d "$d" ] || continue
      name=$(basename "$d")
      printf '%s\n' "$listed" | grep -qxF -- "$name" && continue
      if find "$d" -maxdepth 0 -mtime +"$retention_days" | grep -q .; then
        rm -rf -- "$d"
      fi
    done
  '';

  # Cycle through the IDE layout family by opening the next/previous layout
  # in a new tab. Bound to Alt Shift ] / Alt Shift [.
  #
  # Zellij's `swap_tiled_layout` can only rearrange EXISTING panes; it cannot
  # spawn or close command panes (yazi/lazygit/claude), so proper cycling
  # between IDE variants requires opening each as a fresh tab. State (current
  # index in the cycle) is persisted between invocations at
  # ~/.local/state/zellij/ide-cycle-index.
  zellij-ide-cycle = pkgs.writeShellScriptBin "zellij-ide-cycle" ''
    set -eu
    direction="''${1:-next}"
    state_file="$HOME/.local/state/zellij/ide-cycle-index"
    mkdir -p "$(dirname "$state_file")"

    # Cycle order — keep in sync with the layouts under
    # ressources/dots/zellij/layouts/ide*.kdl.
    layouts="ide ide-filetree ide-console ide-git ide-llm"
    set -- $layouts
    count=$#

    idx=0
    if [ -f "$state_file" ]; then
      idx=$(cat "$state_file" 2>/dev/null || echo 0)
    fi
    # Reset to 0 for empty or non-numeric values (fresh install / corruption).
    [ -z "$idx" ] && idx=0
    case "$idx" in *[!0-9]*) idx=0 ;; esac

    case "$direction" in
      prev|previous|back|-) idx=$((idx - 1)) ;;
      *)                     idx=$((idx + 1)) ;;
    esac
    # Wrap.
    idx=$(( (idx % count + count) % count ))
    echo "$idx" > "$state_file"

    # Pick the layout at that index (positional shift).
    i=0
    for l in $layouts; do
      if [ "$i" = "$idx" ]; then
        exec zellij action new-tab --layout "$l" --name "$l"
      fi
      i=$((i + 1))
    done
  '';

  # Pin-status indicator used by the zjstatus command_pin widget. Prints 📌 if
  # the current session name is in ~/.local/state/zellij/pinned, ○ otherwise.
  #
  # Robustness chain — the zjstatus widget spawns this via zellij's run_command
  # plugin API, and it's unclear whether the plugin subprocess inherits
  # ZELLIJ_SESSION_NAME from the server. Fallbacks:
  #   1. $ZELLIJ_SESSION_NAME (works if zellij exports env to plugin subprocs).
  #   2. Read ~/.local/state/zellij/current-session (a client-side file that
  #      zellij-autostart / the shell hook writes on session attach).
  #   3. If both fail → emit a dim ○ (no session context, no pin possible).
  zellij-pin-indicator = pkgs.writeShellScriptBin "zellij-pin-indicator" ''
    set -eu
    pin_file="$HOME/.local/state/zellij/pinned"
    name="''${ZELLIJ_SESSION_NAME:-}"
    if [ -z "$name" ] && [ -r "$HOME/.local/state/zellij/current-session" ]; then
      name=$(cat "$HOME/.local/state/zellij/current-session" 2>/dev/null || true)
    fi
    if [ -z "$name" ]; then
      printf %s "○"
      exit 0
    fi
    if [ -r "$pin_file" ] && grep -qxF -- "$name" "$pin_file"; then
      printf %s "📌"
    else
      printf %s "○"
    fi
  '';

  # Fuzzy layout picker: pick from ~/.config/zellij/layouts/*.kdl, open in a
  # new tab. Bound to Alt Shift L, also reachable via Ctrl g o l.
  zjl = pkgs.writeShellScriptBin "zjl" ''
    dir="$HOME/.config/zellij/layouts"
    sel=$(ls "$dir" 2>/dev/null | sed -n 's/\.kdl$//p' | fzf \
      --prompt "layout > " \
      --preview "cat \"$dir/{}.kdl\"" \
      --preview-window=right,60%)
    [ -n "$sel" ] || exit 0
    exec zellij action new-tab --layout "$sel"
  '';

  # Reveal a file into the editor pane of an IDE-yazi (or similar) layout.
  # Called from yazi's keymap (`o` -> shell 'zellij-reveal-file "$0"' --confirm).
  # Behavior:
  #   1) focus the "next" pane (assumed to be the editor pane; the tree pane
  #      is deterministically first in all `ide-*` layouts).
  #   2) inspect that pane's RUNNING_COMMAND via `zellij action list-clients`
  #      (per-pane, not system-wide pgrep — the old version misfired when
  #      helix ran anywhere else on the machine).
  #   3) send the appropriate open command:
  #        hx / helix -> ESC :o <path> <CR>
  #        nvim / vim -> ESC :e <path> <CR>
  #        shell      -> "$EDITOR <path>" (fallback for empty editor panes)
  # zellij 0.44 lacks a `focus-pane-by-name` action, hence the focus-next
  # heuristic. Works for every layout in ressources/dots/zellij/layouts/*.
  zellij-reveal-file = pkgs.writeShellScriptBin "zellij-reveal-file" ''
    set -eu
    file="''${1:-}"
    [ -n "$file" ] || { echo "usage: zellij-reveal-file <path>" >&2; exit 1; }
    [ -n "''${ZELLIJ:-}" ] || { echo "not inside a zellij session" >&2; exit 1; }

    # Absolute path — editors resolve relative paths in their own cwd, which
    # differs from yazi's cwd.
    case "$file" in
      /*) abs="$file" ;;
      *)  abs="$PWD/$file" ;;
    esac

    # Move focus off the calling (yazi) pane. `focus-next-pane` cycles
    # visible tiled panes in a deterministic order — from the tree pane in
    # top-left, "next" always lands on the editor.
    zellij action focus-next-pane >/dev/null 2>&1 || true

    # Give zellij a moment to settle the focus change before we introspect.
    sleep 0.15

    # Detect the RUNNING_COMMAND of the now-focused pane via list-clients.
    # Output shape (0.44.3):
    #   CLIENT_ID   ZELLIJ_PANE_ID   RUNNING_COMMAND
    #   1           terminal_2       hx
    # We take the executable name from the first data row (single-client is
    # the norm here). Multi-arg commands (e.g. `sh -c "..."`) collapse to
    # their first token, which is what we want for editor detection.
    cmd=$(zellij action list-clients 2>/dev/null \
      | awk 'NR==2 { print $3; exit }' \
      | tr -d '[:space:]' || true)

    detect_editor() {
      case "$1" in
        hx|helix) echo hx ;;
        nvim)     echo nvim ;;
        vim)      echo vim ;;
        *)        echo shell ;;
      esac
    }
    ed=$(detect_editor "$cmd")

    # Send keys. `zellij action write 27` = ESC, `write 13` = Enter.
    case "$ed" in
      hx)
        zellij action write 27 >/dev/null 2>&1 || true
        zellij action write-chars ":open $abs"
        zellij action write 13
        ;;
      nvim|vim)
        zellij action write 27 >/dev/null 2>&1 || true
        zellij action write-chars ":edit $abs"
        zellij action write 13
        ;;
      shell|*)
        # Empty pane / plain shell prompt: type the launch command.
        editor="''${EDITOR:-hx}"
        zellij action write-chars "$editor $abs"
        zellij action write 13
        ;;
    esac
  '';
in {
  programs.zellij.enable = true;
  # Shell auto-start intentionally does NOT use the home-manager integrations
  # (they run a bare `zellij`, which creates a randomly-named session every
  # time). nushell.nix / fish.nix / zsh.nix call zellij-autostart instead.

  home.packages = [zellij-autostart zellij-layout-preview zjp zjl zellij-ide-cycle zellij-pin-indicator zellij-reveal-file zellij-rename-session zpin zunpin sn zellij-cd-attach zellij-reaper];

  systemd.user.services.zellij-reaper = {
    Unit.Description = "Reap unpinned detached zellij sessions and stale saved sessions";
    Service = {
      Type = "oneshot";
      ExecStart = "${zellij-reaper}/bin/zellij-reaper";
    };
  };
  systemd.user.timers.zellij-reaper = {
    Unit.Description = "Run zellij-reaper every 15 minutes";
    Timer = {
      OnBootSec = "5m";
      OnUnitActiveSec = "15m";
    };
    Install.WantedBy = ["timers.target"];
  };

  home.file =
    {
      ".config/zellij/config.kdl".source = ../../../ressources/dots/zellij/config.kdl;
      ".config/zellij/themes/ansi.kdl".source = ../../../ressources/dots/zellij/themes/ansi.kdl;
      ".config/zellij/layouts/zjstatus.kdl".source = ../../../ressources/dots/zellij/layouts/zjstatus.kdl;
      ".config/zellij/layouts/ide.kdl".source = ../../../ressources/dots/zellij/layouts/ide.kdl;
      ".config/zellij/layouts/ide-git.kdl".source = ../../../ressources/dots/zellij/layouts/ide-git.kdl;
      ".config/zellij/layouts/ide-llm.kdl".source = ../../../ressources/dots/zellij/layouts/ide-llm.kdl;
      ".config/zellij/layouts/ide-filetree.kdl".source = ../../../ressources/dots/zellij/layouts/ide-filetree.kdl;
      ".config/zellij/layouts/ide-console.kdl".source = ../../../ressources/dots/zellij/layouts/ide-console.kdl;
    }
    // lib.mapAttrs' (name: src: {
      name = ".config/zellij/plugins/${name}";
      value = {source = src;};
    })
    plugins;
}
