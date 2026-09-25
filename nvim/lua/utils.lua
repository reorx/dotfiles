local M = {}

-- Text of the current visual selection (charwise, linewise or blockwise), with
-- the lines joined without newlines. Call it in visual mode; unlike yanking
-- the selection, it leaves all registers untouched.
function M.get_visual_selection()
  local lines = vim.fn.getregion(vim.fn.getpos('v'), vim.fn.getpos('.'), { type = vim.fn.mode() })
  return table.concat(lines, '')
end

return M
