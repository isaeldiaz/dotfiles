-- ============================================================================
-- Main Neovim Configuration Entry Point
-- ============================================================================
-- This file loads all configuration modules in the correct order

-- Set leader key FIRST, before any plugins are loaded
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap lazy.nvim plugin manager
require("config.lazy")

-- Load core configurations
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Platform-specific settings
if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
  require("config.windows")
end
