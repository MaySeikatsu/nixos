{...}: {
  # noctalia v5 (pkgs.noctalia, binary `noctalia`) — the default shell for
  # niri and mango. v4 (pkgs.noctalia-shell, binary `noctalia-shell`) stays
  # installed via hosts/configuration-shared.nix as a fallback; its launch
  # lines are commented out in niri/init.kdl and mango/autostart.conf.
  #
  # v4 -> v5 IPC mapping used across the binds (niri/binds.kdl,
  # mango/binds.conf, hyprland_utils/hypridle.nix, scripts/swww/*):
  #   noctalia-shell ipc call launcher toggle      -> noctalia msg panel-toggle launcher
  #   noctalia-shell ipc call launcher clipboard   -> noctalia msg panel-toggle clipboard
  #   noctalia-shell ipc call bar toggle           -> noctalia msg bar-toggle
  #   noctalia-shell ipc call lockScreen lock      -> noctalia msg session lock
  #   noctalia-shell ipc call wallpaper set P, MON -> noctalia msg wallpaper-set MON P
  # Full list: `noctalia msg --help`. Panel ids: launcher clipboard session
  # wallpaper control-center[ audio|network|bluetooth|media|calendar|...].
  #
  # Config layering: this module writes ~/.config/noctalia/config.toml (base);
  # anything changed in the GUI lands in ~/.local/state/noctalia/settings.toml
  # and overrides it. So `settings` below are declarative *defaults*, not a
  # lockdown — the bar/dock/lockscreen layout tuned in the GUI stays as-is.
  # Inspect the merged result with `noctalia config export [merged|full]`.
  programs.noctalia = {
    enable = true;
    # Started by the compositor (exec-once / spawn-at-startup) so it inherits
    # the session env; a user service would race WAYLAND_DISPLAY on niri.
    systemd.enable = false;
    checkConfig = true;

    settings = {
      # --- carried over from v4 settings.json --------------------------------
      shell = {
        # v4 ui.fontDefault / ui.fontFixed
        font_family = "Source Sans 3";
        # v4 general.avatarImage
        avatar_path = "/home/maike/Pictures/wallpaper/1358528.png";
        # v4 general.telemetryEnabled
        telemetry_enabled = false;
        settings_show_advanced = true;
        screen_time_enabled = true;
        # plasma-polkit-agent is started by the compositor autostart instead
        polkit_agent = false;
        # v4 general.animationSpeed 0.9
        animation = {
          enabled = true;
          speed = 0.9;
        };
        # v4 general.showScreenCorners
        screen_corners.enabled = true;
        # v4 ui.panelsAttachedToBar
        panel = {
          launcher_placement = "attached";
          clipboard_placement = "attached";
          transparency_mode = "glass";
        };
        # Shell-native screenshots (also bound in mango/binds.conf as an
        # alternative to grim/slurp): saves to the same dir niri used.
        screenshot = {
          directory = "/home/maike/Pictures/Screenshots";
          filename_pattern = "%Y-%m-%d-%H%M%S.png";
          copy_to_clipboard = true;
          save_to_file = true;
          freeze_screen = true;
        };
      };

      # v4 colorSchemes: useWallpaperColors=true, predefinedScheme "Rose Pine Moon"
      theme = {
        source = "wallpaper";
        wallpaper_scheme = "faithful";
        builtin = "Rosé Pine";
        mode = "auto";
      };

      # v4 wallpaper.directory (state.toml already narrows this to
      # Pictures/wallpaper; that override wins).
      wallpaper = {
        enabled = true;
        directory = "/home/maike/Pictures/wallpaper";
        transition = ["fade" "disc" "stripes" "wipe" "honeycomb" "zoom"];
        transition_on_startup = true;
      };

      # v4 location: weather on, metric, week starts Monday
      location = {
        auto_locate = false;
        # address = "";
      };
      weather = {
        enabled = true;
        unit = "metric";
        effects = true;
      };

      # v4 hooks.wallpaperChange pointed at swww_wallpapersync.sh (v5 now owns
      # the wallpaper, and that script calls back into `noctalia msg
      # wallpaper-set`, which would loop — so it's not wired here).
      # v4 hooks.screenLock/screenUnlock killed niri-screensaver-launch; that
      # tool isn't installed any more, so nothing to carry over.
      hooks = {
        wallpaper_changed = [];
        session_locked = [];
        session_unlocked = [];
      };

      # v4 general.lockOnSuspend
      lockscreen = {
        enabled = true;
        lock_before_suspend = true;
        blurred_desktop = true;
      };

      # v4 idle was disabled (hypridle handled it, also disabled). Keep off.
      idle.behavior = {
        lock.enabled = false;
        screen-off.enabled = false;
        lock-and-suspend.enabled = false;
      };

      nightlight.enabled = false;
    };
  };
}
