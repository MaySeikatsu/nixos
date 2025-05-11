{ config, pkgs, inputs, lib, ... }:
{
  environment.systemPackages = with pkgs; [

    hyprland
    hyprpaper
    hyprpicker
    hypridle
      hyprlock
      swaylock
    hyprshot
    hyprpanel
    rofi
    waybar
    waypaper #wallpaper frontend gui for hyprpaper and swww
    matugen #theme engine to create color palets for the system (like pywall)

    wl-clipboard #clipboard manager
    clipse #clipboard manager
    playerctl #allows for video/audio playback control
    # swww #flake imported seperately
  ];
}
