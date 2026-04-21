{...}: {
  imports = [
    ./hyprland/default.nix
    ./hyprland_utils/default.nix
    ./niri/default.nix

    ./gnome.nix
    ./qs-caelestia.nix
    ./rofi.nix
    ./wofi.nix
    ./mime.nix
    # ./noctalia.nix
    # ./walker.nix
    ./sherlock-launcher.nix
    # ./ironbar.nix
  ];
  wayland.windowManager = {
    wayfire = {
      enable = false;
      # plugins = [
      #   pkgs.wcm
      # ];
    };
  };

}
