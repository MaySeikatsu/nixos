{inputs, pkgs, ...}:{
  
  # use this if not already defined in flake
  # imports = [
  #   inputs.sherlock.homeManagerModules.default
  # ];
  # programs.sherlock.settings = null; # set this if settings should not be symlinked to nix store
  programs.sherlock = {
    enable = true;
    settings = {
      aliases = {
        vesktop = {
          name = "Discord";
        };
      };
      launchers = [
        {
          name = "App Launcher";
          alias = "app";
          type = "app_launcher";
          args = {};
          priority = 1;
          home = true;
        }
        {
          name = "Web Search";
          display_name = "Web Search";
          tag_start = "{keyword}";
          tag_end = "{keyword}";
          alias = "gg";
          type = "web_launcher";
          args = {
              "search_engine" = "ecosia";
              "icon" = "ecosia";
          };
          priority = 10;
        }
      ];
      config = {
        # appearance = {
        #   icon_size = 22;
        #   opacity = 0.9;
        #   # gsk_renderer = "ngl"; #default is cairo
        # };
        units = {
          lengths = "meter";
        };

      # style = null

      # debug = {
      #     try_suppress_warnings = true;
      #   };
      };
      # ignore = ''
      #   Avahi*
      # '';
    };
  };
}
