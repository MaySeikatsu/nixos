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
          # name = "${HOSTNAME}";
          email = "maynoshinseikatsu@gmail.com";
        };
      };
    };
  };
}
