{
  pkgs,
  inputs,
  ...
}: let
  # Legacy zellij session pickers, kept for reference / as fallback pickers
  #   zjp  — original bash picker (was inline in zellij.nix, bound to `Alt s`)
  #   zjp2 — nushell sesh-parity prototype (was ressources/scripts/zjp2/)
  zjp = inputs.zjp.packages.${pkgs.stdenv.hostPlatform.system}.default;
  zjp2 = inputs.zjp2.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  home.packages = [zjp zjp2];

  home.file = {
    # zjp2's config schema. Lives at the shared legacy path (~/.config/zjp/), which noren also reads as a fallback. Copy to config.toml to activate.
    ".config/zjp/config.toml.example".source = "${inputs.zjp2}/config.toml.example";
  };
}
