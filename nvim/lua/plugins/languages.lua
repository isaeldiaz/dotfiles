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
  })
end

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
