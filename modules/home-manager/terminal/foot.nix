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
          # The font is the Nix one whichever way the theming switch is set. The colours are stylix's (switch off) or
          # kurashi's (on, desktop/kurashi.nix themeExport). The stale theme.ini include is gone.
          font = "JetBrains Mono Nerd Font:size=12";
        };
        # colors.alpha = 0.7;
        # colors.alpha-mode = "all";
      };
    };
  };
}
