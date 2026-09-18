-- ============================================================================
-- Autocommands Configuration
-- ============================================================================

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ============================================================================
-- File Type Specific Settings
-- ============================================================================

-- Associate .flist files with bash filetype
autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.flist",
  callback = function()
    vim.bo.filetype = "bash"
  end,
  desc = "Set .flist files to bash filetype",
})

-- Associate .upf files with Tcl filetype
autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.upf",
  callback = function()
    vim.bo.filetype = "tcl"
  end,
  desc = "Set .upf files to Tcl filetype",
})

-- Remove ':' from word delimiter in Perl files
autocmd("FileType", {
  pattern = "perl",
  callback = function()
    vim.opt_local.iskeyword:remove(":")
  end,
  desc = "Remove : from Perl word delimiters",
})

-- Markdown settings: unfold all, and drop markdownError, which flags far too
-- much as an error. Only present when native syntax is driving highlighting.
autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.cmd("normal! zR") -- Unfold all
    vim.schedule(function()
      pcall(vim.cmd, "syntax clear markdownError")
    end)
  end,
  desc = "Markdown-specific settings",
})

-- ============================================================================
-- Colorscheme Settings (Background Transparency)
-- ============================================================================

local function set_transparent_bg()
  local groups = {
    "Normal",
    "NonText",
    "LineNr",
    "CursorLineNr",
    "SignColumn",
    "SignatureMarkText",
    "SignatureMarkerText",
    "NormalFloat",
    "FloatBorder",
    "NormalNC",
    "TelescopeNormal",
    "TelescopePreviewNormal",
    "TelescopePromptNormal",
    "TelescopeResultsNormal",
    "LazyNormal",
  }

  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
  end
end

-- Apply transparent background after colorscheme loads (skip in Neovide)
if not vim.g.neovide then
  autocmd("ColorScheme", {
    callback = set_transparent_bg,
    desc = "Set transparent background",
  })

  -- Apply it now for initial load
  set_transparent_bg()
end

-- ============================================================================
-- General Quality of Life
-- ============================================================================

-- Highlight on yank. 0.11 renamed vim.highlight to vim.hl; keep both working.
local hl = vim.hl or vim.highlight
autocmd("TextYankPost", {
  callback = function()
    hl.on_yank({ timeout = 200 })
  end,
  desc = "Briefly highlight yanked text",
})

-- Auto-create directories when saving files
autocmd("BufWritePre", {
  callback = function()
    local dir = vim.fn.expand("<afile>:p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
  desc = "Auto-create parent directories",
})

-- Close certain windows with 'q'
autocmd("FileType", {
  pattern = { "help", "man", "qf", "fugitive" },
  callback = function()
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true })
  end,
  desc = "Close with 'q'",
})

-- Restore cursor position
autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = "Restore cursor position",
})

-- ============================================================================
-- Neovide Settings
-- ============================================================================

if vim.g.neovide then
  vim.g.neovide_opacity = 0.85        -- 85% opaque (semi-transparent)
  vim.g.neovide_window_blurred = true -- Blur content behind window (Windows Acrylic / macOS vibrancy)
end
