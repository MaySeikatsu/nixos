{ inputs, pkgs, ... }: {
  imports = [
    inputs.niri.homeModules.niri
    # ./settings.nix
    # ./binds.nix
    # ./rules.nix
    # ./output.nix
  ];

  home = {
    file.".config/niri/config.kdl".source =
      ../../../ressources/dots/niri/config.kdl;
    packages = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      # gnome-keyring
      xwayland-satellite
      qt6.qtwayland
      # plasma-polkit-agent # check if needed
      walker
      mako # notification agent
      # seatd
      # jaq
      # brillo
      # wl-clip-persist
      # cliphist
      # wl-clipboard
      # gnome-control-center
      # catppuccin-cursors.mochaGreen
    ];
    sessionVariables = {
      #      QT_QPA_PLATFORMTHEME = "kvantum";
      # QT_STYLE_OVERRIDE = "kvantum";
      XDG_SESSION_TYPE = "wayland";
    };
  };
}
