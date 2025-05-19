{pkgs, inputs, lib, config, ...}:
{
  # needs to be enabled as a homemanager module to work (look at imported files in this folder)

  # stylix.image = ../../../ressources/wallpapers/1309758.jpg;
  # stylix.image = "/home/maike/.config/nixos/ressources/wallpapers/1235167.jpg";
  stylix.targets = {
    wezterm.enable = true;
    alacritty.enable = true;
    kitty.enable = true;
    ghostty.enable = true;
    yazi.enable = true;
    neovim.enable = true;
    btop.enable = true;
    cava.enable = true;
    cava.rainbow.enable = true;
    nixcord.enable = true;
    vencord.enable = true;
    vesktop.enable = true;
    fzf.enable = true;
    gnome.enable = true;
    hyprland.enable = true;
    # hyprland.hyprpaper.enable = true;
    hyprlock.enable = true;
    hyprpaper.enable = true;
    # kde.enable = true;
    lazygit.enable = true;
    # neovim.transparentBackground.main = true;
    neovim.transparentBackground.numberLine = true;
    neovim.transparentBackground.signColumn= true;
    rofi.enable = true;
    # spicetify.enable = true; #not working as imported via nixos
    starship.enable = false;
    tmux.enable = true;
    wayfire.enable = false;
    # grub.enable = false;
    # grub.useWallpaper = true;
    gtk.enable = true;
    qt.enable = true;
    # chromium.enable = true;
    # feh.enable = true;
    zellij.enable = true;
    zathura.enable = true;
    # waybar = {
    #   enable = true;
    #   enableCenterBackColors = false;
    #   enableLeftBackColors = false;
    #   enableRightBackColors = false;
    #   # font = "JetBrainsMono";
    # };
    # firefox = {
    #   enable = true;
    #   profileNames = []; #necessary
    #   colorTheme.enable = true;
    #   firefoxGnomeTheme.enable = false;
    # };
    floorp = {
      enable = true;
      profileNames = [ "default" ]; #necessary
      colorTheme.enable = true;
      firefoxGnomeTheme.enable = false;
    };

  };
}
