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
  };

  programs.helix = {
    enable = true;
    # package = pkgs.evil-helix;
    package = inputs.evil-yazelix-helix.packages.${pkgs.system}.default;

    settings = {
      theme = "rose_pine_moon";
      editor = {
        evil = true;
        # clipboard-provider = "";
        auto-format = true; # global default, can be overridden per language
        line-number = "relative";
        bufferline = "multiple";
        file-picker.hidden = false;
        # softwrap.enable = true;
        # lsp = {
        #   enable = true;
        # };
        # search = "";
        color-modes = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
      };
    };
    # languages = {
    #   language = [
    #     # Nix
    #     {
    #       name = "nix";
    #       auto-format = true;
    #       formatter = {
    #         command = lib.getExe pkgs.alejandra;
    #       };
    #       language-servers = ["nil"];
    #     }
    #
    #     # Rust
    #     {
    #       name = "rust";
    #       auto-format = true;
    #       language-servers = ["rust-analyzer"];
    #     }
    #
    #     # TypeScript
    #     {
    #       name = "typescript";
    #       auto-format = true;
    #       language-servers = ["typescript-language-server"];
    #     }
    #     {
    #       name = "tsx";
    #       auto-format = true;
    #       language-servers = ["typescript-language-server"];
    #     }
    #
    #     # Terraform
    #     {
    #       name = "terraform";
    #       auto-format = true;
    #       language-servers = ["terraform-ls"];
    #     }
    #
    #     # YAML
    #     {
    #       name = "yaml";
    #       auto-format = true;
    #       language-servers = ["yaml-language-server"];
    #     }
    #
    #     # TOML
    #     {
    #       name = "toml";
    #       auto-format = true;
    #       language-servers = ["taplo"];
    #       formatter = {
    #         command = lib.getExe pkgs.taplo;
    #         args = ["format" "-"];
    #       };
    #     }
    #
    #     # Python
    #     {
    #       name = "python";
    #       auto-format = true;
    #       language-servers = ["pyright"];
    #       formatter = {
    #         command = lib.getExe pkgs.black;
    #         args = ["-"];
    #       };
    #     }
    #   ];
    # };

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
