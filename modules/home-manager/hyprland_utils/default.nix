{ config, pkgs, lib, ... }:{
  imports = [
    ./hyprlock.nix
    ./swaylock.nix

    ./hypridle.nix
    ./waybar.nix
    ./swww.nix
    
    ./hyprpaper.nix
    # ./hyprpanel.nix
  ];
}
