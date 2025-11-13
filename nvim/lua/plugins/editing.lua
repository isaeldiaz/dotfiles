-- ============================================================================
-- Editing and Convenience Plugins
-- ============================================================================

return {
  -- Surround text objects
  {
    "tpope/vim-surround",
    event = "VeryLazy",
  },

  -- Commenting
  {
    "scrooloose/nerdcommenter",
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Toggle comment" },
      { "<leader>cc", mode = { "n", "v" }, desc = "Comment" },
      { "<leader>cu", mode = { "n", "v" }, desc = "Uncomment" },
    },
  },

  -- Easy alignment
  {
    "junegunn/vim-easy-align",
    keys = {
      { "ga", "<Plug>(EasyAlign)", mode = { "n", "x" }, desc = "Align" },
      { "<Enter>", "<Plug>(EasyAlign)", mode = "v", desc = "Align" },
    },
  },

  -- Visual increment
  {
    "triglav/vim-visual-increment",
    keys = {
      { "<C-a>", mode = "v" },
      { "<C-x>", mode = "v" },
    },
  },

  -- Enhanced matchup (%, g%, etc.)
  {
    "andymass/vim-matchup",
    event = "VeryLazy",
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },

  -- Line diff
  {
    "AndrewRadev/linediff.vim",
    cmd = "Linediff",
  },

  -- Mark text with colors
  {
    "inkarkat/vim-mark",
    dependencies = {
      "inkarkat/vim-ingo-library",
    },
    keys = {
      { "<leader>m", mode = { "n", "v" } },
    },
  },

  -- OSC52 clipboard integration (for remote sessions)
  {
    "ojroques/nvim-osc52",
    config = function()
      require("osc52").setup({
        max_length = 0, -- No limit
        silent = false,
        trim = false,
      })
    end,
  },

  -- Calculator
  {
    "isaeldiaz/calc.nvim",
    cmd = "Calc",
    config = function()
      require("calc").setup()
    end,
  },
}
