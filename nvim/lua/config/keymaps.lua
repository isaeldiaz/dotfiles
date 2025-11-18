-- ============================================================================
-- Key Mappings Configuration
-- ============================================================================

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ============================================================================
-- Terminal Mode
-- ============================================================================
-- Escape to leave terminal mode
keymap("t", "<Esc>", "<C-\\><C-n>", opts)

-- ============================================================================
-- Mouse Support Toggle
-- ============================================================================
local mouse_enabled = false
local function toggle_mouse_support()
  if mouse_enabled then
    vim.opt.mouse = ""
    mouse_enabled = false
    print("Mouse support OFF")
  else
    vim.opt.mouse = "a"
    mouse_enabled = true
    print("Mouse support ON")
  end
end

keymap("n", "<M-m>", toggle_mouse_support, { desc = "Toggle mouse support" })

-- ============================================================================
-- Number Toggle (cycles through: number+relative -> number only -> none)
-- ============================================================================
local function toggle_numbers()
  if vim.opt.number:get() then
    if vim.opt.relativenumber:get() then
      vim.opt.relativenumber = false
    else
      vim.opt.number = false
      vim.opt.relativenumber = false
    end
  else
    vim.opt.number = true
    vim.opt.relativenumber = true
  end
end

keymap("n", "<C-n>", toggle_numbers, { desc = "Toggle line numbers" })

-- ============================================================================
-- Font Size Adjustment (for GUI/Neovide)
-- ============================================================================
local fontsize = 11
local fonttype = vim.fn.has("win32") == 1 
  and "JetBrainsMono Nerd Font,Consolas:h" 
  or "JetBrainsMono Nerd Font,Monospace:h"

local function adjust_font_size(amount)
  fontsize = fontsize + amount
  if vim.g.neovide then
    vim.opt.guifont = fonttype .. fontsize
  else
    vim.cmd("GuiFont! " .. fonttype .. fontsize)
  end
end

keymap("n", "<C-ScrollWheelUp>", function() adjust_font_size(1) end, { desc = "Increase font size" })
keymap("n", "<C-ScrollWheelDown>", function() adjust_font_size(-1) end, { desc = "Decrease font size" })
keymap("i", "<C-ScrollWheelUp>", function() adjust_font_size(1) end, { desc = "Increase font size" })
keymap("i", "<C-ScrollWheelDown>", function() adjust_font_size(-1) end, { desc = "Decrease font size" })

-- Set initial font for Neovide
if vim.g.neovide then
  vim.opt.guifont = fonttype .. fontsize
end

-- ============================================================================
-- Better Navigation
-- ============================================================================
-- Resize windows
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Better indenting
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move lines up/down
keymap("n", "<A-j>", ":m .+1<CR>==", opts)
keymap("n", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)

-- Clear search highlight
keymap("n", "<Esc>", ":noh<CR>", { desc = "Clear search highlight" })

-- Better paste (don't yank replaced text)
keymap("v", "p", '"_dP', opts)

-- ============================================================================
-- Quick Commands
-- ============================================================================
-- Quick save
keymap("n", "<C-s>", ":w<CR>", { desc = "Save file" })
keymap("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Save file" })

-- Quick quit
keymap("n", "<leader>q", ":q<CR>", { desc = "Quit" })
keymap("n", "<leader>Q", ":qa!<CR>", { desc = "Quit all without saving" })

-- Help for this config
keymap("n", "<F10>", ":help brody-vim-config<CR>", { desc = "Show config help" })
