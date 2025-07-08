{...}:
{
  wayland.windowManager.hyprland.settings = {
    exec = [
      "exec = gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'"
    ];

    general = {
      gaps_in = 2;
      gaps_out = 4;
      border_size = 0;
      layout = "dwindle";
      resize_on_border = true;
      snap = {
        enabled = true;
      };
    };

    # Colors are commented out for stylix theming
    # group = {
    #   "col.border_active" = "rgb(ebdbb2) rgb(d65d0e) 60deg";
    # "col.border_inactive" = "rgb(272727)";
    #   "col.border_locked_active" = "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
    #   "col.border_locked_inactive" = "rgba(b4befecc) rgba(6c7086cc) 45deg";
    # };

    decoration = {
      rounding = 0;
      # rounding_power = 7.0; #4.0 is a squircle
      active_opacity = 1.0;

      blur = {
        enabled = false;
        special = false; # Blurs spexial workspace
        new_optimizations = true;
        size = 1;
        passes = 1;
        xray = false;

        contrast = 0.97;
        brightness = 1;
        popups = true;
        # ignore_opacity = true;
      };

      shadow = {
        enabled = false;
        range = 14;
        render_power = 1;
        color = "rgba(00000034)";
      };
    };
  };
}
