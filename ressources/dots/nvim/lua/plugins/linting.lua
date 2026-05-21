return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        sh         = { "shellcheck" },
        bash       = { "shellcheck" },
        dockerfile = { "hadolint" },
      },
    },
  },
}
