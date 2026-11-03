# kurashi-shell (~/Projects/kurashi-shell): the desktop shell for niri. kurashid and the Quickshell frontend run as user
# services bound to graphical-session.target, so nothing is spawned from niri/init.kdl. noctalia stays installed
# (noctalia.nix) as a fallback; its spawn line in niri/init.kdl is commented out. Never run both: each owns the
# notification server, the polkit agent and the bar.
#
# The shell always runs. The theming switch (my.kurashi-theming.enable, modules/nixos/profiles.nix) decides whether
# kurashi also styles the other apps: see ../theming/kurashi.nix.
{
  lib,
  osConfig,
  ...
}: let
  on = lib.attrByPath ["my" "kurashi-theming" "enable"] false osConfig;
in {
  programs.kurashi = {
    enable = true;
    systemd.enable = true;
    frontend.enable = true;
    #pointerLight.enable = false;

    # The web dock (K38): a strip of pinned sites at a screen edge, run by qs-webengine. Its default key is Mod+B, which Edge
    # has in niri/binds.kdl; kurashi's binds load after it, so the dock would take that key from Edge. Mod+Alt+B is free.
    webdock = {
      enable = true;
      keybind = "Mod+Alt+B";
    };

    # The apps kurashi styles while the switch is on. The kurashi module adds the include lines of gtk, foot and ghostty.
    themeExport.apps = lib.optionals on ["niri" "foot" "ghostty" "gtk3" "gtk4" "qt" "qt5" "kde" "gsettings"];

    # Shortcuts: Home-Manager writes ~/.config/niri/kurashi-binds.kdl, included after binds.kdl in niri/config.kdl (later binds
    # win). The keys are the ones Settings shows (its keys in ~/.config/kurashi/config.toml). Settings cannot write the file while
    # Nix owns it, so they live here. Mod+R replaces the old shell's launcher bind in binds.kdl. The sidebars are on Mod+Shift+[
    # and Mod+Shift+], so niri's preset sizes on Mod+[ and Mod+] stay. Mod+N stays yours: binds.kdl runs nvim on it.
    niri.binds = {
      enable = true;
      keys = {
        "Mod+R" = "launcher.toggle";
        "Mod+Escape" = "session.lock";
        "Mod+Shift+Escape" = "session.menu";
        "Mod+Shift+BracketLeft" = ''sidebar.toggle {"side":"left"}'';
        "Mod+Shift+BracketRight" = ''sidebar.toggle {"side":"right"}'';
        # Kurashi's defaults that Settings does not use. Quick settings has no key in Settings. The volume and brightness keys
        # and the web dock's Mod+Alt+B stay as they are.
        "Mod+Space" = null;
        "Mod+Shift+E" = null;
        "Super+Alt+L" = null;
        "Mod+Ctrl+P" = null;
        "Mod+Shift+P" = null;
        "Mod+N" = null;
        "Mod+Shift+N" = null;
        "Mod+A" = null;
      };
    };

    # The nix layer (~/.config/kurashi/managed.toml). While the switch is off, enforce makes it forced: Settings shows the
    # export list and the icon theme as set by Home-Manager (locked), so nothing can turn an app on. While it is on, they
    # are defaults you can change. The idle setting is not here any more: it is yours (set in Settings).
    enforce = !on;
    settings.theme = {
      icon_theme = "rose-pine-moon";
      # Off: no app is styled by kurashi.
      export = lib.mkIf (!on) [];
      # On: the Nix default look of the shell (style nix-default, below).
      style = lib.mkIf on "nix-default";
    };
  };

  # The shell's side of the Nix default. Interim: kurashi has no rose-pine-moon palette yet, so this uses its rose-pine
  # (main, dark). When kurashi gets rose-pine-moon, set palette to "rose-pine-moon" (its values: theming/kurashi/palette.nix).
  xdg.configFile."kurashi/styles/nix-default.toml".text = ''
    name = "nix-default"
    label = "Nix default: rose-pine"
    category = "custom"
    # The shell's side of the Nix default (modules/home-manager/theming/kurashi.nix).
    look = "soft"
    palette = "rose-pine"
    [recipe]
    "theme.colors.scheme" = "dark"
    "theme.typography.family" = ["JetBrains Mono Nerd Font", "monospace"]
  '';
}
