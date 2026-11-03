return {
  {
    "mason-org/mason.nvim",
    enabled = true,
    -- Nix-provided tools (programs.neovim.extraPackages) win over mason's:
    -- mason binaries built against an old /nix/store glibc break after GC.
    opts = { PATH = "append" },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    enabled = true,
  },
}
