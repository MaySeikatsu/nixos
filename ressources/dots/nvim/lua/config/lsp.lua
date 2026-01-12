-- ~/.config/nvim/lua/config/lsp.lua
local lspconfig = require("lspconfig")

lspconfig.nil_ls.setup({
  on_attach = function(client, bufnr)
    -- Your on_attach function (keymaps, etc.)
  end,
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
  -- Optional: specify the path to nil if not in PATH
  -- cmd = { "nil" },
  cmd = { "nil" },
  filetypes = { "nix" },
})

-- local null_ls = require("null-ls")
-- null_ls.setup({
--   sources = {
--     null_ls.builtins.diagnostics.statix.with({
--       command = "statix", -- or full path, e.g., "/run/current-system/sw/bin/statix"
--     }),
--   },
-- })
