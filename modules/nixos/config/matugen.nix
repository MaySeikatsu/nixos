{ config, inputs, pkgs, ... }:
{
  imports = [
    inputs.matugen.nixosModules.default
  ];

  programs = {
    matugen = {
      enable = true;
      variant = "dark";
      wallpaper = "./../../../ressources/wallpapers/1359084.png";

      templates = {
        ghostty = {
            input_path = ./../../../ressources/matugen_templates/ghostty.theme;
            output_path = "/home/maike/.config/ghostty/matugen.theme"; #output path needs to be created manually if not already existing
          };
          yazi = {
            input_path = ./../../../ressources/matugen_templates/yazi.toml;
            # output_path = "/home/maike/.config/yazi/colors.toml";
            output_path = "/home/maike/.config/yazi/theme.toml";
          };
      palette = "default";
      
      settings = {
          config = {
            reload_apps = true;
          };
        };
      };
    };
  };
}
