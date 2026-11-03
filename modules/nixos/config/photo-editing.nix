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
  # GE-Proton itself. Keep every launcher of this prefix (this script, the
  # Lutris entry) on the SAME version: each switch re-runs Proton's prefix
  # upgrade, which takes minutes here.
  #
  # Stale font paths (2026-10-13): Wine records every fontconfig font in the
  # prefix registry by its /nix/store path (HKCU ...\Fonts\External Fonts and
  # HKLM ...\Windows NT\CurrentVersion\Fonts). After a rebuild those store
  # paths are gone, Wine never removes them, and for each dead path it falls
  # back to a case-insensitive scan of the whole /nix/store (~90k entries).
  # 624 dead entries made every Wine process burn ~1 min of kernel time, so
  # NX Studio took 3+ min to show a window (or gave up). Pruning the dead
  # values before launch brings it to ~12 s; Wine re-adds the current fonts
  # on its own. The prune only touches the two keys, skips values that are
  # not Z:\ unix paths, and is skipped while a wineserver for this prefix is
  # running (the .reg files may only be edited while Wine is down).
  pruneStaleFonts = pkgs.writers.writePython3 "nx-studio-prune-fonts" {flakeIgnore = ["E501"];} ''
    import os
    import re
    import sys

    prefix = os.path.realpath(sys.argv[1])

    # Refuse to edit the registry while a wineserver owns this prefix.
    for pid in os.listdir("/proc"):
        if not pid.isdigit():
            continue
        try:
            with open(f"/proc/{pid}/comm") as f:
                if f.read().strip() != "wineserver":
                    continue
            with open(f"/proc/{pid}/environ", "rb") as f:
                env = f.read().split(b"\0")
        except OSError:
            continue
        for kv in env:
            if kv.startswith(b"WINEPREFIX="):
                if os.path.realpath(kv[11:].decode(errors="replace")) == prefix:
                    print("nx-studio: wineserver running for this prefix, not pruning fonts", file=sys.stderr)
                    sys.exit(0)

    KEYS = {
        "user.reg": ["[Software\\\\Wine\\\\Fonts\\\\External Fonts]"],
        "system.reg": [
            "[Software\\\\Microsoft\\\\Windows NT\\\\CurrentVersion\\\\Fonts]",
            "[Software\\\\Wow6432Node\\\\Microsoft\\\\Windows NT\\\\CurrentVersion\\\\Fonts]",
        ],
    }
    value_re = re.compile(r'"[^"]*"="(.*)"\s*$')


    def unix_path(win):
        p = win.replace("\\\\", "\\")
        if p[:3].lower() == "z:\\":
            return "/" + p[3:].replace("\\", "/")
        if p.startswith("\\??\\unix"):
            return p[8:].replace("\\", "/")
        return None


    for fname, keys in KEYS.items():
        path = os.path.join(prefix, fname)
        if not os.path.exists(path):
            continue
        with open(path, encoding="utf-8", errors="surrogateescape") as f:
            lines = f.readlines()
        out, dropped, in_key = [], 0, False
        for line in lines:
            if line.startswith("["):
                in_key = any(line.startswith(k) for k in keys)
            elif in_key and line.startswith('"'):
                m = value_re.match(line.rstrip("\n"))
                u = unix_path(m.group(1)) if m else None
                if u and not os.path.exists(u):
                    dropped += 1
                    continue
            out.append(line)
        if dropped:
            tmp = path + ".prune-tmp"
            with open(tmp, "w", encoding="utf-8", errors="surrogateescape") as f:
                f.writelines(out)
            os.replace(tmp, path)
            print(f"nx-studio: dropped {dropped} dead font paths from {fname}", file=sys.stderr)
  '';
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
    ${pruneStaleFonts} "$WINEPREFIX" || echo "nx-studio: font prune failed, starting anyway" >&2
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
