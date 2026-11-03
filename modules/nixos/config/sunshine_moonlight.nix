{pkgs, ...}: let
  jq = "${pkgs.jq}/bin/jq";

  # Steam-gamescope-like behaviour for apps that open a normal niri window:
  # launch (or reuse) the window matching <app-id regex>, focus + fullscreen it, then stay
  # alive until it closes, so Sunshine ends the stream when the app is quit. Needed because
  # e.g. `helium --app-id=...` hands the window to an already running Helium and exits at once.
  #   stream-window <app-id regex> <cmd...>   |   stream-window --close <app-id regex>
  stream-window = pkgs.writeShellScriptBin "stream-window" ''
    find_window() {
      niri msg --json windows | ${jq} -r --arg re "$1" 'first(.[] | select((.app_id // "") | test($re)) | .id) // empty'
    }

    if [ "$1" = --close ]; then
      id=$(find_window "$2")
      [ -n "$id" ] && niri msg action close-window --id "$id"
      exit 0
    fi

    re=$1; shift
    id=$(find_window "$re")
    if [ -z "$id" ]; then
      # setsid: ending the stream kills our process group, it must not take the browser along
      setsid -f "$@" >/dev/null 2>&1
      for _ in $(seq 60); do
        sleep 0.5
        id=$(find_window "$re")
        [ -n "$id" ] && break
      done
      [ -n "$id" ] || { echo "stream-window: no window matching '$re' appeared" >&2; exit 1; }
      sleep 0.5 # let niri lay out the new window before reading its size
    fi

    niri msg action focus-window --id "$id"
    # fullscreen-window toggles, so only send it if the window doesn't already cover the output
    size=$(niri msg --json windows | ${jq} -r --argjson id "$id" '.[] | select(.id == $id) | .layout.window_size | "\(.[0])x\(.[1])"')
    out=$(niri msg --json focused-output | ${jq} -r '.logical | "\(.width)x\(.height)"')
    [ "$size" = "$out" ] || niri msg action fullscreen-window --id "$id"

    while niri msg --json windows | ${jq} -e --argjson id "$id" 'any(.[]; .id == $id)' >/dev/null; do
      sleep 2
    done
  '';

  # Helium PWA (installed via Helium, ~/.local/share/applications/chrome-<id>-Default.desktop).
  # Calls the `helium` wrapper instead of the .desktop's Exec, which pins a nix store path.
  # The regex matches both Wayland (chrome-<id>-Default) and X11 (crx_<id>) app ids.
  youtubeTvId = "jdpgmnmabkimlheojapahlejjekibnlk";

  # YouTube TV (youtube.com/tv) only reacts to keys, not to the browser Gamepad API, so while
  # it's streamed the Moonlight controller / TV remote (a Sunshine virtual pad) is remapped to
  # keys with makima. Started per stream rather than as a daemon: makima re-emits unmapped pad
  # events through its own virtual devices, which Steam/games would see as a phantom 2nd pad.
  pad-to-keys = pkgs.writeShellScriptBin "pad-to-keys" ''
    # usage: pad-to-keys <makima config.toml>, runs until killed.
    # makima matches configs by exact device name, and the virtual pad's name depends on the
    # profile Sunshine picks (Xbox/DualSense/...): copy the config for every Sunshine pad found
    cfg=''${XDG_RUNTIME_DIR:-/tmp}/pad-to-keys
    rm -rf "$cfg" && mkdir -p "$cfg"
    for _ in $(seq 20); do # the pad appears only after the client connects
      names=$(awk -F'"' '/^N: Name=/ {n = $2} /^H: Handlers=.*js[0-9]/ {print n}' /proc/bus/input/devices \
        | grep '^Sunshine ' | sort -u) # not "libvirtualhid Mouse (Absolute)", it has a js handler too
      [ -n "$names" ] && break
      sleep 0.5
    done
    [ -n "$names" ] || { echo "pad-to-keys: no Sunshine gamepad found" >&2; exit 0; }
    while IFS= read -r name; do
      echo "pad-to-keys: remapping '$name'" >&2
      cp "$1" "$cfg/''${name//\//}.toml"
    done <<< "$names"
    MAKIMA_CONFIG=$cfg exec ${pkgs.makima}/bin/makima
  '';
  # 16_BIT_AXIS: the virtual Xbox pad's sticks are -32768..32767 (checked with evtest); on a
  # DualSense profile (0..255) the stick just stays inert instead of drifting
  youtube-tv-keys = pkgs.writeText "youtube-tv-keys.toml" ''
    [remap]
    BTN_DPAD_UP = ["KEY_UP"]
    BTN_DPAD_DOWN = ["KEY_DOWN"]
    BTN_DPAD_LEFT = ["KEY_LEFT"]
    BTN_DPAD_RIGHT = ["KEY_RIGHT"]
    LSTICK_UP = ["KEY_UP"]
    LSTICK_DOWN = ["KEY_DOWN"]
    LSTICK_LEFT = ["KEY_LEFT"]
    LSTICK_RIGHT = ["KEY_RIGHT"]
    BTN_SOUTH = ["KEY_ENTER"] # A / cross / remote OK
    BTN_EAST = ["KEY_ESC"] # B / circle / remote back: YouTube TV "back"
    BTN_SELECT = ["KEY_ESC"]
    # no Start -> KEY_PLAYPAUSE: niri binds that key to playerctl, which may pause another player

    [settings]
    GRAB_DEVICE = "true"
    LSTICK = "bind"
    LSTICK_DEADZONE = "64"
    RSTICK = "disabled"
    16_BIT_AXIS = "true"
  '';
  youtube-tv-stream = pkgs.writeShellScript "youtube-tv-stream" ''
    ${pad-to-keys}/bin/pad-to-keys ${youtube-tv-keys} &
    pad=$!
    trap 'kill "$pad" 2>/dev/null' EXIT
    ${stream-window}/bin/stream-window ${youtubeTvId} helium --profile-directory=Default --app-id=${youtubeTvId}
  '';

  # Plasma Bigscreen as a window inside niri: kwin_wayland runs nested (Wayland backend)
  # whenever WAYLAND_DISPLAY is set. Deliberately not plasma-bigscreen-wayland /
  # startplasma-wayland: those start the full Plasma session (systemd user units,
  # powerdevil, autostart apps, env import) which would fight niri's session.
  # A private dbus-run-session bus keeps kwin/plasmashell/kded off niri's session bus.
  bigscreen = pkgs.kdePackages.plasma-bigscreen;
  bigscreen-shell = pkgs.writeShellScript "plasma-bigscreen-shell" ''
    # remote/gamepad -> Bigscreen UI navigation (same as plasma-bigscreen-swap-session)
    QT_QPA_PLATFORM=offscreen plasma-bigscreen-inputhandler &
    exec plasmashell --no-respawn -p org.kde.plasma.bigscreen
  '';
  plasma-bigscreen-nested = pkgs.writeShellScriptBin "plasma-bigscreen-nested" ''
    # sets PLASMA_PLATFORM=mediacenter, PLASMA_DEFAULT_SHELL, XDG_CONFIG_DIRS, ...
    PATH=${bigscreen}/bin:$PATH
    . plasma-bigscreen-common-env
    export PATH=${bigscreen}/bin:$PATH
    export XDG_CURRENT_DESKTOP=KDE KDE_FULL_SESSION=true KDE_SESSION_VERSION=6

    # render at the Moonlight client's resolution; --fullscreen asks niri for fullscreen.
    # plasmashell exiting ends kwin (--exit-with-session), which ends the stream
    exec ${pkgs.dbus}/bin/dbus-run-session -- kwin_wayland --xwayland \
      --width "''${SUNSHINE_CLIENT_WIDTH:-1920}" --height "''${SUNSHINE_CLIENT_HEIGHT:-1080}" \
      --fullscreen true \
      --exit-with-session=${bigscreen-shell}
  '';
