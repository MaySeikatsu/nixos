{ config, pkgs, lib, inputs, ... }: {
  # environment.systemPackages = with pkgs;
  #   [
  #     # inputs.noctalia.packages.${system}.default
  #     inputs.qs-noctalia.packages.${system}.default
  #     inputs.caelestia-shell.packages.${system}.default
  #     inputs.qs-retroism.packages.${system}.default
  #     # inputs.quickshell.packages.${system}.default
  #   ];
  programs.niri = {
    enable = true;
    # package = pkgs.niri-unstable;
  };
}
