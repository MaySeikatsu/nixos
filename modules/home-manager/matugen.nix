{ config, inputs, pkgs, ... }:
{
   imports = [
    inputs.matugen.nixosModules.default
  ];

  programs = {
    matugen = {
      enable = true;
      variant = "dark";
      wallpaper = ./../../../../Downloads/thumb-1920-1377800.png;

      templates = {
        ghostty = {
            input_path = "./matugen_templates/ghostty.theme";
            output_path = "/home/maike/.config/ghostty/themes/matugen.theme"; #output path needs to be created manually if not already existing
          };
          yazi = {
            input_path = "./matugen_templates/yazi.toml";
            output_path = "/home/maike/.config/yazi/colors.toml";
          };
      # palette = "default";
      
      # settings = {
      #   # config = {
      #   #   reload_apps = true;
      #   # };
      };
    };
  };
}
