-- Auto-restore the nvim session for the current cwd when nvim is started
-- without file arguments. This is what makes zellij session resurrection
-- useful for nvim: zellij re-runs `nvim` in the saved cwd, and persistence
-- brings back the buffers/window layout for that directory.
-- persistence.nvim is already a LazyVim default plugin; this only adds the
-- auto-restore behavior (LazyVim only binds manual restore to <leader>qs).
return {
  {
    "folke/persistence.nvim",
    opts = {},
    init = function()
      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("zellij_restore_session", { clear = true }),
        callback = function()
          -- only when launched bare (no args) and not nested inside another nvim
          if vim.fn.argc() == 0 and not vim.env.NVIM then
            require("persistence").load()
          end
        end,
        nested = true,
      })
    end,
  },
}
