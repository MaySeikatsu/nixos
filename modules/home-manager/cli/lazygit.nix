{...}: {
  programs.lazygit = {
    enable = true; #after enabling via hm it's possible for stylix to change theme
    settings = {
      # See https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md for documentation.
    };
  };
}
