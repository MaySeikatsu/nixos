{...}: {
  # Unified, context-rich (cwd, exit code, duration) shell history across
  # zsh, fish, and nushell, replacing each shell's own bespoke history
  # search/keybinds. Local-only until `atuin login`/`atuin sync` is run by
  # hand; nothing phones home by default.
  programs.atuin = {
    enable = true;
    # Defaults: binds ctrl-r and Up arrow in zsh/fish, Up arrow in nushell.
  };
}
