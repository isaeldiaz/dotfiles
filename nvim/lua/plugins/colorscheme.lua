-- ============================================================================
-- Colorscheme Configuration
-- ============================================================================

return {
  {
    "flazz/vim-colorschemes",
    lazy = false,
    priority = 1000, -- Load before other plugins
    config = function()
      -- Set colorscheme
      vim.cmd("colorscheme wombat")
      vim.opt.background = "dark"
      
      -- The transparent background is handled in autocmds.lua
    end,
  },
}
