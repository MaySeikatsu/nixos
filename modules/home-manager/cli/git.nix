{...}: {
  home.sessionVariables = {
    # HOSTNAME = "${config.networking.hostName}";
  };

  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      signing.format = null;
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
