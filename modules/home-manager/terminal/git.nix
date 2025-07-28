{ config, inputs, pkgs, ... }:
{
  home.sessionVariables = {
    # HOSTNAME = "${config.networking.hostName}";
  };
  
  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      # userName = "${HOSTNAME}";
      userEmail = "maynoshinseikatsu@gmail.com";
    };
  };
}
