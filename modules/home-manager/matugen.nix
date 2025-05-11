{ config, inputs, pkgs, ... }:
{
   imports = [
    inputs.matugen.nixosModules.default
  ];

  programs = {
    matugen = {
      enable = true;
      variant = "dark";
      # palette = "default";
      
      # settings = {
      #   # config = {
      #   #   reload_apps = true;
      #   # };
      # };
    };
  };
}
