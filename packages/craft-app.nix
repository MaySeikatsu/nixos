# One of the storytold "*Craft" apps (FilmCraft, PhotoCraft, LightCraft,
# EffectCraft), built from my forks (flake inputs, flake = false).
#
# Modeled on upstream lightcraft's nix/package.nix -- the only one of the
# four that ships a Nix package -- generalized over the app name. All four
# share the same layout: `[workspace.package] version` in Cargo.toml,
# packaging/linux/<appId>.{desktop,mime.xml,metainfo.xml.in},
# assets/app-icon/hicolor, binaries `<name>` + `<name>-cli`.
#
# Security review (2026-10-08, forks identical to upstream): build.rs scripts
# only embed icons/fonts/credits; no telemetry or update checks; network only
# on explicit "download model" actions (SHA-256 pinned); the localhost control
# server only starts with --control <port>.
{
  lib,
  rustPlatform,
  pkg-config,
  makeWrapper,
  wayland,
  wayland-scanner,
  libxkbcommon,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxrandr,
  vulkan-loader,
  alsa-lib,
  autoAddDriverRunpath,
  # the fork's source (flake input)
  src,
  # "filmcraft" | "photocraft" | "lightcraft" | "effectcraft"
  name,
  description,
  # extra cargo flags, e.g. ["--features" "heif"] for photocraft
  extraCargoFlags ? [],
  # storytold/craft-fonts checkout: CJK glyphs (null = boxes for JP/CN text)
  craft-fonts ? null,
}: let
  version = (builtins.fromTOML (builtins.readFile (src + "/Cargo.toml"))).workspace.package.version;
  appId = "ai.storyteller.${name}";
  binaries = [name "${name}-cli"];

  # dlopen'd at run time by winit/wgpu, so nothing puts them in an RPATH
  runtimeLibs = [libxkbcommon wayland libx11 libxcb libxcursor libxi libxrandr vulkan-loader];
in
  rustPlatform.buildRustPackage {
    pname = name;
    inherit version src;

    cargoLock = {
      lockFile = src + "/Cargo.lock";
      # effectcraft pulls filmcraft crates from git at a pinned rev
      allowBuiltinFetchGit = true;
    };

    cargoBuildFlags = ["--locked"] ++ lib.concatMap (b: ["-p" b]) binaries ++ extraCargoFlags;

    # the full workspace test suite is long and some tests want ffmpeg/a GPU
    doCheck = false;

    strictDeps = true;
    nativeBuildInputs = [pkg-config makeWrapper wayland-scanner autoAddDriverRunpath];
    buildInputs = [wayland libxkbcommon libx11 libxcb libxcursor libxi libxrandr alsa-lib];

    env = lib.optionalAttrs (craft-fonts != null) {
      CRAFT_FONTS_DIR = toString craft-fonts;
      CRAFT_FONTS_REQUIRED = "1";
    };

    postInstall = ''
      install -Dm644 packaging/linux/${appId}.desktop $out/share/applications/${appId}.desktop
      install -Dm644 packaging/linux/${appId}.mime.xml $out/share/mime/packages/${appId}.xml
      mkdir -p $out/share/icons
      cp -r assets/app-icon/hicolor $out/share/icons/
      install -d $out/share/metainfo
      substitute packaging/linux/${appId}.metainfo.xml.in \
        $out/share/metainfo/${appId}.metainfo.xml \
        --subst-var-by VERSION ${version} \
        --subst-var-by DATE 1970-01-01

      for bin in ${lib.concatMapStringsSep " " (b: "$out/bin/" + b) binaries}; do
        wrapProgram "$bin" --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"
      done
    '';

    meta = {
      inherit description;
      homepage = "https://getartcraft.com/apps/${name}";
      license = with lib.licenses; [mit asl20];
      platforms = lib.platforms.linux;
      mainProgram = name;
    };
  }
