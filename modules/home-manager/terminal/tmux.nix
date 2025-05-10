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

        ## Start windows and panes at 1, not 0
        #set -g base-index 1
        #set -g pane-base-index 1
        #set-window-option -g pane-base-index 1
        #set-option -g renumber-windows on
        
        set -g base-index 1
        set -g pane-base-index 1
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on

        # Shift arrow to switch windows
        bind -n S-Left  previous-window
        bind -n S-Right next-window

        # Shift Alt vim keys to switch windows
        bind -n M-H previous-window
        bind -n M-L next-window

        set -g default-terminal "tmux-256color"
        set -g allow-passthrough on
        set -ga update-environment TERM
        set -ga update-environment TERM_PROGRAM

        bind -n M-Left select-pane -L
        bind -n M-Right select-pane -R
        bind -n M-Up select-pane -U
        bind -n M-Down select-pane -D

        ## set vi-mode
        ##set-window-option -g mode-keys vi
        ## keybindings
        ##bind-key -T copy-mode-vi v send-keys -X begin-selection
        ##bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        ##bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
        #
        bind '"' split-window -v -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"
      '';
      plugins = with pkgs;
      [
        {
          plugin = tmuxPlugins.rose-pine;
          extraConfig = 
          ''
            set -g @rose_pine_variant 'moon'

            set -g @rose_pine_host 'on'
            set -g @rose_pine_date_time 'on'
            set -g @rose_pine_date_user 'on'
            set -g @rose_pine_date_directory 'on'
          '';
        }
        # {
        #   plugin = tmuxPlugins.gruvbox;
        #   extraConfig = 
        #   ''
        #     set -g @tmux-gruvbox 'dark'
        #   '';
        # }
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
