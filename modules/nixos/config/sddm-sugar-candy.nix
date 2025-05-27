{ lib, config, pkgs, ... }:
# Documentation: https://github.com/Zhaith-Izaliel/sddm-sugar-candy-nix
{
  services.displayManager.sddm = {
    enable = true; # Enable SDDM.
    sugarCandyNix = {
      enable = true; # This set SDDM's theme to "sddm-sugar-candy-nix".
      settings = {
        # Set your configuration options here.
        # Here is a simple example:
        # Background = lib.cleanSource ./background.png;
        Background = "${config.stylix.image}";
        ScreenWidth = 1920;
        ScreenHeight = 1080;
        FormPosition = "left";
        HaveFormBackground = true;
        PartialBlur = true;
        # ...
      };
    };
      # extraPackages = with pkgs; [
      # kdePackages.qtmultimedia
      # kdePackages.qtsvg
      # kdePackages.qtvirtualkeyboard
    ];
  };
}
