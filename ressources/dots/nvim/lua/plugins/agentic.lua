return {
  {
    "carlos-algms/agentic.nvim",

    opts = {
      -- Available by default: "claude-acp" | "gemini-acp" | "codex-acp" | "opencode-acp" | "cursor-acp"
      -- provider = "gemini-acp", -- setting the name here is all you need to get started
      provider = "opencode-acp", -- setting the name here is all you need to get started
      -- provider = "codex-acp", -- setting the name here is all you need to get started
    },

    -- these are just suggested keymaps; customize as desired
    keys = {
      {
        "<C-\\>",
        function()
          require("agentic").toggle()
        end,
        mode = { "n", "v", "i" },
        desc = "Toggle Agentic Chat",
      },
      {
        "<C-'>",
        function()
          require("agentic").add_selection_or_file_to_context()
        end,
        mode = { "n", "v" },
        desc = "Add file or selection to Agentic to Context",
      },
      {
        "<C-,>",
        function()
          require("agentic").new_session()
        end,
        mode = { "n", "v", "i" },
        desc = "New Agentic Session",
      },
    },
  },
}
