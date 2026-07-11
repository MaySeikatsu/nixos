{pkgs, ...}: {
  programs.yazi = {
    enable = true;
    shellWrapperName = "y";
    enableZshIntegration = true;
    enableNushellIntegration = true;
    enableFishIntegration = true;
    # Preview toolchain - without these, PDF/video/many-archive previews are
    # just blank. Scoped to yazi's own PATH rather than installed globally.
    extraPackages = with pkgs; [
      ffmpegthumbnailer # video thumbnails
      poppler-utils # PDF thumbnails (pdftoppm)
      chafa # image preview fallback for terminals without Kitty/iTerm graphics
      unar # broader archive preview support (rar, etc.) beyond 7z
      imagemagick
      file
    ];
    # show_hidden = false;
    # theme = {
    #
    # };
  };
}
