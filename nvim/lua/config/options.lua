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

-- Clipboard. Only couple the unnamed register to the OS clipboard when a real
-- local clipboard is present (an X11/Wayland display, or Neovide). Over SSH --
-- or on any headless box -- there is no display, so xclip/wl-paste cannot
-- work; with 'clipboard=unnamedplus' every `p` then round-trips through a
-- broken provider that returns plain lines, silently destroying blockwise
-- registers. (Plain Vim works because its default 'clipboard' is empty, so
-- `p` always reads the unnamed register directly.) Keep the unnamed register
-- local in that case and mirror yanks to "+" so OSC 52 still carries them to
-- the host clipboard (tmux forwards it via set-clipboard on). Text copied
-- outside Neovim is pasted with the terminal's own Ctrl+Shift+V.
local has_display = (vim.env.DISPLAY or vim.env.WAYLAND_DISPLAY) ~= nil
local over_ssh = (vim.env.SSH_TTY or vim.env.SSH_CONNECTION) ~= nil
local use_unnamedplus = has_display or vim.g.neovide
opt.clipboard = use_unnamedplus and "unnamedplus" or ""
if over_ssh and not use_unnamedplus and vim.fn.has("nvim-0.10") == 1 then
  local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
  if ok then
    vim.g.clipboard = {
      name = "OSC 52",
      copy = {
        ["+"] = osc52.copy("+"),
        ["*"] = osc52.copy("*"),
      },
      -- Only reached by an explicit `"+p`/`"*p`. Read back the last yank,
      -- keeping its register type, instead of a terminal round-trip.
      paste = {
        ["+"] = function() return vim.split(vim.fn.getreg('"'), "\n"), vim.fn.getregtype('"') end,
        ["*"] = function() return vim.split(vim.fn.getreg('"'), "\n"), vim.fn.getregtype('"') end,
      },
    }
    vim.api.nvim_create_autocmd("TextYankPost", {
      callback = function()
        local t = vim.v.event.regtype
        if t == "" then
          return
        end
        vim.fn.setreg("+", vim.split(vim.fn.getreg('"'), "\n", { plain = true }), t)
      end,
      desc = "Mirror yanks to host clipboard over SSH",
    })
  end
end

-- Grep program
if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --smart-case --hidden"
  opt.grepformat = "%f:%l:%c:%m"
end

opt.inccommand = "split" -- Show live preview of substitutions
