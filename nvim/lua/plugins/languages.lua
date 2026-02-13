-- ============================================================================
-- Language-Specific Plugins
-- ============================================================================

local plugins = {}

-- Check Neovim version
local nvim_version = vim.version()
local is_nvim_10_plus = nvim_version.major > 0 or (nvim_version.major == 0 and nvim_version.minor >= 10)

-- Treesitter (only for Neovim 0.10+)
if is_nvim_10_plus then
  table.insert(plugins, {
    "nvim-treesitter/nvim-treesitter", branch = 'master', lazy = false, build = ":TSUpdate",
    config = function()
      require('nvim-treesitter.configs').setup({
        auto_install = true,
        ensure_installed = {
          'lua',
          'markdown',
          'markdown_inline',
          'html',
          'latex',
          'yaml',
          'verilog',
        },
        highlight = {
          enable = true,
          disable = function(lang, buf)
            -- Fallback to native syntax highlighting if parser not available
            local has_parser = pcall(vim.treesitter.language.inspect, lang)
            return not has_parser
          end,
        },
      })

      -- Gracefully handle missing parsers - don't error out
      vim.api.nvim_create_autocmd('FileType', {
        pattern = '*',
        callback = function()
          local has_parser = pcall(vim.treesitter.language.inspect, vim.bo.filetype)
          if has_parser then
            pcall(vim.treesitter.start)
          end
        end,
      })
    end,
  })
end

-- Markdown
local render_markdown_config = {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = is_nvim_10_plus and { 'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons', -- optional, for icons
    'nvim-mini/mini.nvim' } or { 'nvim-tree/nvim-web-devicons', 'nvim-mini/mini.nvim' },
  opts = {
    heading = { sign = false },
    html = { enabled = false },
    latex = { enabled = false },
    yaml = { enabled = false },
  },
  config = function(_, opts)
	  require('render-markdown').setup(opts)

	  -- Enable treesitter highlighting for markdown (only on Neovim 0.10+)
	  if is_nvim_10_plus then
		  vim.api.nvim_create_autocmd('FileType', {
			  pattern = 'markdown',
			  callback = function()
				  local has_parser = pcall(vim.treesitter.language.inspect, 'markdown')
				  if has_parser then
					  vim.treesitter.start()
				  end
			  end,
		  })
	  end
  end,
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
