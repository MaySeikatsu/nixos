{pkgs, ...}: {
  #Stylix Setup for NIXOS Modules (also loads hm targets)
  config = {
    # usually just stylix but config part is needed as we're using options above
    stylix = {
      enable = true;
      autoEnable = false;
      # image = ../../../ressources/wallpapers/Anime/anime-girl-aesthetic-autumn-wallpaper-4k.jpg;
      image = ../../../ressources/wallpapers/Anime/anime-girl-pink-eyes-city-desktop-wallpaper.jpg;
      polarity = "dark"; # options: light, dark, either (selects closest)
      # base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine-moon.yaml";
      # base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
      # homeManagerIntegration.followSystem = true;

      opacity = {
        applications = 1.0;
        # terminal = 0.30;
        # terminal = 0.50;
        # terminal = 0.7; # hyprland good
        # terminal = 0.85; # hyprland niri good
        terminal = 0.96; # niri
        # terminal = 1.0; # niri
        desktop = 0.99;
        popups = 0.95;
      };

      targets = {
        gtk.enable = true;
        # qt.enable = true;
        nixos-icons.enable = true;
        spicetify.enable = false;
      };
      fonts = {
        sizes = {
          # terminal = 14; #was 11 on all
          terminal = 12; #was 11 on all
          applications = 14;
          popups = 14;
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
