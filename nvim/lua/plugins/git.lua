-- ============================================================================
-- Git Integration Plugins
-- ============================================================================

return {
  -- Fugitive - Git wrapper (staging, committing, blame, push/pull)
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse" },
    keys = {
      { "<leader>gs", "<cmd>Git<cr>",        desc = "Git status (fugitive)" },
      { "<leader>gc", "<cmd>Git commit<cr>", desc = "Git commit" },
      { "<leader>gp", "<cmd>Git push<cr>",   desc = "Git push" },
      { "<leader>gl", "<cmd>Git pull<cr>",   desc = "Git pull" },
      { "<leader>gd", "<cmd>Gdiffsplit<cr>", desc = "Git diff split (buffer)" },
      { "<leader>gb", "<cmd>Git blame<cr>",  desc = "Git blame (fugitive)" },
    },
    -- Note: fugitive_diff_tool only affects :Gdiffsplit — no conflict with diffview
    config = function()
      vim.g.fugitive_diff_tool = "vimdiff"
    end,
  },

  -- GitHub integration for fugitive (:GBrowse opens GitHub URLs)
  {
    "tpope/vim-rhubarb",
    dependencies = { "tpope/vim-fugitive" },
  },

  -- SVN integration
  {
    "juneedahamed/svnj.vim",
    cmd = { "SVNStatus", "SVNDiff", "SVNLog" },
  },

  -- -------------------------------------------------------------------------
  -- Diffview.nvim — comprehensive git diff & file history UI
  --
  -- Complements fugitive: use diffview for browsing diffs/history,
  -- fugitive for staging, committing, push/pull.
  -- vim-diff-enhanced still improves native :diff (vimdiff) sessions.
  -- -------------------------------------------------------------------------
  {
    "sindrets/diffview.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- icons in file panel
    },
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewFileHistory",
      "DiffviewRefresh",
    },
    keys = {
      -- Toggle: opens a diff against HEAD, or closes the view you're sitting in.
      -- get_current_view() is tab-local, so pressing this from a non-diffview
      -- tab opens a new view rather than closing an existing one.
      {
        "<leader>dd",
        function()
          local lib = require("diffview.lib")
          if lib.get_current_view() then
            vim.cmd("DiffviewClose")
          else
            vim.cmd("DiffviewOpen")
          end
        end,
        desc = "Diffview: toggle",
      },
      { "<leader>dv", "<cmd>DiffviewOpen<cr>",                desc = "Diffview: open (HEAD diff)" },
      { "<leader>dc", "<cmd>DiffviewClose<cr>",               desc = "Diffview: close" },
      { "<leader>dh", "<cmd>DiffviewFileHistory %<cr>",       desc = "Diffview: file history" },
      { "<leader>dH", "<cmd>DiffviewFileHistory<cr>",         desc = "Diffview: repo history" },
      { "<leader>dm", "<cmd>DiffviewOpen -uno<cr>",           desc = "Diffview: merge conflicts" },
      { "<leader>df", "<cmd>DiffviewToggleFiles<cr>",         desc = "Diffview: toggle file panel" },
      { "<leader>dr", "<cmd>DiffviewRefresh<cr>",             desc = "Diffview: refresh" },
    },
    -- Short aliases for the argument-taking commands (:DV master...HEAD).
    -- Defined at startup so they exist before the plugin loads; invoking the
    -- real command triggers lazy's cmd handler.
    init = function()
      local function alias(name, target)
        vim.api.nvim_create_user_command(name, function(o)
          vim.cmd(target .. " " .. o.args)
        end, {
          nargs = "*",
          complete = function(lead)
            return vim.fn.getcompletion(target .. " " .. lead, "cmdline")
          end,
        })
      end
      alias("DV", "DiffviewOpen")
      alias("DVH", "DiffviewFileHistory")
    end,
    config = function()
      require("diffview").setup({
        enhanced_diff_hl = true, -- richer diff highlights (requires nvim-treesitter)
        use_icons = true,

        view = {
          -- Side-by-side for normal diffs
          default = {
            layout = "diff2_horizontal",
            winbar_info = false,
          },
          -- 3-way layout for merge conflicts: LOCAL | BASE | REMOTE + MERGED below
          merge_tool = {
            layout = "diff3_horizontal",
            disable_diagnostics = true,
          },
          -- File history shows commit info in the winbar
          file_history = {
            layout = "diff2_horizontal",
            winbar_info = true,
          },
        },

        file_panel = {
          listing_style = "tree",
          tree_options = {
            flatten_dirs = true,
            folder_statuses = "only_folded",
          },
          win_config = {
            position = "left",
            width = 35,
          },
        },

        file_history_panel = {
          win_config = {
            position = "bottom",
            height = 16,
          },
        },

        hooks = {
          -- Clean up diff buffers: no wrap, no list chars, no colorcolumn
          diff_buf_read = function(_bufnr)
            vim.opt_local.wrap = false
            vim.opt_local.list = false
            vim.opt_local.colorcolumn = ""
          end,
        },
      })
    end,
  },

  -- -------------------------------------------------------------------------
  -- Gitsigns.nvim — in-buffer hunk signs, staging, inline blame
  --
  -- Works at the hunk level inside buffers; perfectly complementary to
  -- diffview (macro view) and fugitive (repo operations). No conflicts.
  -- -------------------------------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    -- Current gitsigns requires 0.11; on older Neovim its setup() throws.
    enabled = vim.fn.has("nvim-0.11") == 1,
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
        end

        -- Hunk navigation
        map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
        map("n", "[h", function() gs.nav_hunk("prev") end, "Prev hunk")

        -- Hunk staging / reset
        map("n", "<leader>ghs", gs.stage_hunk,   "Stage hunk")
        map("n", "<leader>ghr", gs.reset_hunk,   "Reset hunk")
        map("v", "<leader>ghs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage hunk (visual)")
        map("v", "<leader>ghr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset hunk (visual)")

        -- Buffer-level ops
        map("n", "<leader>ghS", gs.stage_buffer,     "Stage buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk,  "Undo stage hunk")
        map("n", "<leader>ghR", gs.reset_buffer,     "Reset buffer")

        -- Preview / blame
        map("n", "<leader>ghp", gs.preview_hunk,                              "Preview hunk")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame line (full)")
        map("n", "<leader>ghi", gs.toggle_current_line_blame,                 "Toggle inline blame")

        -- Diff current file against index / last commit
        map("n", "<leader>ghd", gs.diffthis,                       "Diff this (index)")
        map("n", "<leader>ghD", function() gs.diffthis("~") end,   "Diff this (~HEAD)")
      end,
    },
  },

  -- Enhanced diff algorithm for native vimdiff / :Gdiffsplit sessions.
  -- Sets patience/histogram algorithm; orthogonal to diffview (which has
  -- its own rendering pipeline). No conflicts.
  {
    "chrisbra/vim-diff-enhanced",
  },
}
