-- ============================================================================
-- Language-Specific Plugins
-- ============================================================================

local plugins = {

  -- Treesitter
  {"nvim-treesitter/nvim-treesitter", branch = 'master', lazy = false, build = ":TSUpdate",
    opts = {
      ensure_installed = { 
        'markdown', 
        'markdown_inline',
        'html',      -- add these if you want them
        'latex',
        'yaml',
      },
      highlight = {
        enable = true,
      },
    },
  },

  -- Markdown
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 
    'nvim-tree/nvim-web-devicons', -- optional, for icons
    'nvim-mini/mini.nvim' },            -- if you use the mini.nvim suite
    opts = {
      heading = { sign = false },
      html = { enabled = false },
      latex = { enabled = false },
      yaml = { enabled = false },
    },
    config = function(_, opts)
	    require('render-markdown').setup(opts)

	    -- Enable treesitter highlighting for markdown
	    vim.api.nvim_create_autocmd('FileType', {
		    pattern = 'markdown',
		    callback = function()
			    vim.treesitter.start()
		    end,
	    })
    end,
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
