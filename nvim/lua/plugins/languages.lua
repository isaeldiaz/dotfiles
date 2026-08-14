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
          'make',
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
-- Word-wrapped tables. Upstream render-markdown has no option for this (see
-- issue #616), so this tracks MaxDillon's open PR #617 (table cell wrapping),
-- pinned to a commit, plus a local patch that makes wrapped cells break at word
-- boundaries instead of mid-word.
--
-- `:Lazy update` will show this plugin as dirty -- that is the patch, and the
-- commit pin means there is nothing to update anyway.
--
-- To revert to upstream: delete url/branch/commit/build and the pipe_table line
-- below, restore the lazy-lock.json entry, then `:Lazy sync`.
local render_markdown_config = {
  'MeanderingProgrammer/render-markdown.nvim',
  url = 'https://github.com/MaxDillon/render-markdown.nvim.git',
  branch = 'feat/table-cell-wrapping',
  commit = '1da76861f4d2ae27bcb5fff2a81fae9aa1d68dda',
  build = function(plugin)
    local patch = vim.fn.stdpath('config') .. '/patches/render-markdown-table-wordwrap.patch'
    local function git(args)
      local cmd = { 'git', '-C', plugin.dir }
      vim.list_extend(cmd, args)
      vim.fn.system(cmd)
      return vim.v.shell_error
    end
    -- A successful reverse-check means it is already applied, so re-running
    -- this hook is a no-op.
    if git({ 'apply', '--reverse', '--check', patch }) == 0 then
      return
    end
    assert(git({ 'apply', '--3way', patch }) == 0,
      'render-markdown word-wrap patch failed to apply: ' .. patch)
  end,
  dependencies = is_nvim_10_plus and { 'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons', -- optional, for icons
    'nvim-mini/mini.nvim' } or { 'nvim-tree/nvim-web-devicons', 'nvim-mini/mini.nvim' },
  opts = {
    heading = { sign = false },
    html = { enabled = false },
    latex = { enabled = false },
    yaml = { enabled = false },
    -- Fit tables to the window; requires virtual lines, so 0.10+ only.
    pipe_table = is_nvim_10_plus and { max_table_width = 1.0 } or nil,
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
