-- All LSP servers are provided by Nix packages.
-- Setting mason = false prevents mason-lspconfig from trying (and failing)
-- to install them on NixOS's immutable filesystem.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nil_ls                         = { mason = false },
        rust_analyzer                  = { mason = false },
        gopls                          = { mason = false },
        basedpyright                   = { mason = false },
        omnisharp                      = { mason = false },
        clangd                         = { mason = false },
        ts_ls                          = { mason = false },
        jsonls                         = { mason = false },
        html                           = { mason = false },
        cssls                          = { mason = false },
        kotlin_language_server         = { mason = false },
        terraformls                    = { mason = false },
        yamlls                         = { mason = false },
        taplo                          = { mason = false },
        marksman                       = { mason = false },
        lua_ls                         = { mason = false },
        bashls                         = { mason = false },
        dockerls                       = { mason = false },
        docker_compose_language_service = { mason = false },
        fsautocomplete                 = { mason = false },
        sqls                           = { mason = false },
        qmlls                          = { mason = false },
      },
    },
  },
}
