{pkgs, ...}:
{
  programs.zsh = {
      enable = true;
      history = {
        size = 5000;
        append = true;
        share = true;
        ignoreAllDups = true;
        ignoreDups = true;
        path = "$HOME/.zsh_history;";
      };

      initExtra = 
      ''
        alias v=nvim
        bindkey '^p' history-search-backward
        bindkey '^n' history-search-backward

        eval "$(fzf --zsh)"
        eval "$(zoxide init zsh)"
      '';
      
        zplug = {
          enable = true;
          plugins = [
        { name = "zsh-users/zsh-autosuggestions"; }
        { name = "zsh-users/zsh-completions"; }
        { name = "zsh-users/zsh-syntax-highlighting"; }
        ];
    };
  };
}
