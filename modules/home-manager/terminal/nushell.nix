{ pkgs, ... }: {
  programs.nushell = {
    enable = true;
    shellAliases = {
      n = "nvim";
      v = "nvim";
      y = "yazi";
      zlja = "zellij attach";
      zlj = "zellij";
      pass = "gopass";
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
      # pkgs.nushellPlugins.hcl
      pkgs.nushellPlugins.gstat
      pkgs.nushellPlugins.formats
    ];

    extraConfig = ''

      let fish_completer = {|spans|
          fish --command $"complete '--do-complete=($spans | str replace --all "'" "\\'" | str join ' ')'"
          | from tsv --flexible --noheaders --no-infer
          | rename value description
          | update value {|row|
            let value = $row.value
            let need_quote = ['\' ',' '[' ']' '(' ')' ' ' '\t' "'" '"' "`"] | any {$in in $value}
            if ($need_quote and ($value | path exists)) {
              let expanded_path = if ($value starts-with ~) {$value | path expand --no-symlink} else {$value}
              $'"($expanded_path | str replace --all "\"" "\\\"")"'
            } else {$value}
          }
      }

      let carapace_completer = {|spans: list<string>|
          carapace $spans.0 nushell ...$spans
          | from json
          | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
      }

      # let zsh_completer = {|spans|
      #     zsh --rcfile /dev/null -c $"autoload -Uz compinit; compinit; compgen -A file -- ($spans | str join ' ')"
      #     | lines
      #     | each {|line| { value: $line description: "" } }
      # }

      # This completer will use carapace by default
      let external_completer = {|spans|
          let expanded_alias = scope aliases
          | where name == $spans.0
          | get -o 0.expansion

          let spans = if $expanded_alias != null {
              $spans
              | skip 1
              | prepend ($expanded_alias | split row ' ' | take 1)
          } else {
              $spans
          }

          match $spans.0 {
              # carapace completions are incorrect for nu
              nu => $fish_completer
              # fish completes commits and branch names in a nicer way
              git => $fish_completer
              # carapace doesn't have completions for asdf
              gopass => $fish_completer
              hyprctl => $fish_completer
              niri => $fish_completer
              # wallust => $zsh_completer
              _ => $carapace_completer
              # _ => $fish_completer
          } | do $in $spans
      }

      $env.config = {
          completions: {
              external: {
                  enable: true
                  completer: $external_completer
              }
          }
      }
      def start_zellij [] {
         if 'ZELLIJ' not-in ($env | columns) {
           zellij
         }
       }
       start_zellij

        # Example binding - this might need adjustment to Nushell's actual syntax:
        # bind alt-backspace = delete_word_backward
        # bind alt-delete = delete_word_forward
        # bind alt-h = move_word_backward
        # bind alt-l = move_word_forward
    '';

    envFile.text = ''
      zoxide init nushell | save -f ~/.zoxide.nu

      $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
      mkdir ~/.cache/carapace
      carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
    '';
    configFile.text = ''
      source ~/.zoxide.nu
      cat ~/.cache/wallust/sequences
    '';
    # The config.nu can be anywhere you want if you like to edit your Nushell with Nu
    # configFile.source = ./.../config.nu;

  };
  # For Autocompletions:
  programs.carapace.enable = true;
  # home.file.".config/carapace/config.kdl".source = ../../../ressources/dots/carapace/config.kdl;
  # programs.carapace.enableNushellIntegration = true;
  # programs.carapace.enableZshIntegration= true;
  # programs.carapace.enableFishIntegration = true;
  # home.sessionVariables = { CARAPACE_BRIDGES = "fish"; };
  home.sessionVariables = { CARAPACE_BRIDGES = "fish,zsh,inshellisense"; };
}
