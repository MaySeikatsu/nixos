{...}: {
  programs.nushell = {
    enable = true;
    shellAliases = {
      n = "nvim";
      v = "nvim";
      zlja = "zellij attach";
      zlj = "zellij";
      # session rename+pin is the `sn` script from zellij.nix (not an alias,
      # so that renaming also pins the session against the reaper)
      pass = "gopass";

      # Git Aliases:
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gf = "git fetch";
      gp = "git pull";
      gP = "git push";
      gb = "git branch";
      gC = "git checkout";
      gm = "git merge";
      gr = "git rebase";
      gl = "git log";

      davinci-resolve = "nvidia-offload davinci-resolve";
    };

    settings = {
      # edit_mode = "vi";
      show_banner = false;
      completions = {
        external.enable = true;
        # external.completer = "fish";
        # external.fallback = "fish"; #set fish as fallsback to nuhsell / carapace
      };
    };
    plugins = [
      # pkgs.nushellPlugins.skim
      # pkgs.nushellPlugins.highlight
      # pkgs.nushellPlugins.hcl
      # pkgs.nushellPlugins.gstat
      # pkgs.nushellPlugins.formats
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
              zellij => $fish_completer
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
      # Auto-start zellij: session named after the current directory;
      # attaches if live, resurrects if dead, creates otherwise (zellij.nix).
      if 'ZELLIJ' not-in ($env | columns) { zellij-autostart }

      # Rename the zellij tab to the current dir (at prompt) or the running
      # command (while it runs). `tn <name>` pins a manual name, `tn` unpins.
      $env.config.hooks.pre_prompt = ($env.config.hooks.pre_prompt | append {||
        if ('ZELLIJ' in ($env | columns)) and (($env.ZJ_TAB_NAME_LOCK? | default "") == "") {
          let name = if $env.PWD == $env.HOME { "~" } else { $env.PWD | path basename }
          zellij action rename-tab $name
        }
      })
      $env.config.hooks.pre_execution = ($env.config.hooks.pre_execution | append {||
        if ('ZELLIJ' in ($env | columns)) and (($env.ZJ_TAB_NAME_LOCK? | default "") == "") {
          let cmd = (commandline | str trim | split row ' ' | get -o 0 | default "")
          if $cmd != "" { zellij action rename-tab $cmd }
        }
      })
      def --env tn [name?: string] {
        if $name == null {
          hide-env -i ZJ_TAB_NAME_LOCK
        } else {
          $env.ZJ_TAB_NAME_LOCK = "1"
          zellij action rename-tab $name
        }
      }

      # On cd into a dir with an existing zellij session, offer to switch
      # to it (exit 3 = declined; remember the decline for this shell).
      $env.config.hooks.env_change.PWD = ($env.config.hooks.env_change.PWD? | default [] | append {
        condition: {|_, after| ('ZELLIJ' in ($env | columns)) and (not ($after in ($env.ZJ_CD_DECLINED? | default []))) }
        code: "if (do { zellij-cd-attach } | complete | get exit_code) == 3 { $env.ZJ_CD_DECLINED = (($env.ZJ_CD_DECLINED? | default []) | append $env.PWD) }"
      })

        # Example binding - this might need adjustment to Nushell's actual syntax:
        # bind alt-backspace = delete_word_backward
        # bind alt-delete = delete_word_forward
        # bind alt-h = move_word_backward
        # bind alt-l = move_word_forward
        $env.config.keybindings = [
        {
          name: delete_word_backward
          modifier: control
          keycode: char_h
          mode: [emacs vi_insert vi_normal]
          event: { edit: backspaceword }
        }
      ]

    # Direnv Hook
    $env.config.hooks.pre_prompt = ($env.config.hooks.pre_prompt | append {||
        if (which direnv | is-empty) { return }
        direnv export json | from json | default {} | load-env
    })
    '';

    envFile.text = ''
      zoxide init nushell | save -f ~/.zoxide.nu

      $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
      mkdir ~/.cache/carapace
      carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
    '';
    configFile.text = ''
      source ~/.zoxide.nu
      # cat ~/.cache/wallust/sequences
      { ||
          if (which direnv | is-empty) {
              return
          }

          direnv export json | from json | default {} | load-env
      }
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
  home.sessionVariables = {
    CARAPACE_BRIDGES = "fish,zsh,inshellisense";
    CARAPACE_EXCLUDES = "git";
  };
}
