{ inputs, pkgs, ... }:
{
  programs = {
    starship = {
      enable = true;
      settings = {
        add_newline = true;
        
      };
      # Or import a toml settings file if prefered non nixified
      # settings = pkgs.lib.importTOML ../starship.toml;
    };
  };
}
