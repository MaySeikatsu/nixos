{ pkgs, ... }:
{
  programs.nushell = {
    enable = true;
    shellAliases = {
      n = "nvim";
      v = "nvim";
      y = "yazi";
      zja = "zellij attach";
      zlj = "zellij";
    };
    settings = {
      edit_mode = "vi";
      show_banner = false;
      completions = {
        external.enable = true;
        # external.completer = "fish";
        # external.fallback = "fish"; #set fish as fallsback to nuhsell / carapace
      };
    };
    plugins = [
      pkgs.nushellPlugins.skim
      pkgs.nushellPlugins.highlight
      pkgs.nushellPlugins.hcl
      pkgs.nushellPlugins.gstat
      pkgs.nushellPlugins.formats
    ];

    extraConfig = ''
      # $env.config = ($env.config | upsert show_banner false)
      # $env.config.completions.external = ($env.config.completions.external | upsert completer fish)
      #
      # def start_zellij [] {
      #    if 'ZELLIJ' not-in ($env | columns) {
      #      zellij
      #    }
      #  }
      #  start_zellij

       # Example binding - this might need adjustment to Nushell's actual syntax:
       # bind alt-backspace = delete_word_backward
       # bind alt-delete = delete_word_forward
       # bind alt-h = move_word_backward
       # bind alt-l = move_word_forward
    '';

    envFile.text = ''
      zoxide init nushell | save -f ~/.zoxide.nu
    '';
    configFile.text = ''
      source ~/.zoxide.nu
    '';
    # The config.nu can be anywhere you want if you like to edit your Nushell with Nu
    # configFile.source = ./.../config.nu;

  };
  # For Autocompletions:
  programs.carapace.enable = true;
  programs.carapace.enableNushellIntegration = true;
  # programs.carapace.enableZshIntegration= true;
  programs.carapace.enableFishIntegration = true;
  home.sessionVariables = {
    CARAPACE_BRIDGES = "fish";
  };
}
