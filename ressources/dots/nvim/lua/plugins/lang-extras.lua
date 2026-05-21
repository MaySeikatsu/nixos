return {
  -- Bash language server — no LazyVim extra exists
  -- Kotlin and SQL are handled by lazyvim.json extras
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bashls = {
          filetypes = { "sh", "bash" },
          mason = false, -- provided by Nix
        },
        -- QML (QuickShell)
        qmlls = {
          cmd = { "/run/current-system/sw/bin/qmlls" },
          filetypes = { "qml", "qmljs" },
        },
        -- HCL: extend terraform-ls filetypes to also cover standalone .hcl files
        terraformls = {
          filetypes = { "terraform", "tf", "terraform-vars", "hcl" },
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, {
        "bash",
        "hcl",
        "qmljs",
      })
    end,
  },
}
