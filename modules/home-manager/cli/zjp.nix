{
  pkgs,
  lib,
  ...
}: let
  # zjp v2 - sesh feature-parity zellij session picker.
  # Nushell prototype. The current bash `zjp` in zellij.nix is intentionally
  # left untouched during the bake-off (see plan). Wire to Alt s later.
  zjp2Src = ../../../ressources/scripts/zjp2;

  zjp2 = pkgs.writeShellScriptBin "zjp2" ''
    export PATH=${lib.makeBinPath [
      pkgs.nushell
      pkgs.zellij
      pkgs.zoxide
      pkgs.fzf
      pkgs.git
      pkgs.coreutils
      pkgs.gnused
      pkgs.gawk
      pkgs.gnugrep
      pkgs.findutils
    ]}:$PATH
    exec nu ${zjp2Src}/main.nu "$@"
  '';
in {
  home.packages = [zjp2];

  home.file = {
    ".config/zjp/config.toml.example".source = ../../../ressources/dots/zjp/config.toml.example;
  };
}
