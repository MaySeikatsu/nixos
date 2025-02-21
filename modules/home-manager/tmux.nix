{pkgs, ...}:
{
  programs.tmux = {
      enable = true;
      #shortcut = " ";
      shell = "${pkgs.zsh}/bin/zsh";
      terminal = "tmux-256color";
      historyLimit = 10000;
      baseIndex = 1;
      extraConfig = 
      ''
        set -g mouse on

        unbind C-b
        set -g prefix C-Space
        bind C-Space send-prefix

        bind h select-pane -L
        bind l select-pane -R
        bind j select-pane -D
        bind k select-pane -U

        set -g base-index 1
        set -g pane-base-index 1
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on

        set -g default-terminal "tmux-256color"
        set -g allow-passthrough on
        set -ga update-environment TERM
        set -ga update-environment TERM_PROGRAM

      '';
      plugins = with pkgs;
      [
        # {
        #   plugin = tmuxPlugins.rose-pine;
        #   extraConfig = 
        #   ''
        #     set -g @rose_pine_variant 'moon'
        #
        #     set -g @rose_pine_host 'on'
        #     set -g @rose_pine_date_time 'on'
        #     set -g @rose_pine_date_user 'on'
        #     set -g @rose_pine_date_directory 'on'
        #   '';
        # }
        {
          plugin = tmuxPlugins.gruvbox;
          extraConfig = 
          ''
            set -g @tmux-gruvbox 'dark'
          '';
        }
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = 
          ''
            set -g @resurrect-strategy-vim 'session'
            set -g @resurrect-strategy-nvim 'session'
            set -g @resurrect-capture-pane-contents 'on'
          '';
        }
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = 
          ''
            set -g @continuum-restore 'on'
            set -g @continuum-boot 'on'
            set -g @continuum-save-interval '10'
          '';
        }
      ];
    };
}
