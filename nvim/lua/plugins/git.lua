-- ============================================================================
-- Git Integration Plugins
-- ============================================================================

return {
  -- Fugitive - Git wrapper
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse" },
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git status" },
      { "<leader>gc", "<cmd>Git commit<cr>", desc = "Git commit" },
      { "<leader>gp", "<cmd>Git push<cr>", desc = "Git push" },
      { "<leader>gl", "<cmd>Git pull<cr>", desc = "Git pull" },
      { "<leader>gd", "<cmd>Gdiffsplit<cr>", desc = "Git diff" },
      { "<leader>gb", "<cmd>Git blame<cr>", desc = "Git blame" },
    },
    config = function()
      vim.g.fugitive_diff_tool = "vimdiff"
    end,
  },

  -- GitHub integration for fugitive
  {
    "tpope/vim-rhubarb",
    dependencies = { "tpope/vim-fugitive" },
  },

  -- SVN integration
  {
    "juneedahamed/svnj.vim",
    cmd = { "SVNStatus", "SVNDiff", "SVNLog" },
  },

  -- Diff view
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>dv", "<cmd>DiffviewOpen<cr>", desc = "Open diff view" },
      { "<leader>dc", "<cmd>DiffviewClose<cr>", desc = "Close diff view" },
      { "<leader>dh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
    },
  },

  -- Enhanced diff algorithm
  {
    "chrisbra/vim-diff-enhanced",
  },
}
