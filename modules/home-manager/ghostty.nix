{ config, inputs, pkgs, ... }:
{
  programs = {
    ghostty = {
      enable = true;
      settings = {
        font-size = 11;
        window-decoration = false;
        confirm-close-surface = false;
        font-feature = ["-liga" "-dlig" "-calt"];
        theme = "Adventure";
        # theme = "rose-pine-moon";
        # background =000000;
        background-opacity = 0.8;
        background-blur = 4;
      };
    };
  };
}
