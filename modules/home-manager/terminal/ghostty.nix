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
        # theme = "Adventure";
        theme = "rose-pine-moon";
        # theme = "/home/maike/.config/ghostty/matugen.theme"; #theme path and folder needs to be created first ls -l /home/maike/.config/ghostty/themes/matugen.theme
        # background =000000;
        # background-opacity = 0.85;
        # background-opacity = 0.25;
        background-blur = 4;
      };
    };
  };
}
