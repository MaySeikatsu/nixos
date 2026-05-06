{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    # inputs.niri.homeModules.niri
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

    file.".config/niri/style_focus.kdl".source =
      ../../../../ressources/dots/niri/style_focus.kdl;

    packages = with pkgs; [
      qt6.qtwayland
      xwayland-satellite
      # pipewire
      # wireplumber
      # xdg-desktop-portal
      # xdg-desktop-portal-gnome
      # gnome-keyring
      # plasma-polkit-agent # check if needed
      # mako # notification agent
    ];
    sessionVariables = {
      # QT_QPA_PLATFORMTHEME = "kvantum";
      # QT_STYLE_OVERRIDE = "kvantum";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "niri";
      XDG_CURRENT_DESKTOP = "niri";
    };
  };
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.niri = {
      default                                   = [ "gtk" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      "org.freedesktop.impl.portal.OpenURI"     = [ "gtk" ];
      "org.freedesktop.impl.portal.AppChooser"  = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast"  = [ "wlr" ];
      "org.freedesktop.impl.portal.Screenshot"  = [ "wlr" ];
      "org.freedesktop.impl.portal.Secret"      = [ "gnome-keyring" ];
    };
  };
}
