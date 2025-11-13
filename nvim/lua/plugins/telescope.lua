-- ============================================================================
-- Telescope Configuration
-- ============================================================================

return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-lua/popup.nvim",
      "nvim-telescope/telescope-live-grep-args.nvim",
    },
    cmd = "Telescope",
    keys = {
      { "<leader>tf", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>tb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
      { "<leader>th", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      { "<leader>tg", "<cmd>Telescope live_grep_args<cr>", desc = "Live grep with args" },
      {
        "<leader>tt",
        function()
          require("telescope.builtin").tags({ default_text = vim.fn.expand("<cword>") })
        end,
        desc = "Find tag under cursor",
      },
    },
    config = function()
      local telescope = require("telescope")
      
      telescope.setup({
        defaults = {
          prompt_prefix = "🔍 ",
          selection_caret = "➜ ",
          path_display = { "truncate" },
          mappings = {
            i = {
              ["<C-u>"] = false,
              ["<C-d>"] = false,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            follow = true,
          },
        },
      })
      
      -- Load extensions
      telescope.load_extension("live_grep_args")
    end,
  },
}
