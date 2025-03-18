{pkgs, inputs, ...}:
  let
    system = "x86_64-linux";
  in
{
  home.packages = [
# For NixOS
  # inputs.spicetify-nix.nixosModules.default
# For home-manager
  inputs.spicetify-nix.homeManagerModules.default
  ];
}
