{
  config,
  inputs,
  pkgs,
  ...
}: {
  programs = {
    foot = {
      enable = true;
      settings = {
        main = {
          selection-target = "both";
          include = "~/.config/foot/theme.ini";
        };
        # colors.alpha = 0.7;
        # colors.alpha-mode = "all";
      };
    };
  };
}
