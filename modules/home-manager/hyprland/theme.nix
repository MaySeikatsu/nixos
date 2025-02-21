{...}:
{
  wayland.windowManager.hyprland.settings = {
    exec = [
    #   "exec = gsettings set org.gnome.desktop.interface icon-theme 'Tela-circle-dracula'"
    #   "exec = gsettings set org.gnome.desktop.interface gtk-theme 'rose-pine-moon'"
      "exec = gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'"
    ];

    general = {
      gaps_in = 5;
      gaps_out = 10;
      border_size = 2;
      "col.active_border" = "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
      "col.inactive_border" = "rgba(b4befecc) rgba(6c7086cc) 45deg";
      layout = "dwindle";
      resize_on_border = true;
      # allow_tearing = true;
    };

    group = {
      "col.border_active" = "rgb(ebdbb2) rgb(d65d0e) 60deg";
      "col.border_inactive" = "rgb(272727)";
      "col.border_locked_active" = "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
      "col.border_locked_inactive" = "rgba(b4befecc) rgba(6c7086cc) 45deg";
    };

    decoration = {
      rounding = 10;
      active_opacity = 1.0;
      inactive_opacity = 1.0;

      blur = {
        enabled = true;
        size = 3;
        passes = 1;
        # vibrancy = 0.1696;
        new_optimizations = true;
        ignore_opacity = true;
        xray = false;
      };

      shadow = {
        enabled = true;
        # range = 4;
        # render_power = 3;
        # color = rgba(1a1a1aee);
      };

    };
  };
}
