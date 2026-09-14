{pkgs, ...}: {
  # Compositor itself is enabled at the NixOS level (programs.mango.enable,
  # see modules/nixos/config/mangowm.nix) so it gets a session entry and the
  # right xdg-portal wiring. This module only manages the user config.
  #
  # ~/.config/mango/config.conf fully replaces /etc/mango/config.conf (no
  # layering like niri's `include`), and `source=` pulls in the rest. Validate
  # edits before rebuilding with:
  #   mango -c ressources/dots/mango/config.conf -p
  # (it resolves the ~/.config/mango/*.conf sources against the deployed
  # symlinks, so run it after a switch or point -c at the deployed file).
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
    # screenshots (binds.conf): grim captures, slurp selects, wl-copy copies,
    # jq parses `mmsg get focusing-client` for the focused-window shot.
    grim
    slurp
    wl-clipboard
    jq
    brightnessctl
    playerctl
    libnotify # notify-send in scripts/mango_toggle_effects.sh + screenshot binds
  ];
}
