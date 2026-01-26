{...}: {
  # programs.sherlock.settings = null; # set this if settings should not be symlinked to nix store
  programs.sherlock = {
    enable = true;
    systemd.enable = true;
    settings = {
      aliases = {vesktop = {name = "Discord";};};
      launchers = [
        {
          name = "App Launcher";
          alias = "app";
          type = "app_launcher";
          args = {};
          priority = 1;
          home = true;
        }
        # {
        #   name = "Clipboard";
        #   alias = "clip";
        #   type = "clipboard-execution";
        #   args = { };
        #   priority = 2;
        #   home = true;
        # }
        # {
        #   name = "Web Search";
        #   display_name = "Web Search";
        #   tag_start = "{keyword}";
        #   tag_end = "{keyword}";
        #   alias = "gg";
        #   type = "web_launcher";
        #   args = {
        #       "search_engine" = "ecosia";
        #       "icon" = "ecosia";
        #   };
        #   priority = 10;
        # }
      ];
      config = {
        # appearance = {
        #   icon_size = 22;
        #   opacity = 0.9;
        #   # gsk_renderer = "ngl"; #default is cairo
        # };
        # behavior = {
        #   # daemonize = true;
        #   daemonize = false;
        #   caching = true;
        #   cache = "~/.cache/sherlock/sherlock_desktop_cache.json";
        #   # animate = false;
        #   animate = true;
        # };
        # units = {
        #   lengths = "meter";
        # };

        # style = null

        # debug = {
        #     try_suppress_warnings = true;
        #   };
      };
      # ignore = ''
      #   Avahi*
      # '';
    };
    # launchers = [
    #   {
    #     name = "Calculator";
    #     type = "calculation";
    #     args = {
    #       capabilities = [
    #         "calc.math"
    #         "calc.units"
    #       ];
    #     };
    #     priority = 1;
    #   }
    #   {
    #     name = "App Launcher";
    #     type = "app_launcher";
    #     args = {};
    #     priority = 2;
    #     home = "Home";
    #   }
    # ];
  };
}
