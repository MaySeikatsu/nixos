{pkgs, ...}:
{
  programs.zsh = {
      enable = true;
      enableCompletion = false;
      history = {
        size = 5000;
        append = true;
        share = true;
        ignoreAllDups = true;
        ignoreDups = true;
        path = "$HOME/.zsh_history;";
      };

      initContent = 
      ''
        alias v=nvim
        bindkey '^p' history-search-backward
        bindkey '^n' history-search-backward

        # Enable STRG to delete words
        bindkey '^H' backward-kill-word
        bindkey '^[[3;5~' kill-word

        # Enable Ctrl+arrow key bindings for word jumping
        bindkey '^[[1;5C' forward-word     # Ctrl+right arrow
        bindkey '^[[1;5D' backward-word    # Ctrl+left arrow

        bindkey  "^[[H"   beginning-of-line # Pos1
        bindkey  "^[[F"   end-of-line       # End

        alias n='nvim'

        # export ANDROID_HOME=/opt/android-sdk/
        # export PATH=$PATH:$ANDROID_HOME/emulator
        # export PATH=$PATH:$ANDROID_HOME/platform-tools
        # wallust run ~/.current-wallpaper
        cat ~/.cache/wallust/sequences

        eval "$(starship init zsh)"
        eval "$(fzf --zsh)"
        eval "$(zoxide init zsh)"
      '';
      
        zplug = {
          enable = true;
          plugins = [
        { name = "zsh-users/zsh-autosuggestions"; }
        { name = "zsh-users/zsh-completions"; }
        { name = "zsh-users/zsh-syntax-highlighting"; }
        # { name = "zsh-users/zsh-defer"; }
        # { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; } # Installations with additional options. For the list of options, please refer to Zplug README.
        ];
    };
  };
}
