{
  pkgs,
  lib,
  inputs,
  ...
}: {
  xdg.dataFile = {
    "steel/cogs/forest".source = inputs.forest-hx;
    "steel/cogs/notify".source = inputs.notify-hx;
    "steel/cogs/glyph".source = inputs.glyph-hx;
  };

  xdg.configFile = {
    "helix/init.scm".text = ''
      (require "helix/keymaps.scm")
      (require "forest/forest.scm")
      (forest-configure! 'left #:ignore (list ".git" "target" "__pycache__"))
      (forest-set-style! 'snacks)
      (keymap (global)
              (normal (space (e ":forest-open"))))
    '';

    # Yazelix reads --config-dir ~/.config/yazelix/helix, not ~/.config/helix, so repeat the theme here.
    "yazelix/helix/config.toml".text = ''
      theme = "rose_pine_moon"
    '';
  };

  programs.helix = {
    enable = true;
    # package = pkgs.evil-helix;
    package = inputs.evil-yazelix-helix.packages.${pkgs.system}.default;

    settings = {
      theme = "rose_pine_moon";
      # Zellij integration: works because :sh just talks to the surrounding
      # zellij session's server. -f = floating pane, -c = close when app exits.
      keys = {
        normal = {
          S-h = "goto_previous_buffer";
          S-l = "goto_next_buffer";
          C-r = "redo";
          C-x = ":buffer-close";
          C-S-x = ":buffer-close-others";
          C-b = "buffer_picker";

          space = {
            T = ":sh zellij action new-pane -f"; # Space+T floating console
            L = ":sh zellij run -fc -- lazygit"; # Space+L floating lazygit
            Y = ":sh zellij run -fc -- yazi"; # Space+Y floating yazi (Space+e/E = builtin explorer)
            B = ":sh zellij run -c -d left -- broot"; # Space+B sidebar filetree
            X = ":sh zellij plugin -f -- zellij:strider"; # Space+X floating strider tree
            # space = "openfilepicker";
          };
        };
        # select = {
        #   A-e = "extend_to_line_bounds";
        #   A-z = "select_line_above";
        # };
      };
      editor = {
        evil = true;
        # clipboard-provider = "";
        auto-format = true; # global default, can be overridden per language
        line-number = "relative";
        bufferline = "multiple"; # Enable bufferline at top showing open/active buffers
        file-picker.hidden = false;
        statusline = {
          left = ["mode" "spinner" "version-control" "file-name"];
        };
        end-of-line-diagnostics = "hint";
        inline-diagnostics = {
          cursor-line = "error";
          # other-lines = "";
        };
        lsp = {
          # enable = true;
          auto-signature-help = false;
          display-messages = true;
        };
        # softwrap.enable = true;
        # search = "";
        rulers = [120];
        color-modes = true;
        true-color = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        # indent-guides = {
        #   character = "╎"; # "|"
        #   render = true;
        # };
      };
    };
    extraPackages = with pkgs; [
      nil
      alejandra
      rust-analyzer
      rustfmt
      # nodePackages.typescript-language-server
      # nodePackages.typescript
      terraform-ls
      yaml-language-server
      # taplo
      # pyright
      # black
    ];
  };
}
