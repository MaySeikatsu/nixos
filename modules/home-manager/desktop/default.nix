{ ... }: {
  imports = [
    ./hyprland/default.nix
    ./hyprland_utils/default.nix
    ./niri/default.nix

    ./gnome.nix
    ./qs-caelestia.nix
    ./rofi.nix
    ./wofi.nix
    ./sherlock-launcher.nix
    # ./ironbar.nix
  ];
}
