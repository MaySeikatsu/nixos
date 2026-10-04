{pkgs, ...}: {
  wayland.windowManager.hyprland.enable = true;
  # HM switched the default to Lua configs for stateVersion >= 26.05; all
  # settings here are written for hyprlang
  wayland.windowManager.hyprland.configType = "hyprlang";
  # home.sessionVariables.NIXOS_OZONE_WL = "1";
  imports = [
    ./animations.nix
    ./autostart.nix
    ./bind.nix
    ./env.nix
    ./monitor.nix
    ./nvidia.nix
    ./programs.nix
    ./theme-loader.nix
    # ./windowrules.nix #now under theme
    ./keyboard.nix
    ./workspace.nix
    ./misc.nix
  ];

  home.packages = with pkgs; [
    # hyprland
    # hyprpaper
    # hyprpicker
    hypridle
    # ironbar
    # polybar
    hyprlock
    # swaylock
    hyprshot
    # hyprpanel
    rofi
    # waybar
    # waypaper # wallpaper frontend gui for hyprpaper and swww
    # matugen # theme engine to create color palets for the system (like pywall)

    wl-clipboard # clipboard manager
    clipse # clipboard manager
    brightnessctl # allows to control brightness
    playerctl # allows for video/audio playback control
    # swww #flake imported seperately
  ];
}
