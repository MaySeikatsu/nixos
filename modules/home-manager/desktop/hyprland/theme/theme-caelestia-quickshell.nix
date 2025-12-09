{...}:
{
  wayland.windowManager.hyprland.settings = {
    exec = [
    #   "exec = gsettings set org.gnome.desktop.interface icon-theme 'Tela-circle-dracula'"
    #   "exec = gsettings set org.gnome.desktop.interface gtk-theme 'rose-pine-moon'"
      "exec = gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'"
    ];

    general = {
      # gaps_in = 8;
      gaps_in = 2;
      gaps_out = 4;
      border_size = 0;
      # "col.active_border" = "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
      # "col.inactive_border" = "rgba(00000000)";
      layout = "dwindle";
      resize_on_border = true;
      # allow_tearing = true;
      snap = {
        enabled = true;
      };
    };

    # Colors are commented out for stylix theming
    # group = {
    #   "col.border_active" = "rgb(ebdbb2) rgb(d65d0e) 60deg";
    #   "col.border_inactive" = "rgb(272727)";
    #   "col.border_locked_active" = "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
    #   "col.border_locked_inactive" = "rgba(b4befecc) rgba(6c7086cc) 45deg";
    # };

    decoration = {
      # rounding = 24;
      rounding = 25;
      # rounding_power = 7.0; #4.0 is a squircle
      active_opacity = 1.0;
      inactive_opacity = 0.94;
      dim_special = 0.20;
      dim_around = 0.60;
      border_part_of_window = true;

      blur = {
        enabled = true;
        special = true; # Blurs spexial workspace
        new_optimizations = true;
        size = 2;
        passes = 6;
        xray = false;

        noise = 0.0117;
        vibrancy = 0.7696;
        # vibrancy_darkness = 0.9;
        contrast = 0.97;
        brightness = 1;
        popups = true;
        # ignore_opacity = true;
      };

      shadow = {
        enabled = true;
        # range = 18;
        # range = 10;
        range = 14;
        # range = 8;
        # render_power = 3;
        render_power = 2;
        color = "rgba(00000034)";
      };
    };
  };
}
