{
  pkgs,
  inputs,
  username,
  config,
  ...
}:
{
  # services = {
  #   blueman.enable = true;
  #   gnome.gnome-keyring.enable = true;
  #   logind.powerKey = "ignore";
  # };

  # systemd = {
  #   user.services = {
  #     # Polkit
  #     polkit-gnome-authentication-agent-1 = {
  #       description = "polkit-gnome-authentication-agent-1";
  #       wantedBy = [ "graphical-session.target" ];
  #       wants = [ "graphical-session.target" ];
  #       after = [ "graphical-session.target" ];
  #       serviceConfig = {
  #         Type = "simple";
  #         ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
  #         Restart = "on-failure";
  #         RestartSec = 1;
  #         TimeoutStopSec = 10;
  #       };
  #     };
  #     niri-flake-polkit.enable = false;
  #
  #     cliphist = {
  #       description = "wl-paste + cliphist service";
  #       serviceConfig = {
  #         Type = "simple";
  #         ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
  #         Restart = "on-failure";
  #       };
  #     };
  #
  #     swaybg = {
  #       description = "swaybg service";
  #       serviceConfig = {
  #         Type = "simple";
  #         ExecStart = "${pkgs.swaybg}/bin/.swaybg-wrapped -m fill -i ${
  #           pkgs.graphite-gtk-theme.override { wallpapers = true; }
  #         }/share/backgrounds/wave-Dark.png";
  #         Restart = "on-failure";
  #       };
  #     };
  #   };
  # };
  #
  # xdg.portal = {
  #   enable = true;
  #   extraPortals = with pkgs; [
  #     xdg-desktop-portal-gtk
  #     xdg-desktop-portal-gnome
  #   ];
  #   config = {
  #     common = {
  #       default = [
  #         "gnome"
  #         "gtk"
  #       ];
  #       "org.freedesktop.impl.portal.Access" = [ "gtk" ];
  #       "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
  #       "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
  #       "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
  #     };
  #   };
  # };

  # nixpkgs.overlays = [ inputs.niri.overlays.niri ];
  # niri-flake.cache.enable = false;

  # environment.sessionVariables.NIXOS_OZONE_WL = "1";
  #
  # environment.systemPackages = with pkgs; [
  #   cliphist
  #   hypridle
  #   hyprlock
  #   kitty
  #   networkmanagerapplet
  #   playerctl
  #   qalculate-gtk
  #   swaynotificationcenter
  #   swayosd
  #   syncthingtray
  #   wl-clipboard
  #   wl-clip-persist
  #   wl-color-picker
  #   wofi-power-menu
  #   xwayland-satellite
  # ];
  #
  programs = {

    niri = {
      enable = true;
      # package = pkgs.niri-unstable;
      settings = {
        prefer-no-csd = true;
        hotkey-overlay.skip-at-startup = true;
        screenshot-path = "~/Pictures/Screenshots/%Y-%m-%d-%H%M%S.png";

        environment = {
          DISPLAY = ":1";
          ELM_DISPLAY = "wl";
          GDK_BACKEND = "wayland,x11";
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
          SDL_VIDEODRIVER = "wayland";
          CLUTTER_BACKEND = "wayland";
        };

        spawn-at-startup =
          let
            sh = [
              "sh"
              "-c"
            ];
          in
          [
            { command = sh ++ [ "wl-clip-persist --clipboard regular" ]; }
            { command = sh ++ [ "cliphist wipe" ]; }
            { command = sh ++ [ "systemctl --user start cliphist.service" ]; }
            { command = sh ++ [ "systemctl --user start hypridle.service" ]; }
            { command = sh ++ [ "systemctl --user start waybar.service" ]; }
            # { command = sh ++ [ "systemctl --user start hyprpanel" ]; }
            { command = sh ++ [ "systemctl --user start xwayland-satellite.service" ]; }
            { command = sh ++ [ "systemctl --user start swaybg.service" ]; }
            { command = sh ++ [ "systemctl --user start swaync.service" ]; }
            { command = sh ++ [ "sleep 1 && blueman-applet" ]; }
            { command = sh ++ [ "sleep 3 && syncthingtray --wait" ]; }
            { command = sh ++ [ "id=0" ]; }
            { command = [ "swayosd-server" ]; }
            { command = [ "nm-applet" ]; }
          ];

        input = {
          power-key-handling.enable = false;
          warp-mouse-to-focus.enable = true;

          mouse = {
            accel-speed = 0.5;
          };
          touchpad = {
            accel-speed = 0.5;
          };

          keyboard.xkb = {
            layout = "us, de";
            variant = "altgr-intl,";
            options = "grp:win_space_toggle";
          };
          # keyboard = {
          #   numlock = true;
          # };

          focus-follows-mouse = {
            enable = true;
            max-scroll-amount = "25%";
          };
        };

        binds =
          with config.lib.niri.actions;
          let
            sh = spawn "sh" "-c";
          in
          {
            # "Super+Shift+M" = sh "~/.config/nixos/scripts/wall_cycle.sh";
            "Super+Q".action = close-window;
            "Super+W".action = toggle-window-floating;
            "Alt+Return".action = fullscreen-window;
            # "Super+Tab".action = toggle-overview;

            # "Alt+X".action = close-window;
            # "Alt+F".action = toggle-window-floating;
            # "Super+F".action = fullscreen-window;

            "Super+Right".action = focus-column-or-monitor-right;
            "Super+Left".action = focus-column-or-monitor-left;
            "Super+Up".action = focus-window-or-monitor-up;
            "Super+Down".action = focus-window-or-monitor-down;

            "Super+L".action = focus-column-or-monitor-right;
            "Super+H".action = focus-column-or-monitor-left;
            "Super+K".action = focus-window-or-monitor-up;
            "Super+J".action = focus-window-or-monitor-down;

            "Super+Return".action = move-window-to-monitor-next;

            "Super+Ctrl+Shift+Right".action = consume-or-expel-window-right;
            "Super+Ctrl+Shift+Left".action = consume-or-expel-window-left;
            "Super+Ctrl+Shift+Up".action = move-window-up-or-to-workspace-up;
            "Super+Ctrl+Shift+Down".action = move-window-down-or-to-workspace-down;

            "Super+Ctrl+Shift+L".action = consume-or-expel-window-right;
            "Super+Ctrl+Shift+H".action = consume-or-expel-window-left;
            "Super+Ctrl+Shift+K".action = move-window-up-or-to-workspace-up;
            "Super+Ctrl+Shift+J".action = move-window-down-or-to-workspace-down;

            "Ctrl+Alt+Q".action = switch-preset-column-width;
            "Ctrl+Alt+A".action = switch-preset-window-height;
            "Ctrl+Alt+W".action = maximize-column;
            "Ctrl+Alt+Tab".action = toggle-column-tabbed-display;

            "Ctrl+Super+Up".action = focus-workspace-up;
            "Ctrl+Super+Down".action = focus-workspace-down;
            "Ctrl+Super+Left".action = focus-workspace-up;
            "Ctrl+Super+Right".action = focus-workspace-down;

            "Ctrl+Super+K".action = focus-workspace-up;
            "Ctrl+Super+J".action = focus-workspace-down;
            "Ctrl+Super+H".action = focus-workspace-up;
            "Ctrl+Super+L".action = focus-workspace-down;

            "Super+1".action = focus-workspace 1;
            "Super+2".action = focus-workspace 2;
            "Super+3".action = focus-workspace 3;
            "Super+4".action = focus-workspace 4;
            "Super+5".action = focus-workspace 5;
            "Super+6".action = focus-workspace 6;
            "Super+7".action = focus-workspace 7;
            "Super+8".action = focus-workspace 8;
            "Super+9".action = focus-workspace 9;
            "Super+0".action = focus-workspace 10;

            "Print".action = screenshot;

            # "Super+V".action = sh "cliphist list | wofi -S dmenu | cliphist decode | wl-copy";
            "Ctrl+Alt+C".action = sh "pidof wl-color-picker || wl-color-picker";
            "Super+C".action = spawn "qalculate-gtk";
            # "Super+T".action = spawn "kitty";
            # "Super+T".action = spawn "ghostty";
            "Super+T".action = spawn "foot";
            # "Super+A".action = sh "wofi  -drun || wofi";
            "Super+A".action = sh "sherlock"; # walker -C
            # "Super+S".action = sh "swaync-client -t";
            # "Super+Escape".action = sh "loginctl lock-session";
            "Super+Escape".action = sh "hyprlock";
            "Super+Alt+P".action = sh "pidof wofi-power-menu || wofi-power-menu";
            "XF86PowerOff".action = sh "pidof wofi-power-menu || wofi-power-menu";
            "XF86AudioMute".action = sh "swayosd-client --output-volume=mute-toggle";
            "XF86AudioPlay".action = sh "playerctl play-pause";
            "XF86AudioPrev".action = sh "playerctl previous";
            "XF86AudioNext".action = sh "playerctl next";
            "XF86AudioRaiseVolume".action = sh "swayosd-client --output-volume=raise";
            "XF86AudioLowerVolume".action = sh "swayosd-client --output-volume=lower";
            "XF86MonBrightnessUp".action = sh "swayosd-client --brightness=raise";
            "XF86MonBrightnessDown".action = sh "swayosd-client --brightness=lower";
          };

        # gestures.hot-corners.enable = false;

        outputs = {
          "HDMI-A-1" = {
            mode = {
              width = 1920;
              height = 1080;
              refresh = null;
            };
            scale = 1.0;
            position = {
              x = -1920;
              y = 540;
            };
            transform = "90";
          };
          "DP-2" = {
            # mode = {
            #     width = 2160;
            #     height = 1440;
            #     refresh = null;
            # };
            scale = 1.0;
            position = {
              x = 0;
              y = 0;
            };
          };
        };

        # output = {
        #   # HDMI-A-1 = {
        #   #   Transform = 90;
        #   # };
        #   DP-2 = {
        #     Transform = 90;
        #   };
        # };

        layout = {
          gaps = 8;
          default-column-width.proportion = 0.5;
          insert-hint.display = {
            color = "rgba(224, 224, 224, 30%)";
          };

          preset-column-widths = [
            { proportion = 1.0 / 3.0; }
            { proportion = 0.5; }
            { proportion = 2.0 / 3.0; }
          ];

          preset-window-heights = [
            { proportion = 1.0 / 3.0; }
            { proportion = 0.5; }
            { proportion = 2.0 / 3.0; }
            { proportion = 1.0; }
          ];

          border.enable = true;

          focus-ring = {
            enable = true;
            width = 1;
            active = {
              color = "#22222222";
            };
            inactive = {
              color = "#00000000";
            };
          };

          tab-indicator = {
            enable = true;
            place-within-column = true;
            width = 4;
            corner-radius = 8;
            gap = 8;
            gaps-between-tabs = 8;
            position = "top";
            active = {
              color = "rgba(224, 224, 224, 100%)";
            };
            inactive = {
              color = "rgba(224, 224, 224, 30%)";
            };
            length.total-proportion = 1.0;
          };
        };

        # overview.backdrop-color = "#0f0f0f";

        window-rules = [
          {
            geometry-corner-radius =
              let
                radius = 12.0;
              in
              {
                bottom-left = radius;
                bottom-right = radius;
                top-left = radius;
                top-right = radius;
              };
            clip-to-geometry = true;
            draw-border-with-background = false;
          }
          {
            matches = [
              { app-id = ".blueman-manager-wrapped"; }
              { app-id = "nm-connection-editor"; }
              { app-id = "com.saivert.pwvucontrol"; }
              { app-id = "org.pipewire.Helvum"; }
              { app-id = "wdisplays"; }
              { app-id = "qalculate-gtk"; }
              { title = "Syncthing Tray"; }
            ];
            open-floating = true;
          }
          {
            matches = [
              { is-window-cast-target = true; }
            ];

            focus-ring = {
              active = {
                color = "rgba(224, 53, 53, 100%)";
              };
              inactive = {
                color = "rgba(224, 53, 53, 30%)";
              };
            };

            tab-indicator = {
              active = {
                color = "rgba(224, 53, 53, 100%)";
              };
              inactive = {
                color = "rgba(224, 53, 53, 30%)";
              };
            };

            opacity = 0.96;
          }
        ];
      };
    };
  };
  #   dconf.enable = true;
  #
  #   ssh.askPassword = "";
  #   xwayland.enable = true;
  # };
}
