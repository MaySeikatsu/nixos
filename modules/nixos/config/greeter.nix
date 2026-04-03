{ config, pkgs,...}: {
  services = {
    # Tuigreet
    # greetd = {
    #   enable = false;
    #   settings = {
    #       default_session = {
    #           command= "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri";
    #     # command = "${pkgs.greetd.tuigreet}/bin/tuigreet --sessions ${config.services.xserver.displayManager.sessionData.desktops}/share/xsessions:${config.services.xserver.displayManager.sessionData.desktops}/share/wayland-sessions --remember --remember-user-session";
    #           user = "greeter";
    #         };
    #     };
    # };
 
    # Gysc-greet - needs flake installed
    sysc-greet = {
      enable = false;
      compositor = "niri"; # or "hyprland" or "sway"
      settings = {
        theme = "TransIsHardJob";
      };

      # Optional: Set initial session for auto-login
      # settings.initial_session = {
      #   command = "niri";
      #   user = "maike";
      # };
    };
  };
}
