{
  lib,
  osConfig,
  ...
}: let
  kurashiOn = lib.attrByPath ["my" "kurashi-theming" "enable"] false osConfig;
in {
  programs = {
    ghostty = {
      enable = true;
      settings = {
        font-size = 11;
        # Set here, not only by stylix, so the font stays when the theming switch hands the colours to kurashi.
        font-family = "JetBrains Mono Nerd Font";
        window-decoration = false;
        confirm-close-surface = false;
        font-feature = ["-liga" "-dlig" "-calt"];
        # theme = "Adventure";
        # theme = "rose-pine-moon";
        # Only while kurashi does not style ghostty. Its theme file names its own shader and sets custom-shader-animation = false.
        # ghostty keeps the theme's custom-shader entry and runs these after it, so they would filter kurashi's material.
        custom-shader = lib.mkIf (!kurashiOn) [
          "~/.config/nixos/ressources/dots/ghostty/shaders/in-game-crt-cursor.glsl"
          # "~/.config/nixos/ressources/dots/ghostty/shaders/glow-rgbsplit-twitchy.glsl"
          # "~/.config/nixos/ressources/dots/ghostty/shaders/retro-terminal.glsl"
          "~/.config/nixos/ressources/dots/ghostty/shaders/bloom.glsl"
        ];

        # theme = "/home/maike/.config/ghostty/matugen.theme"; #theme path and folder needs to be created first ls -l /home/maike/.config/ghostty/themes/matugen.theme
        # background =000000;
        # background-opacity = 0.85;
        # background-opacity = 0.25;
        background-blur = 4;
      };
    };
  };
}
