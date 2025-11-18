-- ============================================================================
-- Language-Specific Plugins
-- ============================================================================

local plugins = {

  -- Treesitter
  {"nvim-treesitter/nvim-treesitter", branch = 'master', lazy = false, build = ":TSUpdate"},

  -- Markdown
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },            -- if you use the mini.nvim suite
    opts = {
      heading = { sign = false },
    },
},

  -- SystemVerilog
  {
    "nachumk/systemverilog.vim",
    ft = { "systemverilog", "verilog" },
  },
}

-- Add PowerShell plugin only on Windows
if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
  table.insert(plugins, {
    "PProvost/vim-ps1",
    ft = "ps1",
  })
end

return plugins
