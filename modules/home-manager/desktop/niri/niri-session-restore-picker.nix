# Installs niri-session-restore-picker (../../../../niri-session-restore-picker),
# a standalone script that lets you pick which saved workspaces to restore
# instead of blindly running `niri-session-manage --load-last` on every
# niri startup. Bound to Mod+Shift+R (ressources/dots/niri/binds.kdl),
# opened as a floating terminal (window-rule in
# ressources/dots/niri/config.kdl).
#
# Depends on `niri-session-manage` being on PATH, which the sibling
# [[niri-session-restore.nix]] module already provides.
{pkgs, ...}: {
  home.packages = [
    (pkgs.callPackage ../../../../niri-session-restore-picker/package.nix {})
  ];
}
