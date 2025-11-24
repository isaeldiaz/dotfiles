-- ============================================================================
-- Vim Options Configuration
-- ============================================================================

local opt = vim.opt

-- Terminal and GUI settings
opt.termguicolors = true -- Enable true color support
opt.mouse = vim.g.neovide and "a" or "" -- Enable mouse on Neovide, disable otherwise (toggle with <M-m>)
opt.mousehide = false -- Don't hide mouse when typing

-- Indentation settings
opt.expandtab = true -- Use spaces instead of tabs
opt.tabstop = 2 -- Number of spaces tabs count for
opt.shiftwidth = 2 -- Size of an indent
opt.smartindent = true -- Insert indents automatically

-- Search settings
opt.hlsearch = true -- Highlight search results
opt.ignorecase = true -- Ignore case in search
opt.smartcase = true -- Unless uppercase is used

-- UI settings
opt.number = false -- Don't Show line numbers
opt.relativenumber = false -- Don't Show relative line numbers
opt.signcolumn = "yes" -- Always show sign column
opt.cursorline = false -- Don't highlight current line
opt.wrap = true -- Wrap lines
opt.scrolloff = 8 -- Keep 8 lines above/below cursor

-- Split windows
opt.splitright = true -- Vertical splits go right
opt.splitbelow = true -- Horizontal splits go below

-- Invisible characters (use :set list to enable)
opt.listchars = {
  space = "·",
  tab = "→ ",
  eol = "↲",
  nbsp = "␣",
  trail = "•",
  extends = "⟩",
  precedes = "⟨",
}

-- Diff options
opt.diffopt:append("algorithm:patience")

-- File handling
opt.backup = false -- Don't create backup files
opt.swapfile = false -- Don't create swap files
opt.undofile = true -- Enable persistent undo
opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- Performance
opt.updatetime = 250 -- Faster completion
opt.timeoutlen = 300 -- Faster key sequence completion

-- Clipboard (using OSC52 for remote sessions)
opt.clipboard = "unnamedplus"

-- Grep program
if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --smart-case --hidden"
  opt.grepformat = "%f:%l:%c:%m"
end

-- Enable filetype detection and indentation
vim.cmd("filetype indent on")

-- Neovim-specific settings
if vim.fn.has("nvim") == 1 then
  opt.inccommand = "split" -- Show live preview of substitutions
end
