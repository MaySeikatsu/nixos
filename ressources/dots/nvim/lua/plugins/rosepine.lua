-- lua/plugins/rose-pine.lua
-- Rosé Pine moon. While the theming switch is on, the bridge (modules/home-manager/theming/kurashi.nix) writes
-- lua/kurashi/palette.lua from kurashi's colours; it is the same moon values until kurashi changes them.
return {
  "rose-pine/neovim",
  name = "rose-pine",
  config = function()
    local ok, palette = pcall(require, "kurashi.palette")
    require("rose-pine").setup({
      palette = ok and {moon = palette} or nil,
    })
    vim.cmd("colorscheme rose-pine-moon")
  end
}
