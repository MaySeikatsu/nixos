{ pkgs, ... }:
{
  home.file.".config/caelestia/shell.json".source =
    ../../ressources/dots/quickshell/caelestia/shell.json;
  home.file.".config/caelestia/cli.json".source = ../../ressources/dots/quickshell/caelestia/cli.json;
}
