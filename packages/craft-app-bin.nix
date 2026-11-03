# One of the storytold "*Craft" apps (FilmCraft, PhotoCraft, LightCraft,
# EffectCraft) from the official GitHub release tarball (x86_64 Linux).
# No local compiling; the source-build alternative from my forks is
# packages/craft-app.nix (see modules/nixos/config/craft-apps.nix).
#
# Trust: the hash pins exactly the tarball checked on 2026-10-08 against the
# release's SHA256SUMS.txt. Upstream publishes no signatures or build
# provenance, so these binaries can't be tied to the reviewed source -- you
# trust storytold's release CI.
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  wayland,
  libxkbcommon,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxrandr,
  vulkan-loader,
  addDriverRunpath,
  # "filmcraft" | "photocraft" | "lightcraft" | "effectcraft"
  name,
  version,
  hash,
  description,
}: let
  binaries = [name "${name}-cli"];
  # dlopen'd at run time by winit/wgpu (not ELF NEEDED entries)
  runtimeLibs = [libxkbcommon wayland libx11 libxcb libxcursor libxi libxrandr vulkan-loader];
in
  stdenv.mkDerivation {
    pname = name;
    inherit version;

    src = fetchurl {
      url = "https://github.com/storytold/${name}/releases/download/v${version}/${name}-${version}-linux-x86_64.tar.gz";
      inherit hash;
    };

    nativeBuildInputs = [autoPatchelfHook makeWrapper];
    # libasound (film/effectcraft) + libgcc_s; everything else is glibc
    buildInputs = [alsa-lib stdenv.cc.cc.lib];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r bin share $out/
      runHook postInstall
    '';

    postFixup = ''
      for bin in ${lib.concatMapStringsSep " " (b: "$out/bin/" + b) binaries}; do
        wrapProgram "$bin" \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}:${addDriverRunpath.driverLink}/lib"
      done
    '';

    meta = {
      inherit description;
      homepage = "https://getartcraft.com/apps/${name}";
      license = with lib.licenses; [mit asl20];
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      platforms = ["x86_64-linux"];
      mainProgram = name;
    };
  }
