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
    #DOES NOT WORK - put hard values in instead
  #This part is used for hyprpanel configuration with stylix - stolen from: https://github.com/anotherhadi/nixy/blob/main/themes/nixy.nix
  #   options.theme = lib.mkOption {
  #   type = lib.types.attrs;
  #   default = {
  #     rounding = 20;
  #     gaps-in = 10;
  #     gaps-out = 10 * 2;
  #     active-opacity = 0.96;
  #     inactive-opacity = 0.92;
  #     blur = true;
  #     border-size = 3;
  #     animation-speed = "fast"; # "fast" | "medium" | "slow"
  #     fetch = "none"; # "nerdfetch" | "neofetch" | "pfetch" | "none"
  #     textColorOnWallpaper =
  #       config.lib.stylix.colors.base01; # Color of the text displayed on the wallpaper (Lockscreen, display manager, ...)
  #
  #     bar = { # Hyprpanel
  #       position = "top"; # "top" | "bottom"
  #       transparent = true;
  #       transparentButtons = false;
  #       floating = true;
  #     };
  #   };
  #   description = "Theme configuration options";
  # };
  
  #Stylix Setup for NIXOS Modules (also loads hm targets)
  config = { #usually just stylix but config part is needed as we're using options above
    stylix = { 
      enable = true;
      autoEnable = false;
      # image = ../../../ressources/wallpapers/Anime/anime-girl-aesthetic-autumn-wallpaper-4k.jpg;
      image = ../../../ressources/wallpapers/Anime/anime-girl-pink-eyes-city-desktop-wallpaper.jpg;
      polarity = "dark"; # options: light, dark, either (selects closest)
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    # homeManagerIntegration.followSystem = true;

      opacity = {
        applications = 1.0;
        terminal = 0.80;
        desktop = 1.0;
        popups = 1.0;
      };

      targets = {
          # gtk.enable = true;
          # qt.enable = true;
          spicetify.enable = true; #not working as imported via nixos
          nixos-icons.enable = true;
          # spicetify.enable = true;
      };
      fonts = {
      sizes = {
      terminal = 11;
      applications = 11;
      popups = 11;
      };
      #
      serif = {
      #     name = "CaskaydiaCove Nerd Font";
      #     package = pkgs.nerd-fonts.caskaydia-cove;
            package = pkgs.nerd-fonts.jetbrains-mono;
            name = "JetBrains Mono Nerd Font";
      };
      #
      sansSerif = {
      #     name = "CaskaydiaCove Nerd Font";
      #     package = pkgs. nerd-fonts.caskaydia-cove;
            package = pkgs.nerd-fonts.jetbrains-mono;
            name = "JetBrains Mono Nerd Font";
      };
      #
      monospace = {
      #     package = pkgs. nerd-fonts.caskaydia-cove;
      #     name = "CaskaydiaCove Nerd Font";
            package = pkgs.nerd-fonts.jetbrains-mono;
            name = "JetBrains Mono Nerd Font";

         # emoji = {
         #   package = pkgs.noto-fonts-emoji;
         #   name = "Noto Color Emoji";
         # };
      };
    };
    
      # making your own theme
      # See https://tinted-theming.github.io/tinted-gallery/ for more schemes
      # base16Scheme = {
      #   base00 = "09090B"; # Default Background
      #   base01 =
      #     "1c1e1f"; # Lighter Background (Used for status bars, line number and folding marks)
      #   base02 = "313244"; # Selection Background
      #   base03 = "45475a"; # Comments, Invisibles, Line Highlighting
      #   base04 = "585b70"; # Dark Foreground (Used for status bars)
      #   base05 = "cdd6f4"; # Default Foreground, Caret, Delimiters, Operators
      #   base06 = "f5e0dc"; # Light Foreground (Not often used)
      #   base07 = "b4befe"; # Light Background (Not often used)
      #   base08 =
      #     "f38ba8"; # Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
      #   base09 =
      #     "fab387"; # Integers, Boolean, Constants, XML Attributes, Markup Link Url
      #   base0A = "f9e2af"; # Classes, Markup Bold, Search Text Background
      #   base0B = "a6e3a1"; # Strings, Inherited Class, Markup Code, Diff Inserted
      #   base0C =
      #     "94e2d5"; # Support, Regular Expressions, Escape Characters, Markup Quotes
      #   base0D =
      #     "c5afd4"; # Functions, Methods, Attribute IDs, Headings, Accent color
      #   base0E =
      #     "cba6f7"; # Keywords, Storage, Selector, Markup Italic, Diff Changed
      #   base0F =
      #     "f2cdcd"; # Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>
      # };
    };
  };
}
