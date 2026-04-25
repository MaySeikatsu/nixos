{...}: {
  programs.yazi = {
    enable = true;
    shellWrapperName = "y";
    enableZshIntegration = true;
    enableNushellIntegration = true;
    enableFishIntegration = true;
    # show_hidden = false;
    # theme = {
    #
    # };
  };
}
