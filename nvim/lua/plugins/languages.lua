-- ============================================================================
-- Language-Specific Plugins
-- ============================================================================

return {
  -- Markdown
  {
    "plasticboy/vim-markdown",
    ft = "markdown",
    config = function()
      vim.g.vim_markdown_conceal = 0
      vim.g.vim_markdown_math = 1
      vim.g.vim_markdown_frontmatter = 1
    end,
  },

  -- SystemVerilog
  {
    "nachumk/systemverilog.vim",
    ft = { "systemverilog", "verilog" },
  },

  -- PowerShell (Windows only)
  vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
    and {
      "PProvost/vim-ps1",
      ft = "ps1",
    }
    or {},
}
