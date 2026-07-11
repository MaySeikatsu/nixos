{...}: {
  programs.zsh = {
    enable = true;

    # Native completion system.
    enableCompletion = true;
    completionInit = ''
      autoload -Uz compinit
      # Rescanning $fpath on every startup is the single biggest compinit
      # cost. Only do the full rescan once a day; otherwise trust the
      # cached dump (compinit -C skips the staleness check).
      if [[ -n ''${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
        compinit
      else
        compinit -C
      fi
    '';

    autosuggestion = {
      enable = true;
      strategy = ["history" "completion"];
    };
    # Home Manager sources this after all custom widgets are defined, as
    # required by zsh-syntax-highlighting's own docs.
    syntaxHighlighting.enable = true;
    # History search/recall (Up arrow, Ctrl-R, ...) is owned by atuin
    # (see atuin.nix) rather than zsh's own history-search machinery.

    history = {
      size = 5000;
      append = true;
      share = true;
      ignoreAllDups = true;
      ignoreDups = true;
      path = "$HOME/.zsh_history";
    };

    shellAliases = {
      n = "nvim";
      v = "nvim";
      # `y`  
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

    initContent = ''
      # Enable Ctrl+Backspace to delete words
      bindkey '^H' backward-kill-word
      bindkey '^[[3;5~' kill-word

      # Enable Ctrl+arrow key bindings for word jumping
      bindkey '^[[1;5C' forward-word     # Ctrl+right arrow
      bindkey '^[[1;5D' backward-word    # Ctrl+left arrow

      bindkey  "^[[H"   beginning-of-line # Pos1
      bindkey  "^[[F"   end-of-line       # End

      # Reapply cached terminal color sequences (wallust)
      [[ -r ~/.cache/wallust/sequences ]] && cat ~/.cache/wallust/sequences

      # Auto-start zellij: session named after the current directory;
      # attaches if live, resurrects if dead, creates otherwise (zellij.nix).
      [[ -o interactive ]] && zellij-autostart

      # Rename the zellij tab to the current dir (at prompt) or the running
      # command (while it runs). `tn <name>` pins a manual name, `tn` unpins.
      _zj_tab_pwd() {
        [[ -n "$ZELLIJ" && -z "$ZJ_TAB_NAME_LOCK" ]] || return 0
        local name="''${PWD:t}"
        [[ "$PWD" == "$HOME" ]] && name="~"
        zellij action rename-tab "$name"
      }
      _zj_tab_cmd() {
        [[ -n "$ZELLIJ" && -z "$ZJ_TAB_NAME_LOCK" ]] || return 0
        zellij action rename-tab "''${1%% *}"
      }
      autoload -Uz add-zsh-hook
      add-zsh-hook precmd _zj_tab_pwd
      add-zsh-hook preexec _zj_tab_cmd
      tn() {
        if (( $# )); then
          ZJ_TAB_NAME_LOCK=1
          zellij action rename-tab "$*"
        else
          unset ZJ_TAB_NAME_LOCK
        fi
      }

      # On cd into a dir with an existing zellij session, offer to switch
      # to it (exit 3 = declined; remember the decline for this shell).
      typeset -ga _zj_declined
      _zj_cd_attach_hook() {
        [[ -n "$ZELLIJ" ]] || return 0
        (( ''${_zj_declined[(Ie)$PWD]} )) && return 0
        zellij-cd-attach
        [[ $? -eq 3 ]] && _zj_declined+=("$PWD")
        return 0
      }
      add-zsh-hook chpwd _zj_cd_attach_hook
    '';
  };
}