in {
  # also on PATH for testing without Moonlight
  environment.systemPackages = [stream-window plasma-bigscreen-nested];

  services.sunshine = {
    enable = true;
    # NVENC (GPU encoding): the default build has no CUDA and no driver runpath, and the
    # capSysAdmin wrapper strips LD_LIBRARY_PATH, so libcuda/libnvidia-encode never load
    # and Sunshine silently falls back to CPU encoding (libx264). Builds locally.
    package = pkgs.sunshine.override {cudaSupport = true;};
    autoStart = true;
    openFirewall = true;
    capSysAdmin = true;

    # declarative apps: replaces ~/.config/sunshine/apps.json, web UI app editing is disabled
    applications = {
      env.PATH = "$(PATH):$(HOME)/.local/bin";
      apps = [
        {
          name = "Desktop";
          image-path = "desktop.png";
        }
        {
          # Deck-like: Steam gamepad UI nested in gamescope (steam-gamescope, gaming.nix)
          # cmd (not detached): quitting Steam ends the stream, ending the stream stops Steam
          name = "Steam (Gamescope)";
          image-path = "steam.png";
          cmd = "steam-gamescope";
          prep-cmd = [
            {
              do = "";
              undo = "sh -c 'pgrep -x steam >/dev/null && steam -shutdown || true'";
            }
          ];
        }
        {
          # same lifetime as Steam above: closing the PWA ends the stream, ending the stream
          # closes the PWA window (only that window, the rest of Helium keeps running)
          name = "YouTube TV";
          cmd = "${youtube-tv-stream}";
          prep-cmd = [
            {
              do = "";
              undo = "${stream-window}/bin/stream-window --close ${youtubeTvId}";
            }
          ];
        }
        {
          # Pegasus frontend (gaming.nix, forced to X11 there) in a niri window, like YouTube TV:
          # closing Pegasus ends the stream. The app_id regex is a guess, check it with
          # `niri msg --json windows` once Pegasus is open and tighten it if needed
          name = "Pegasus";
          cmd = "${stream-window}/bin/stream-window '(?i)pegasus' pegasus-fe";
          prep-cmd = [
            {
              do = "";
              undo = "${stream-window}/bin/stream-window --close '(?i)pegasus'";
            }
          ];
        }
        {
          name = "Plasma Bigscreen";
          cmd = "${plasma-bigscreen-nested}/bin/plasma-bigscreen-nested";
        }
      ];
    };
  };
}
