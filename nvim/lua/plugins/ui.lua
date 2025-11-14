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
      vim.g.airline_theme = "deus"
      -- Enable powerline fonts if available
      vim.g.airline_powerline_fonts = 1

      -- Manually set Nerd Font symbols using vim.fn.nr2char
      vim.cmd([[
      if !exists('g:airline_symbols')
        let g:airline_symbols = {}
        endif

        " Powerline symbols
        let g:airline_left_sep = nr2char(0xe0b0)
        let g:airline_left_alt_sep = nr2char(0xe0b1)
        let g:airline_right_sep = nr2char(0xe0b2)
        let g:airline_right_alt_sep = nr2char(0xe0b3)
        let g:airline_symbols.branch = nr2char(0xe0a0)
        let g:airline_symbols.readonly = nr2char(0xe0a2)
        let g:airline_symbols.linenr = nr2char(0xe0a1)
        let g:airline_symbols.maxlinenr = nr2char(0xe0a1)
        let g:airline_symbols.dirty = nr2char(0x26a1)
        ]])
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
