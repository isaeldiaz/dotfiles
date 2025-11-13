-- ============================================================================
-- Navigation Plugins
-- ============================================================================

return {
  -- File explorer
  {
    "scrooloose/nerdtree",
    keys = {
      { "<F2>", "<cmd>NERDTreeToggle<cr>", desc = "Toggle NERDTree" },
      { "<F3>", "<cmd>NERDTreeFind %<cr>", desc = "Find current file in NERDTree" },
      { "<leader><F2>", "<cmd>NERDTreeFocus<cr>", desc = "Focus NERDTree" },
    },
    config = function()
      vim.g.NERDTreeShowLineNumbers = 1
    end,
  },

  -- Easy motion
  {
    "easymotion/vim-easymotion",
    keys = {
      { "<leader>w", "<Plug>(easymotion-bd-w)", desc = "EasyMotion word" },
      { "<leader>f", "<Plug>(easymotion-bd-f)", desc = "EasyMotion find char" },
      { "<leader>s", "<Plug>(easymotion-overwin-f2)", desc = "EasyMotion 2-char search" },
    },
  },

  -- Seamless tmux navigation
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>" },
    },
  },
}
