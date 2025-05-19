{
  pkgs,
  config,
  host,
  username,
  options,
  lib,
  inputs,
  system,
  ...
}: 
{
  stylix.enable = true;
  stylix.autoEnable = false; #set false to manually declare applications in hm module.
  # stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
  # stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
  # stylix.homeManagerIntegration.followSystem = true;
  stylix = {
      targets = {
          # gtk.enable = true;
          # qt.enable = true;
          nixos-icons.enable = true;
          #kitty.enable = true;
          # ghostty.enable = true;
          #wezterm.enable = true;
      };
  };
  stylix.image = ../../../ressources/wallpapers/Anime/1359466.png;
  # stylix.wallpaper = ../../../ressources/wallpapers/1313919.jpg;
  stylix.polarity = "dark";
  stylix.opacity = {
    applications = 1.0;
    terminal = 0.85;
    desktop = 1.0;
    popups = 1.0;
  };
  stylix = {
    # fonts = {
    #   sizes = {
    #     terminal = 11;
    #     applications = 11;
    #     popups = 11;
    #   };
    #
    #   serif = {
    #     name = "CaskaydiaCove Nerd Font";
    #     package = pkgs.nerd-fonts.caskaydia-cove;
    #   };
    #
    #   sansSerif = {
    #     name = "CaskaydiaCove Nerd Font";
    #     package = pkgs. nerd-fonts.caskaydia-cove;
    #   };
    #
    #   monospace = {
    #     package = pkgs. nerd-fonts.caskaydia-cove;
    #     name = "CaskaydiaCove Nerd Font";
    #   };
    #
    #   emoji = {
    #     package = pkgs.noto-fonts-emoji;
    #     name = "Noto Color Emoji";
    #   };
    # };
  };
}
