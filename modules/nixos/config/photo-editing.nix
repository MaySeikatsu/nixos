# Photo / RAW editing. Toggle: my.photoEditing.enable (modules/nixos/profiles.nix)
#
# Nikon ZR NEFs (lossless compressed, 2026-10): RapidRaw and RawTherapee
# open them; darktable 5.6's RawSpeed doesn't know the camera yet.
# DaVinci Resolve 21 (videoEditing toggle) also has a free Photo page with
# Nikon RAW support.
{
  config,
  lib,
  pkgs,
  ...
}: let
  # Nikon NX Studio (Windows) through Proton, without Lutris. The program is
  # installed into the prefix once (it already is, from the earlier Lutris
  # setup: ~/Games/nx-studio, NX Studio 1.10.1, GE-Proton10-33, win11).
  # umu-run supplies the Steam runtime that Proton needs on NixOS. Prefer the
  # GE-Proton the prefix was made with; otherwise umu fetches the latest
  # GE-Proton itself.
  nxStudio = pkgs.writeShellScriptBin "nx-studio" ''
    export WINEPREFIX="''${NX_STUDIO_PREFIX:-$HOME/Games/nx-studio}"
    if [ -z "''${PROTONPATH-}" ]; then
      ge="$HOME/.steam/root/compatibilitytools.d/GE-Proton10-33"
      if [ -d "$ge" ]; then export PROTONPATH="$ge"; else export PROTONPATH=GE-Proton; fi
    fi
    export GAMEID=umu-nxstudio
    exe="$WINEPREFIX/drive_c/Program Files/Nikon/NXStudio/NXStudio.exe"
    if [ ! -f "$exe" ]; then
      echo "NX Studio isn't installed in $WINEPREFIX." >&2
      echo "Install: WINEPREFIX=$WINEPREFIX umu-run S-NXSTDO-...exe" >&2
      exit 1
    fi
    cd "$(dirname "$exe")"
    exec ${lib.getExe pkgs.umu-launcher} ./NXStudio.exe "$@"
  '';
  nxStudioDesktop = pkgs.makeDesktopItem {
    name = "nx-studio";
    desktopName = "NX Studio";
    comment = "Nikon RAW viewer/editor (Windows, via Proton)";
    exec = "nx-studio";
    categories = ["Graphics" "Photography"];
  };
in {
  config = lib.mkIf config.my.photoEditing.enable {
    environment.systemPackages = with pkgs; [
      rapidraw # Lightroom-like, GPU accelerated (wgpu/Vulkan)
      darktable # like lightroom
      rawtherapee
      gimp-with-plugins
      umu-launcher # Proton + Steam runtime for non-Steam Windows apps
      nxStudio
      nxStudioDesktop
    ];
  };
}
