-- ============================================================================
-- lazy.nvim Bootstrap and Setup
-- ============================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Auto-install lazy.nvim if not present
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Configure lazy.nvim
require("lazy").setup({
  spec = {
    -- Import all plugin specs from lua/plugins/
    { import = "plugins" },
  },
  defaults = {
    lazy = false, -- Don't lazy-load by default
    version = false, -- Use latest git commit, not releases
  },
  install = { colorscheme = { "tokyonight" } },
  checker = { enabled = false }, -- Don't automatically check for updates
  -- Git configuration to prevent Windows line-ending issues
  git = {
    timeout = 300,
    url_format = "https://github.com/%s.git",
    filter = false,
    -- FIX: Prevent Git from converting line endings on Windows
    -- This stops the "local changes" error when updating plugins
    config = {
      ["core.autocrlf"] = "false",
    },
  },
  performance = {
    rtp = {
      -- Disable some rtp plugins
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

