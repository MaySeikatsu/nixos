{...}: {
  services = {
    # Tuigreet
    # greetd = {
    #   enable = true;
    #   settings = {
    #       default_session = {
    #           command= "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri";
    #           user = "greeter";
    #         };
    #     };
    # };

    # Gysc-greet - needs flake installed
    sysc-greet = {
      enable = true;
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
