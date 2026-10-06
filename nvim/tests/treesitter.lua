-- Run after parser installation has finished:
-- nvim --headless -c 'luafile nvim/tests/treesitter.lua'
local function check_treesitter()
  vim.v.errmsg = ''
  assert(vim.fn.executable('tree-sitter') == 1,
    'Missing tree-sitter CLI; on macOS run: brew install tree-sitter-cli')

  local languages = {
    'comment', 'lua', 'vim', 'vimdoc', 'markdown', 'markdown_inline',
    'go', 'python', 'javascript', 'typescript', 'tsx',
  }
  local installed = require('nvim-treesitter').get_installed('parsers')
  for _, lang in ipairs(languages) do
    assert(vim.list_contains(installed, lang), 'Parser not installed: ' .. lang)
    assert(vim.treesitter.language.add(lang), 'Cannot load parser: ' .. lang)
    local parser = vim.treesitter.get_string_parser('', lang)
    assert(parser:parse()[1], 'Cannot parse: ' .. lang)
    for _, query in ipairs({ 'highlights', 'injections', 'folds', 'indents', 'locals' }) do
      vim.treesitter.query.get(lang, query)
    end
  end

  -- Exercise the real FileType hook, highlighting, and fold evaluation.
  vim.cmd('enew')
  vim.api.nvim_buf_set_lines(0, 0, -1, false, {
    'local function example()', '  return "hello"', 'end',
  })
  vim.bo.filetype = 'lua'
  assert(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()],
    'Lua highlighting must be active')
  assert(vim.wo.foldmethod == 'expr', 'Lua must use Tree-sitter folding')
  vim.cmd('normal! zx')
  vim.cmd('redraw!')
  assert(vim.v.errmsg == '', vim.v.errmsg)
  print('PASS: Tree-sitter CLI, 11 parsers, queries, Lua highlighting and folding')
end

local passed, failure = pcall(check_treesitter)
if not passed then
  print(failure)
  vim.cmd('cquit 1')
end
vim.cmd('qa!')
