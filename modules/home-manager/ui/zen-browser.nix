{ pkgs, inputs, ... }:
let
  system = "x86_64-linux";
in
{
  home.packages = [
    # inputs.zen-browser.packages."${system}".specific
    # Docu: https://github.com/0xc000022070/zen-browser-flake
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".twilight
  ];
}
