-- ============================================================================
-- Colorscheme Configuration
-- ============================================================================

return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000, -- Load before other plugins
    config = function()
      -- Set tokyonight with moon variant (darker, more contrast)
      require("tokyonight").setup({
        style = "moon", -- moon, storm, or night
        transparent = false, -- Allow transparent background (handled in autocmds)
        terminal_colors = true,
      })
      vim.cmd("colorscheme tokyonight")
      vim.opt.background = "dark"

      -- The transparent background is handled in autocmds.lua
    end,
  },
}
