-- ============================================================================
-- Language-Specific Plugins
-- ============================================================================

local plugins = {}

local ts = require('config.treesitter')

-- Treesitter (only for Neovim 0.10+)
if ts.supported then
  table.insert(plugins, {
    "nvim-treesitter/nvim-treesitter", branch = 'master', lazy = false,
    build = ts.has_compiler and ":TSUpdate" or nil,
    config = function()
      require('nvim-treesitter.configs').setup({
        -- Both of these build parsers, so they stay off without a compiler.
        auto_install = ts.has_compiler,
        ensure_installed = ts.has_compiler and {
          'lua',
          'markdown',
          'markdown_inline',
          'html',
          'latex',
          'make',
          'yaml',
          'verilog',
        } or {},
        highlight = {
          enable = true,
          disable = function(lang, buf)
            -- Fallback to native syntax highlighting if parser not available
            local has_parser = pcall(vim.treesitter.language.inspect, lang)
            return not has_parser
          end,
        },
      })
    end,
  })
end

-- Markdown
local render_markdown_config = {
  'MeanderingProgrammer/render-markdown.nvim',
  -- Renders nothing without the markdown parsers, so do not install it then.
  enabled = ts.can_use('markdown') and ts.can_use('markdown_inline'),
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons', -- optional, for icons
    'nvim-mini/mini.nvim',
  },
  opts = {
    heading = { sign = false },
    html = { enabled = false },
    latex = { enabled = false },
    yaml = { enabled = false },
  },
}

table.insert(plugins, render_markdown_config)

-- SystemVerilog
table.insert(plugins, {
  "nachumk/systemverilog.vim",
  ft = { "systemverilog", "verilog" },
})

-- Add PowerShell plugin only on Windows
if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
  table.insert(plugins, {
    "PProvost/vim-ps1",
    ft = "ps1",
  })
end

return plugins
