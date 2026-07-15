{
  pkgs,
  lib,
  inputs,
  ...
}: let
  # noren (暖簾) - the Rust session manager (formerly zjp3), consumed as a
  # flake input from GitHub. After changing it: commit there,
  # `nix flake update noren` here, rebuild. The legacy pickers it superseded
  # (bash zjp, nushell zjp2) live in their own flakes now — see zjp.nix.
  # Bound to Alt Shift S / Alt Shift P / Alt Shift W and `Ctrl g o s|k|x`;
  # also used by zellij-autostart for per-project layout/startup resolution.
  noren = inputs.noren.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  home.packages = [
    noren
  ];

  # `zs` works in any shell/terminal as the universal picker shortcut.
  home.shellAliases.zs = "noren";

  home.file = {
    # noren's example documents the full option set (sort/separator/pins/preview/snapshots).
    ".config/noren/config.toml.example".source = "${inputs.noren}/config.toml.example";
  };

  # Alt+(Shift)+S opens the picker straight from the shell prompt — this covers
  # bare terminals/TTY/SSH; inside zellij the same chord is consumed by
  # zellij's own bind (locked mode passes it through, where these fire too,
  # and noren switches via the zellij-switch pipe, so both paths are safe).
  # fish/zsh/bash completions ship in the package's vendor dirs; nushell has
  # no vendor convention, so it's sourced explicitly below.
  programs.fish.interactiveShellInit = ''
    bind \eS 'noren; commandline -f repaint'
  '';

  programs.zsh.initContent = ''
    _noren-picker() { zle -I; noren </dev/tty; zle reset-prompt }
    zle -N _noren-picker
    bindkey '\eS' _noren-picker
  '';

  # mkAfter: nushell.nix assigns `$env.config = {…}` and `$env.config.keybindings = […]`
  # in its extraConfig — this append has to land after both.
  programs.nushell.extraConfig = lib.mkAfter ''
    source ${noren}/share/nushell/noren-completions.nu
    $env.config.keybindings = ($env.config.keybindings | append {
      name: noren_picker
      modifier: alt_shift
      keycode: char_s
      mode: [emacs vi_normal vi_insert]
      event: { send: executehostcommand cmd: "noren" }
    })
  '';
}
