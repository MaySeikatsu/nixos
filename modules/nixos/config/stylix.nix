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
          gtk.enable = true;
          qt.enable = true;
          nixos-icons.enable = true;
          #kitty.enable = true;
          # ghostty.enable = true;
          #wezterm.enable = true;
      };
  };
  stylix.image = ../../../ressources/wallpapers/1359465.png;
  stylix.polarity = "dark";
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
