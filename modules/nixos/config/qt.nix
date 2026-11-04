{...}: {
  qt = {
    enable = true;
    # No platform theme or style here: they would beat qt6ct. The systemd user environment sets
    # QT_QPA_PLATFORMTHEME=qt6ct (modules/home-manager/theming/qt.nix).
    # platformTheme = "qtct";
    # style.name = "kvantum";
  };
}
