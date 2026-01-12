# *.nix
{...}: let
  # fg = "#${colors.base05}";
  # bg = "#${colors.base00}";
  # accent = "#${colors.base0D}";
  # warning = "#${colors.base08}";
  # hover = "#${colors.base02}";
  # background = grep "^let color1" home/maike/.cache/wal/colors-wal.vim | sed -E 's/.*= "#([0-9A-Fa-f]+)"/\1/') -d 1 -c $(grep '^let color1' ~/.cache/wal/colors-wal.vim | sed -E 's/.*= "#([0-9A-Fa-f]+)"/\1/') -d 2 -c $(grep '^let color1' ~/.cache/wal/colors-wal.vim | sed -E 's/.*= "#([0-9A-Fa-f]+)"/\1/'
  WALLPAPER = "$(readlink -f /home/maike/.current-wallpaper)";
  color1 = "#ffffff";
  color2 = "#afffff";
  colorText = "#000000";
in {
  # imports = [ inputs.hyprpanel.homeManagerModules.hyprpanel ];

  programs.hyprpanel = {
    enable = false;
    # systemd.enable = true;
    # hyprland.enable = true;
    # overwrite.enable = true;
    # overlay.enable = true;

    # override = {
    #   # # Global bar settings
    #   # "theme.bar.background" = bg;
    # "theme.bar.background" = background;
    #   # "theme.bar.foreground" = fg;
    #   # "theme.bar.menus.border.color" = accent;
    #   #
    #   "bar.workspaces.workspaceIconMap.1.icon" = "一";
    #   #           "二": "<U+F269>",
    #   #           "三": "<U+EAC4>",
    #   #           "四": "<U+EC1B>",
    #   #           "五": "<U+F02B4>",
    #   #           "六": "<U+F1FF> ",
    #   #           "七": "<U+EB1C>"
    #   #           "八": "<U+EB1C>"
    #   #           "九": "<U+EB1C>"
    #   #           '';
    #   # };
    # };
    settings = {
      layout = {
        "bar.layouts" = {
          "0" = {
            left = ["dashboard" "windowtitle" "systray" "cava" "media"];
            middle = ["workspaces"];
            right = [
              "volume"
              "network"
              "bluetooth"
              "clock"
              "battery"
              "notifications"
              "hypridle"
              "power"
            ];
          };
        };
        "bar.layouts" = {
          "1" = {
            left = ["dashboard" "windowtitle" "systray" "media" "cava"];
            middle = ["workspaces"];
            right = ["volume" "network" "clock" "notifications" "hypridle" "power"];
          };
        };
      };
      bar = {
        workspaces = {
          # show_icons = true;
          show_numbered = false;
          ignored = "[-99]";
          monitorSpecific = true;
          workspaces = 3;
          showWsIcons = false;
          show_icons = true;
          workspaceIconMap = {
            example = ''
              "一": "<U+EEFE>",
              "二": "<U+F269>",
              "三": "<U+EAC4>",
              "四": "<U+EC1B>",
              "五": "<U+F02B4>",
              "六": "<U+F1FF> ",
              "七": "<U+EB1C>"
              "八": "<U+EB1C>"
              "九": "<U+EB1C>"
            '';
          };
        };
        launcher = {
          autoDetectIcon = false;
          icon = "󱄅_󱄅";
          #icon = "󰣇_󰣇";
        };
        volume = {
          rightClick = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
          middleClick = "pavucontrol";
        };
        clock = {
          format = "%y/%m/%d  %H:%M";
          time = {
            military = true;
            hideSeconds = true;
          };
          weather.unit = "metric";
        };
        media.show_active_only = false;
        notifications.show_total = true;
        windowtitle.leftClick = "'pkill rofi||/nix/store/rsb5ihbh4m3q4x046vc0y1r301i8j3is-ags-1.8.2/bin/ags -t overview'";
        battery.hideLabelWhenFull = true;
        media.format = "{title}";
        autoHide = "fullscreen";
        notifications.position = "top";
        customModules = {
          cava = {
            showIcon = true;
            icon = "";
            spaceCharacter = " ";
            barCharacters = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
            showActiveOnly = true;
            bars = 12;
            # channels = 2;
            framerate = 90;
            # samplerate = 44100;
            # autoSensitivity = true;
            # lowCutoff = 50;
            # highCutoff = 10000;
            # noiseReduction = 0.77;
            # stereo = true;
            # leftClick = "";
            # rightClick = "";
            # middleClick = "";
            # scrollUp = "";
            # scrollDown = "";
          };
          updates = {
            updateCommand = "jq '[.[].cvssv3_basescore | to_entries | add | select(.value > 5)] | length' <<< $(vulnix -S --json)";
            pollingInterval = 1440000;
            icon = {
              updated = "󰋼";
              pending = "󰋼";
            };
          };
        };
      };
      theme = {
        bar = {
          buttonStyle = "default";
          # radius = "2.0";
          buttons = {
            icon = color1;
            text = color1;
            borderColor = color1;
            monochrome = true;
            workspaces = {
              active = color1;
              occupied = color2;
              spacing = "0.4";
              enableBorder = true;
              pill = {
                radius = "0.3rem * 0.2";
                height = "4em";
                width = "5em";
                active_width = "12em";
              };
            };
            modules = {
              ram.enableBorder = false;
              power.enableBorder = true;
            };
            background_hover_opacity = 80;
            # background = "#029192";
            innerRadiusMultiplier = "0.4";
            radius = "0.0em";
            y_margins = "0.5em";
            padding_y = "0.1rem";
            padding_x = "0.7rem";
            spacing = "0.25em";
            dashboard.enableBorder = true;
            enableBorders = true;
          };
          border = {
            location = "none";
            width = "0.1em";
          };
          outer_spacing = "0.25em";
          label_spacing = "0.5em";
          border_radius = "0.4em";
          margin_sides = "1.5em";
          margin_bottom = "0em";
          margin_top = "0.5em";
          layer = "overlay";
          opacity = 80;
          # opacity = 90;
          scaling = 85;
          menus = {
            monochrome = true;
            label = color2;
            text = color2;
            icons.active = color2;
            buttons.default = color2;
            buttons.text = color1;
            menu = {
              dashboard = {
                # confirmation_scaling = 80;
                scaling = 70;
                confirmation_scaling = 80;
              };
              battery.scaling = 80;
              bluetooth.scaling = 80;
              clock.scaling = 80;
              media.scaling = 80;
              notifications.scaling = 80;
              volume.scaling = 80;
            };
            popover.scaling = 80;
          };
          location = "top";
          transparent = false;
          floating = false;
          # floating = true;
          # transparent = true;
        };
        font = {
          name = "JetBrainsMono Nerd Font";
          size = "1.1rem";
        };
        wallpaper = {
          enable = false;
          pywal = false;
          # image = "/home/maike/.current-wallpaper";
          image = WALLPAPER;
          # image = "~/.config/nixos/ressources/wallpapers/1359465.png";
          # image = "/home/maike/.config/nixos/ressources/wallpapers/1359465.png";
          # image = "${config.stylix.image}"; #use stylix image as wallpaper and source for matugen
          # image = "~/.config/nixos/ressources/wallpapers/1359465.png";
        };
        osd.scaling = 80;
        tooltip.scaling = 80;
        notification.scaling = 80;
        matugen = false;
        matugen_settings = {
          mode = "dark";
          scheme_type = "tonal-spot";
          contrast = 0; # -1 -> 1
          # variation = "standard_1";
          variation = "standard_2";
          # variation = "vivid_1";
        };
        menus = {
          dashboard = {
            directories = {
              enabled = true;
              left = {
                directory1.command = ''bash -c "xdg-open $HOME/Downloads/"'';
                directory1.label = "󰉍 Downloads";
                directory2.command = ''bash -c "xdg-open $HOME/Videos/"'';
                directory2.label = "󰉏 Videos";
                directory3.command = ''bash -c "xdg-open $HOME/Projects/"'';
                directory3.label = "󰚝 Projects";
              };
              right = {
                directory1.command = ''bash -c "xdg-open $HOME/Documents/"'';
                directory1.label = "󱧶 Documents";
                directory2.command = ''bash -c "xdg-open $HOME/Pictures/"'';
                directory2.label = "󰉏 Pictures";
                directory3.label = "󱂵 Home";
                directory3.command = ''bash -c "xdg-open $HOME/"'';
              };
            };
            shortcuts = {
              enabled = true;
              right.shortcut1.command = "gcolor3";
            };
            controls.enabled = true;
            stats.enable_gpu = false;
            powermenu.avatar.image = "~/.config/nixos/ressources/wallpapers/375567.png";
          };
        };
        media.displayTime = true;
        power.lowBatteryNotification = true;
      };
    };
  };
}
