{ config, inputs, pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
    # show_hidden = false;
    # theme = {
    #
    # };
    
  };
}
