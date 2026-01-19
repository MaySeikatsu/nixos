{...}: {
  home.sessionVariables = {
    # HOSTNAME = "${config.networking.hostName}";
  };

  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user = {
          name = "maike";
          # email = "maynoshinseikatsu@gmail.com";
        };
        config = {
          push = {autoSetupRemote = true;};
        };
        # extraConfig = {
        #   init.defaultBranch = "main";
        # };
      };
    };
  };
}
