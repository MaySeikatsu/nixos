{
  pkgs,
  lib,
  ...
}: {
  programs.lazygit = {
    enable = true; #after enabling via hm it's possible for stylix to change theme
    settings = {
      # See https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md for documentation.
      git.overrideGpg = true;
    #   # Syntax-highlighted, word-level diffs
      git.pager = {
        colorArg = "always";
        pager = "${lib.getExe pkgs.delta} --paging=never";
      };
      gui = {
        nerdFontsVersion = "3"; # file/branch icons (nerd fonts already present)
        border = "rounded";
        showRandomTip = false;
      };
      update.method = "never"; # nix owns the binary
      disableStartupPopups = true;
      # No "press enter to return" after editing a file from lazygit
      promptToReturnFromSubprocess = false;
      os.editPreset = "nvim";
    };
  };
}
