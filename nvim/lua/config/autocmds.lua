-- ============================================================================
-- Autocommands Configuration
-- ============================================================================

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ============================================================================
-- File Type Specific Settings
-- ============================================================================

-- Associate .r files with XML syntax
autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.r",
  callback = function()
    vim.bo.filetype = "xml"
  end,
  desc = "Set .r files to XML filetype",
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

-- Markdown settings: unfold all and clear HTML tags
autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.cmd("normal! zR") -- Unfold all
    vim.cmd("syn clear htmlTag")
    vim.cmd("syn clear htmlEndTag")
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
  }
  
  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
  end
end

-- Apply transparent background after colorscheme loads
autocmd("ColorScheme", {
  callback = set_transparent_bg,
  desc = "Set transparent background",
})

-- Apply it now for initial load
set_transparent_bg()

-- ============================================================================
-- Clipboard Integration (OSC52)
-- ============================================================================

autocmd("TextYankPost", {
  callback = function()
    if vim.v.event.operator == "y" and vim.v.event.regname == "+" then
      vim.cmd("OSCYankReg +")
    end
  end,
  desc = "Copy to system clipboard using OSC52",
})

-- ============================================================================
-- General Quality of Life
-- ============================================================================

-- Highlight on yank
autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
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
