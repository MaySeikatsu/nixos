{
  inputs,
  pkgs,
  ...
}: let
  # nixpkgs bumped libdisplay-info 0.3.0 -> 0.4.0, but niri vendors
  # libdisplay-info-sys 0.3.0, whose build script requires
  # `libdisplay-info < 0.4.0` -> pkg-config fails, niri won't build.
  #
  # Upstream is fixing this on both sides, neither has reached us yet:
  #   - nixpkgs#546004 adds libdisplay-info_0_3 and pins niri to it.
  #     Merged to master 2026-07-26, not yet in the nixos-unstable channel.
  #   - niri#4366 does the same for niri's own flake.nix. Still open.
  #
  # Until then, build the 0.3.0 library ourselves and pass it to niri.
  # Drop this once nixpkgs exposes libdisplay-info_0_3 *and* niri's flake
  # pins it (i.e. the plain `.default` builds again).
  libdisplay-info_0_3 = pkgs.libdisplay-info.overrideAttrs (_: {
    version = "0.3.0";
    src = pkgs.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "emersion";
      repo = "libdisplay-info";
      rev = "0.3.0";
      hash = "sha256-nXf2KGovNKvcchlHlzKBkAOeySMJXgxMpbi5z9gLrdc=";
    };
  });
in {
  programs.niri = {
    enable = true;
    # useNautilus = true;
    package =
      inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
        libdisplay-info = libdisplay-info_0_3;
      };
  };
}
