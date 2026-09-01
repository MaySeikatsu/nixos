{pkgs, ...}: {
  # Compositor itself is enabled at the NixOS level (programs.mango.enable,
  # see modules/nixos/config/mangowm.nix) so it gets a session entry and the
  # right xdg-portal wiring. This module only manages the user config.
  home.file.".config/mango/config.conf".source =
    ../../../ressources/dots/mango/config.conf;
  home.file.".config/mango/input.conf".source =
    ../../../ressources/dots/mango/input.conf;
  home.file.".config/mango/monitors.conf".source =
    ../../../ressources/dots/mango/monitors.conf;
  home.file.".config/mango/autostart.conf".source =
    ../../../ressources/dots/mango/autostart.conf;
  home.file.".config/mango/binds.conf".source =
    ../../../ressources/dots/mango/binds.conf;
  home.file.".config/mango/rules.conf".source =
    ../../../ressources/dots/mango/rules.conf;

  # XDG_SESSION_DESKTOP/XDG_CURRENT_DESKTOP are intentionally not pinned here:
  # they'd statically conflict with niri's home-manager module (both are always
  # active for this user), and GDM already sets them correctly per-session from
  # the wayland-sessions/mango.desktop DesktopNames field.
  home.packages = with pkgs; [
    qt6.qtwayland
    grim
    slurp
    brightnessctl
    playerctl
  ];
}
