{ config, inputs, pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    # show_hidden = false;
    # theme = {
    #
    # };
    
  };
}
