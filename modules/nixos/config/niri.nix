{
  config,
  inputs,
  pkgs,
  ...
}: {
  programs.niri = {
    enable = true;
    # useNautilus = true;
    # package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };

  # my.kurashi-pointerLight.enable (profiles.nix): kurashi's module then builds niri from its main branch. Its package
  # option is a mkDefault, so this is the nixpkgs niri while the toggle is off.
  programs.kurashi.pointerLight.enable = config.my.kurashi-pointerLight.enable;
}
