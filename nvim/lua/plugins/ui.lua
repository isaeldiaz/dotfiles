-- ============================================================================
-- UI and Appearance Plugins
-- ============================================================================

return {
  -- Statusline
  {
    "vim-airline/vim-airline",
    dependencies = {
      "vim-airline/vim-airline-themes",
    },
    config = function()
      vim.g.airline_theme = "distinguished"
      -- Enable powerline fonts if available
      vim.g.airline_powerline_fonts = 1
    end,
  },

  -- Show marks in sign column
  {
    "kshenoy/vim-signature",
    event = "VeryLazy",
  },

  -- Line number toggling
  {
    "jeffkreeftmeijer/vim-numbertoggle",
    event = "VeryLazy",
  },
}
