-- ============================================================================
-- Vim Options Configuration
-- ============================================================================

local opt = vim.opt

-- Terminal and GUI settings
opt.termguicolors = true -- Enable true color support
-- Mouse always on. WezTerm's bypass_mouse_reporting_modifiers = 'SHIFT' means a
-- plain drag is an nvim visual selection (yank with "y" -> OSC 52 -> Windows
-- clipboard) while Shift+drag hands the event to WezTerm's own selection, so
-- there is no longer any reason to disable it over SSH. Toggle with <M-m>.
opt.mouse = "a"
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

-- Clipboard: only over SSH, where there is no local clipboard tool, use OSC 52
-- so yanks reach the host OS clipboard (tmux forwards it via set-clipboard on).
-- Locally the standard providers already do, so leave vim.g.clipboard alone.
opt.clipboard = "unnamedplus"
if (vim.env.SSH_TTY or vim.env.SSH_CONNECTION) and not vim.g.neovide and vim.fn.has("nvim-0.10") == 1 then
  local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
  if ok then
    -- OSC 52 paste requires a terminal round-trip that hangs over plain SSH, so
    -- read back the last yank instead (returning nil makes every `p` fail with
    -- "clipboard: provider returned invalid data"). Use the terminal's own
    -- paste, Ctrl+Shift+V in WezTerm, for text copied outside Neovim.
    local function paste()
      return vim.split(vim.fn.getreg('"'), "\n")
    end
    vim.g.clipboard = {
      name = "OSC 52",
      copy = {
        ["+"] = osc52.copy("+"),
        ["*"] = osc52.copy("*"),
      },
      paste = {
        ["+"] = paste,
        ["*"] = paste,
      },
    }
  end
end

-- Grep program
if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --smart-case --hidden"
  opt.grepformat = "%f:%l:%c:%m"
end

opt.inccommand = "split" -- Show live preview of substitutions
