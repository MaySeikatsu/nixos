{inputs, pkgs, ...}: {
  programs.niri = {
    enable = true;
    # useNautilus = true;
    package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
}
