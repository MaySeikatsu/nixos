# See for documentation: https://github.com/luccahuguet/yazelix/blob/main/docs/configuration.md
#
# Yazelix Nova (1.0.0-beta.1) rewrote the home-manager module: manage_config,
# helix_external, custom_popups, and runtime_tool_sources are gone. Config is
# now a sparse TOML passthrough (programs.yazelix.config.settings), and the
# embedded Helix build is chosen via the yazelixHelix flake input instead
# (see flake.nix: yazelix-hm.inputs.yazelixHelix.follows).
{...}: {
  programs.yazelix = {
    enable = true;

    config.settings = {
      welcome.enabled = false;

      popups.btop = {
        command = "btop";
        keybinding = "Alt Shift Y";
        keep_alive = true;
      };
    };
  };
}
