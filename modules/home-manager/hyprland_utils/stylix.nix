{pkgs, inputs, ...}:
{
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
    # cava.enable = true;
    cava.rainbow.enable = true;
    nixcord.enable = true;
    vencord.enable = true;
    vesktop.enable = true;
    fzf.enable = true;
    gnome.enable = true;
    hyprland.enable = true;
    # hyprland.hyprpaper.enable = true;
    # hyprlock.enable = true;
    hyprpaper.enable = true;
    kde.enable = true;
    lazygit.enable = true;
    # neovim.transparentBackground.main = true;
    neovim.transparentBackground.numberLine = true;
    neovim.transparentBackground.signColumn= true;
    rofi.enable = true;
    spicetify.enable = true;
    starship.enable = false;
    tmux.enable = true;
    wayfire.enable = false;
    # grub.enable = false;
  };
}
