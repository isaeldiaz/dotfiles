-- ============================================================================
-- Treesitter Availability
-- ============================================================================
-- nvim-treesitter builds parsers with a C compiler. Without one, installing a
-- parser raises from a FileType autocmd, which aborts the rest of that chain --
-- including the runtime's own `set syntax=<ft>`. The buffer then gets no
-- highlighting at all rather than falling back to native syntax, so everything
-- that needs a parser is gated on the checks below.

local M = {}

-- nvim-treesitter's master branch supports Neovim 0.10 and 0.11 only. On 0.12
-- it needs the main branch, which is a different API -- until then treesitter
-- stays off there rather than breaking.
M.supported = vim.fn.has("nvim-0.10") == 1 and vim.fn.has("nvim-0.12") == 0

M.has_compiler = false
for _, cc in ipairs({ "cc", "gcc", "clang", "cl", "zig" }) do
  if vim.fn.executable(cc) == 1 then
    M.has_compiler = true
    break
  end
end

-- Plugin specs are evaluated before lazy.nvim puts nvim-treesitter on the
-- runtimepath, so its install directory has to be searched separately.
local parser_dir = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/parser/"

---@param lang string
---@return boolean
function M.has_parser(lang)
  if #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) > 0 then
    return true
  end
  return vim.fn.glob(parser_dir .. lang .. ".*") ~= ""
end

-- A parser is usable when it is already built, or when we can build it.
---@param lang string
---@return boolean
function M.can_use(lang)
  return M.supported and (M.has_compiler or M.has_parser(lang))
end

return M
