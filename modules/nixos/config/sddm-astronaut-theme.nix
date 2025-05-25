{pkgs, config, ...}:
{
    # sddm-astronaut-theme
    services.displayManager.sddm = {
      enable = true;
      theme = "sddm-astronaut-theme"; # Must match package name
      # settings = {
      #   General = {
      #     HeaderText = "Hi";
      #     Background = "/etc/nixos/ressources/wallpapers/1359465.png";
      #   };
      # };
      extraPackages = with pkgs; [
        kdePackages.qtmultimedia
        kdePackages.qtsvg
        kdePackages.qtvirtualkeyboard
      ];
    };

  environment.systemPackages = with pkgs; [ #would be pkgs.packagename without the with pkgs;
      (pkgs.callPackage ../../../ressources/sddm-astronaut-theme {
        # theme = "hyprland_kath";
        theme = "black_hole";
        # theme = "japanese_aesthetic";
        # theme = "astronaut";
        # theme = "purple_leaves";
        # theme = "pixel_sakura(-static)";
        themeConfig = {
          General = {
            HeaderText = "Hi Bitch!";
            # Background = "/home/maike/.config/nixos/ressources/wallpapers/1359465.png";
            Background = "${config.stylix.image}";
            FullBlur = "false";
          };
          Colors = {
            HeaderTextColor = config.lib.stylix.colors.base05;
            # DateTextColor = config.lib.stylix.colors.base0A;
            # TimeTextColor = config.lib.stylix.colors.base0B;
            #
            # FormBackgroundColor = config.lib.stylix.colors.base01;
            BackgroundColor = "#fde086";
            DimBackgroundColor = "#fde086";
            #
            LoginFieldBackgroundColor = "#fde086";
            PasswordFieldBackgroundColor = "#fde086";
            # LoginFieldTextColor = config.lib.stylix.colors.base05;
            # PasswordFieldTextColor = config.lib.stylix.colors.base05;
            # UserIconColor = config.lib.stylix.colors.base0C;
            # PasswordIconColor = config.lib.stylix.colors.base0C;
            #
            # PlaceholderTextColor = config.lib.stylix.colors.base03;
            # WarningColor = config.lib.stylix.colors.base08;
            #
            # LoginButtonTextColor = config.lib.stylix.colors.base07;
            # # LoginButtonBackgroundColor = config.lib.stylix.colors.accent;
            # SystemButtonsIconsColor = config.lib.stylix.colors.base0C;
            # SessionButtonTextColor = config.lib.stylix.colors.base0C;
            # VirtualKeyboardButtonTextColor = config.lib.stylix.colors.base0C;
            #
            # DropdownTextColor = config.lib.stylix.colors.base07;
            # # DropdownSelectedBackgroundColor = config.lib.stylix.colors.accent;
            # DropdownBackgroundColor = config.lib.stylix.colors.base01;
            #
            # HighlightTextColor = config.lib.stylix.colors.base01;
            HighlightBackgroundColor = "#fde086";
            # HighlightBorderColor = config.lib.stylix.colors.accent;
            #
            # HoverUserIconColor = config.lib.stylix.colors.accent;
            # HoverPasswordIconColor = config.lib.stylix.colors.accent;
            # HoverSystemButtonsIconsColor = config.lib.stylix.colors.accent;
            # HoverSessionButtonTextColor = config.lib.stylix.colors.accent;
            # HoverVirtualKeyboardButtonTextColor = config.lib.stylix.colors.accent;
          };   
        };
     })
  ];
}
