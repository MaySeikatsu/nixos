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
      ../../../../ressources/dots/niri/config.kdl;
    file.".config/niri/binds.kdl".source =
      ../../../../ressources/dots/niri/binds.kdl;
    file.".config/niri/layout.kdl".source =
      ../../../../ressources/dots/niri/layout.kdl;
    file.".config/niri/colors.kdl".source =
      ../../../../ressources/dots/niri/colors.kdl;
    file.".config/niri/init.kdl".source =
      ../../../../ressources/dots/niri/init.kdl;
    file.".config/niri/input.kdl".source =
      ../../../../ressources/dots/niri/input.kdl;
    file.".config/niri/outputs.kdl".source =
      ../../../../ressources/dots/niri/outputs.kdl;
    file.".config/niri/animations.kdl".source =
      ../../../../ressources/dots/niri/animations.kdl;

    packages = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      # gnome-keyring
      xwayland-satellite
      qt6.qtwayland
      # plasma-polkit-agent # check if needed
      walker
      # mako # notification agent
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
