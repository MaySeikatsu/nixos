{
  pkgs,
  lib,
  ...
}: {
  # imports = [
  #   # Import the nixCats module
  #   inputs.nixCats-nvim.homeModule
  # ];

  # Creates a wallust.lua file inside of ~/.config/wallust or overwrites it with the given values of the file included in the repo
  # xdg.configFile."./nvim/lua/plugins/wallust.lua".source = ../../../ressources/dos/nvim/lua/plugins/wallust.lua; #For neovim config to work with wallust

  # Check out https://github.com/pfassina/lazyvim-nix for flake that includes up to date lazyvim config

  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [lazy-nvim mini-surround];
    # Add extra packages as needed
    extraPackages = with pkgs; [
      lua-language-server
      stylua
      ripgrep
      rust-analyzer
      terraformls
      terraformfmt
      statix
      nil
      alejandra

      # Go
      gopls
      gofumpt
      golangci-lint

      # Python
      basedpyright
      ruff

      # C / C++
      clang-tools

      # C#
      omnisharp-roslyn
      csharpier

      # TypeScript / JavaScript
      typescript-language-server
      vscode-langservers-extracted
      prettierd
      eslint

      # Kotlin
      kotlin-language-server
      ktfmt
      ktlint

      # Config formats
      yaml-language-server
      taplo
      marksman

      # Bash / Shell
      bash-language-server
      shfmt
      shellcheck

      # Docker
      dockerfile-language-server
      docker-compose-language-service
      hadolint

      # .NET / F#
      fsautocomplete

      # SQL
      sqls
      sqlfluff
    ];
    extraLuaConfig = let
      plugins = with pkgs.vimPlugins; [
        # LazyVim
        LazyVim
        bufferline-nvim
        cmp-buffer
        cmp-nvim-lsp
        cmp-path
        cmp_luasnip
        conform-nvim
        dashboard-nvim
        dressing-nvim
        flash-nvim
        friendly-snippets
        gitsigns-nvim
        indent-blankline-nvim
        lualine-nvim
        neo-tree-nvim
        neoconf-nvim
        neodev-nvim
        noice-nvim
        nui-nvim
        nvim-cmp
        nvim-lint
        nvim-lspconfig
        nvim-notify
        nvim-spectre
        nvim-treesitter
        nvim-treesitter-context
        nvim-treesitter-textobjects
        nvim-ts-autotag
        nvim-ts-context-commentstring
        nvim-web-devicons
        persistence-nvim
        plenary-nvim
        telescope-fzf-native-nvim
        telescope-nvim
        todo-comments-nvim
        tokyonight-nvim
        trouble-nvim
        vim-illuminate
        vim-startuptime
        which-key-nvim
        {
          name = "LuaSnip";
          path = luasnip;
        }
        {
          name = "catppuccin";
          path = catppuccin-nvim;
        }
        {
          name = "mini.ai";
          path = mini-nvim;
        }
        {
          name = "mini.bufremove";
          path = mini-nvim;
        }
        {
          name = "mini.comment";
          path = mini-nvim;
        }
        {
          name = "mini.indentscope";
          path = mini-nvim;
        }
        {
          name = "mini.pairs";
          path = mini-nvim;
        }
        {
          name = "mini.surround";
          path = mini-nvim;
        }
      ];
      mkEntryFromDrv = drv:
        if lib.isDerivation drv
        then {
          name = "${lib.getName drv}";
          path = drv;
        }
        else drv;
      lazyPath = pkgs.linkFarm "lazy-plugins" (builtins.map mkEntryFromDrv plugins);
    in ''
      require("lazy").setup({
        defaults = {
          lazy = true,
        },
        dev = {
          -- reuse files from pkgs.vimPlugins.*
          path = "${lazyPath}",
          patterns = { "" },
          -- fallback to download
          fallback = true,
        },
        spec = {
          { "LazyVim/LazyVim", import = "lazyvim.plugins" },
          -- The following configs are needed for fixing lazyvim on nix
          -- force enable telescope-fzf-native.nvim
          { "nvim-telescope/telescope-fzf-native.nvim", enabled = true },
          -- disable mason.nvim, use programs.neovim.extraPackages
          { "williamboman/mason-lspconfig.nvim", enabled = false },
          { "williamboman/mason.nvim", enabled = false },
          -- import/override with your plugins
          { import = "plugins" },
          -- treesitter handled by xdg.configFile."nvim/parser", put this line at the end of spec to clear ensure_installed
          { "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = {} } },
        },
      })
    '';
  };

  # https://github.com/nvim-treesitter/nvim-treesitter#i-get-query-error-invalid-node-type-at-position
  xdg.configFile."nvim/parser".source = let
    parsers = pkgs.symlinkJoin {
      name = "treesitter-parsers";
      paths =
        (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins:
          with plugins; [
            c
            lua
          ])).dependencies;
    };
  in "${parsers}/parser";

  # Normal LazyVim config here, see https://github.com/LazyVim/starter/tree/main/lua
  xdg.configFile."nvim/lua".source = ./lua;
}
#     # nixCats will handle plugins and LazyVim setup
#   };
# }
#

