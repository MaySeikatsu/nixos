# storytold "*Craft" creative apps. Toggle: my.craftApps.enable
# (modules/nixos/profiles.nix)
#
#   filmcraft    video editor
#   photocraft   image editor (Photoshop-like)
#   lightcraft   photo library + raw developer (Lightroom-like)
#   effectcraft  motion graphics / VFX (After Effects-like)
#
# Each also installs `<name>-cli` (headless renderer / MCP server).
#
# Default: official release binaries (packages/craft-app-bin.nix), no local
# compiling. Bump: set `version` to the new release tag and `hash` to
# lib.fakeHash, rebuild, copy the real hash from the error -- and compare it
# with the release's SHA256SUMS.txt.
#
# ALTERNATIVE -- build from source from my forks (github:MaySeikatsu/*),
# the code that was security-reviewed (2026-10-08). Slow first build.
# To switch:
#   1. flake.nix: uncomment the filmcraft/photocraft/lightcraft/effectcraft
#      and craft-fonts inputs, then `nix flake lock`
#   2. here: comment out the "release binaries" list and uncomment the
#      "forks" list below
# Bump forks: sync them with upstream on GitHub, then
# `nix flake update filmcraft photocraft lightcraft effectcraft`.
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  craftAppBin = args: pkgs.callPackage ../../../packages/craft-app-bin.nix args;
  # craftApp = args:
  #   pkgs.callPackage ../../../packages/craft-app.nix ({craft-fonts = inputs.craft-fonts;} // args);
in {
  config = lib.mkIf config.my.craftApps.enable {
    # --- release binaries (official repo) ---
    environment.systemPackages = [
      (craftAppBin {
        name = "filmcraft";
        version = "0.2.1";
        hash = "sha256-3/J+ZEvLBrPUwfZnuP1US9Fe5LRGyK7mFwZxLyEoh68=";
        description = "Video editor";
      })
      (craftAppBin {
        name = "photocraft";
        version = "0.3.0";
        hash = "sha256-6POvavrlOopNbrE6v7zPdLj/whQ+SHBH1yTlaD1c/z0=";
        description = "Image editor";
      })
      (craftAppBin {
        name = "lightcraft";
        version = "0.2.1";
        hash = "sha256-VD+RyW5AgehgZeyPs9YkR7CL/Wrg2iLfUPwnpVu5d30=";
        description = "Photo library and non-destructive raw developer";
      })
      (craftAppBin {
        name = "effectcraft";
        version = "0.4.0";
        hash = "sha256-O3tha6g3kQ6BLlPP8XdsVhWf6WRO+NxHpFdZvXq3Z5o=";
        description = "Motion graphics and visual effects";
      })
    ];

    # --- forks, built from source (see ALTERNATIVE above) ---
    # environment.systemPackages = [
    #   (craftApp {
    #     name = "filmcraft";
    #     src = inputs.filmcraft;
    #     description = "Video editor";
    #   })
    #   (craftApp {
    #     name = "photocraft";
    #     src = inputs.photocraft;
    #     description = "Image editor";
    #     # HEIC/HEIF support, as in the official builds (pure Rust)
    #     extraCargoFlags = ["--features" "heif"];
    #   })
    #   (craftApp {
    #     name = "lightcraft";
    #     src = inputs.lightcraft;
    #     description = "Photo library and non-destructive raw developer";
    #   })
    #   (craftApp {
    #     name = "effectcraft";
    #     src = inputs.effectcraft;
    #     description = "Motion graphics and visual effects";
    #   })
    # ];
  };
}
