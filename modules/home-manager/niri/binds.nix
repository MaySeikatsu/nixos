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

  # programs = {
  #   niri = {
  #     enable = true;
  #     package = pkgs.niri;
  #   };
  #
  #   dconf.enable = true;
  #   ssh.askPassword = "";
  #   xwayland.enable = true;
  # };
      programs = {

        niri = {
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
              warp-mouse-to-focus = true;

              mouse = {
                accel-speed = 0.5;
              };

              touchpad = {
                accel-speed = 0.5;
              };

              keyboard.xkb.layout = "de";

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
                "Alt+X".action = close-window;
                "Alt+F".action = toggle-window-floating;
                "Super+F".action = fullscreen-window;

                "Alt+Right".action = focus-column-or-monitor-right;
                "Alt+Left".action = focus-column-or-monitor-left;
                "Alt+Up".action = focus-window-or-monitor-up;
                "Alt+Down".action = focus-window-or-monitor-down;

                "Ctrl+Alt+Right".action = consume-or-expel-window-right;
                "Ctrl+Alt+Left".action = consume-or-expel-window-left;
                "Ctrl+Alt+Up".action = move-window-up-or-to-workspace-up;
                "Ctrl+Alt+Down".action = move-window-down-or-to-workspace-down;
                "Ctrl+Alt+Return".action = move-window-to-monitor-next;

                "Ctrl+Alt+Q".action = switch-preset-column-width;
                "Ctrl+Alt+A".action = switch-preset-window-height;
                "Ctrl+Alt+W".action = maximize-column;
                "Ctrl+Alt+Tab".action = toggle-column-tabbed-display;

                "Super+Q".action = toggle-overview;

                "Alt+Super+Up".action = focus-workspace-up;
                "Alt+Super+Down".action = focus-workspace-down;
                "Alt+1".action = focus-workspace 1;
                "Alt+2".action = focus-workspace 2;
                "Alt+3".action = focus-workspace 3;
                "Alt+4".action = focus-workspace 4;
                "Alt+5".action = focus-workspace 5;
                "Alt+6".action = focus-workspace 6;
                "Alt+7".action = focus-workspace 7;
                "Alt+8".action = focus-workspace 8;
                "Alt+9".action = focus-workspace 9;
                "Alt+0".action = focus-workspace 10;

                "Print".action = screenshot;

                "Super+V".action = sh "cliphist list | wofi -S dmenu | cliphist decode | wl-copy";
                "Ctrl+Alt+C".action = sh "pidof wl-color-picker || wl-color-picker";
                "Super+C".action = spawn "qalculate-gtk";
                "Ctrl+Alt+T".action = spawn "kitty";
                "Super+A".action = sh "pidof wofi || wofi";
                "Super+S".action = sh "swaync-client -t";
                "Super+Alt+L".action = sh "loginctl lock-session";
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

            gestures.hot-corners.enable = false;

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

              border.enable = false;

              focus-ring = {
                enable = true;
                width = 2;
                active = {
                  color = "#e0e0e0ff";
                };
                inactive = {
                  color = "#00000000";
                };
              };

              tab-indicator = {
                enable = true;
                place-within-column = true;
                width = 8;
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

            overview.backdrop-color = "#0f0f0f";

            window-rules = [
              {
                geometry-corner-radius =
                  let
                    radius = 8.0;
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
              }
            ];
          };
        };
      };
}

