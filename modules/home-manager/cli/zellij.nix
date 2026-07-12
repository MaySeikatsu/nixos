{
  pkgs,
  lib,
  ...
}: let
  # Community plugins, pinned. Referenced from config.kdl via
  # file:/home/maike/.config/zellij/plugins/<name>.
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
    # Keybinding cheatsheet (Alt g)
    "zellij_forgot.wasm" = pkgs.fetchurl {
      url = "https://github.com/karimould/zellij-forgot/releases/download/0.4.2/zellij_forgot.wasm";
      hash = "sha256-MRlBRVGdvcEoaFtFb5cDdDePoZ/J2nQvvkoyG6zkSds=";
    };
    # Switch sessions from inside zellij without nesting (used by zjp)
    "zellij-switch.wasm" = pkgs.fetchurl {
      url = "https://github.com/mostafaqanbaryan/zellij-switch/releases/download/0.2.1/zellij-switch.wasm";
      hash = "sha256-7yV+Qf/rczN+0d6tMJlC0UZj0S2PWBcPDNq1BFsKIq4=";
    };
  };

  # Auto-start wrapper used by nushell/fish/zsh: names the session after the
  # current directory and attaches (live), resurrects (dead) or creates it.
  # A .zellij.kdl file in the directory is used as layout for new sessions.
  zellij-autostart = pkgs.writeShellScriptBin "zellij-autostart" ''
    [ -n "$ZELLIJ" ] && exit 0
    if [ "$PWD" = "$HOME" ]; then
      name="home"
    else
      name=$(basename "$PWD" | tr -c 'a-zA-Z0-9._\n-' '-' | sed 's/^-*//')
    fi
    [ -n "$name" ] || name="session"
    if zellij list-sessions -s 2>/dev/null | grep -qxF -- "$name"; then
      exec zellij attach "$name"
    elif [ -f "$PWD/.zellij.kdl" ]; then
      exec zellij --session "$name" --new-session-with-layout "$PWD/.zellij.kdl"
    else
      exec zellij --session "$name"
    fi
  '';

  # Fuzzy session picker with a preview of each session's saved layout
  # (tabs, cwds, running commands). Outside zellij it attaches/resurrects;
  # inside it switches the current client in place (no nesting) via the
  # zellij-switch plugin. Bound to Alt s inside zellij.
  zjp = pkgs.writeShellScriptBin "zjp" ''
    info="$HOME/.cache/zellij/contract_version_1/session_info"
    sel=$(zellij list-sessions -n 2>/dev/null | fzf \
      --preview "sed -n '/swap_tiled_layout/q;p' \"$info/{1}/session-layout.kdl\" 2>/dev/null || echo '(no saved layout)'" \
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
  #   1) focus the pane named "editor" (falls back to next pane if unnamed)
  #   2) auto-detect helix vs nvim vs shell by inspecting the pane's process
  #   3) send the appropriate open command:
  #        helix (`hx`) -> ESC :o <path> <CR>
  #        nvim         -> ESC :e <path> <CR>
  #        other (shell) -> "$EDITOR <path>" as a fallback
  # zellij lacks a stable focus-pane-by-name action; we walk panes and match
  # the tab's pane list from `zellij action query-tab-names` is not enough
  # (it only lists tab names). We use directional focus as a fallback: from
  # the tree pane (typical yazi position, top-left), one "focus-next-pane"
  # cycles to the editor pane.
  zellij-reveal-file = pkgs.writeShellScriptBin "zellij-reveal-file" ''
    set -e
    file="''${1:-}"
    [ -n "$file" ] || { echo "usage: zellij-reveal-file <path>" >&2; exit 1; }
    [ -n "$ZELLIJ" ] || { echo "not inside a zellij session" >&2; exit 1; }

    # Move focus to the editor pane. `zellij action focus-next-pane` cycles
    # through visible tiled panes in a deterministic order. In the ide-yazi
    # layout, the yazi pane is the tree; next pane is the editor.
    zellij action focus-next-pane >/dev/null 2>&1 || true

    # Sniff the process running in the now-focused pane. `zellij action
    # list-clients` doesn't give us that; instead we introspect via /proc.
    # Approach: find the child process of the current pane's shell PID.
    # We rely on ZELLIJ setting PANE_ID/PANE_TITLE isn't enough — use pgrep
    # against known editor names as a best-effort.
    detect_editor() {
      # Prefer helix (evil-helix ships `hx`), then nvim, then $EDITOR.
      if pgrep -x hx  >/dev/null 2>&1; then echo hx;   return; fi
      if pgrep -x helix >/dev/null 2>&1; then echo hx; return; fi
      if pgrep -x nvim >/dev/null 2>&1; then echo nvim; return; fi
      if pgrep -x vim  >/dev/null 2>&1; then echo vim;  return; fi
      echo shell
    }
    ed=$(detect_editor)

    # Absolute path — editors resolve relative paths in their own cwd which
    # may not match yazi's cwd.
    case "$file" in
      /*) abs="$file" ;;
      *)  abs="$PWD/$file" ;;
    esac

    # Send keys. `zellij action write 27` = ESC. `write 13` = Enter.
    case "$ed" in
      hx)
        zellij action write 27
        zellij action write-chars ":open $abs"
        zellij action write 13
        ;;
      nvim|vim)
        zellij action write 27
        zellij action write-chars ":edit $abs"
        zellij action write 13
        ;;
      shell)
        # Assume a running shell prompt; type an editor command.
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

  home.packages = [zellij-autostart zjp zjl zellij-reveal-file zellij-rename-session zpin zunpin sn zellij-cd-attach zellij-reaper];

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
      ".config/zellij/layouts/ide-yazi.kdl".source = ../../../ressources/dots/zellij/layouts/ide-yazi.kdl;
    }
    // lib.mapAttrs' (name: src: {
      name = ".config/zellij/plugins/${name}";
      value = {source = src;};
    })
    plugins;
}
