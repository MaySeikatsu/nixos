# PNGTuber Remix: PNG-tuber avatar app (Godot 4) with mouth/blink states
# driven by the mic. Not in nixpkgs; this repackages upstream's Linux build.
# Update: bump version + hash (nix-prefetch-url <url>).
{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  alsa-lib,
  dbus,
  fontconfig,
  libGL,
  libpulseaudio,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxkbcommon,
  libxrandr,
  libxrender,
  udev,
  vulkan-loader,
  wayland,
}: let
  # Godot dlopen()s these at runtime instead of linking them
  runtimeLibs = [
    alsa-lib
    dbus
    fontconfig
    libGL
    libpulseaudio
    libx11
    libxcursor
    libxext
    libxi
    libxinerama
    libxkbcommon
    libxrandr
    libxrender
    udev
    vulkan-loader
    wayland
  ];
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "pngtuber-remix";
    version = "1.4.7";

    src = fetchzip {
      url = "https://github.com/MudkipWorld/PNGTuber-Remix/releases/download/v${finalAttrs.version}/PNGTubeRemixV${finalAttrs.version}.Linux.zip";
      hash = "sha256-WmGpz95rWBdetn3a3GxUqn5DkrzypWCiXEc28kp1PSc=";
    };

    nativeBuildInputs = [autoPatchelfHook];
    buildInputs = [stdenv.cc.cc.lib];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/pngtuber-remix $out/bin
      cp -r ./* $out/libexec/pngtuber-remix/
      chmod +x $out/libexec/pngtuber-remix/PNGTube-Remix.x86_64

      # The app saves its settings (and DefaultTraining.tres) next to its own
      # executable, which is read-only in the store. So the launcher keeps a
      # writable copy in ~/.local/share/pngtuber-remix: program files are
      # refreshed when the version changes, files the app wrote are kept.
      cat > $out/bin/pngtuber-remix <<EOF
      #!${stdenv.shell}
      dir="\''${XDG_DATA_HOME:-\$HOME/.local/share}/pngtuber-remix"
      if [ "\$(cat "\$dir/.version" 2>/dev/null)" != "$out" ]; then
        mkdir -p "\$dir"
        for f in $out/libexec/pngtuber-remix/*; do
          case "\$f" in
            *.tres) cp -n --no-preserve=mode "\$f" "\$dir/" ;;
            *) cp -f --no-preserve=mode "\$f" "\$dir/" ;;
          esac
        done
        chmod +x "\$dir/PNGTube-Remix.x86_64"
        echo "$out" > "\$dir/.version"
      fi
      export LD_LIBRARY_PATH="${lib.makeLibraryPath runtimeLibs}\''${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
      exec "\$dir/PNGTube-Remix.x86_64" "\$@"
      EOF
      chmod +x $out/bin/pngtuber-remix

      mkdir -p $out/share/applications
      cat > $out/share/applications/pngtuber-remix.desktop <<EOF
      [Desktop Entry]
      Type=Application
      Name=PNGTuber Remix
      Comment=PNG-tuber avatar driven by your microphone
      Exec=pngtuber-remix
      Categories=AudioVideo;Video;
      EOF
      runHook postInstall
    '';

    meta = {
      description = "PNG-tuber avatar app with mic-driven mouth states";
      homepage = "https://github.com/MudkipWorld/PNGTuber-Remix";
      # source-available: personal use + streaming fine, commercial
      # redistribution needs the author's permission
      license = lib.licenses.unfree;
      platforms = ["x86_64-linux"];
      mainProgram = "pngtuber-remix";
    };
  })
