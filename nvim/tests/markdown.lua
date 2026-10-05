-- Run from the repository root:
-- nvim --headless -c 'luafile nvim/tests/markdown.lua'
local api = vim.api

local function check_markdown()
  local lines = {
    '# Markdown 中文测试',
    '',
    'prefix [中文链接](https://example.com/a/long/path) suffix',
    '',
    '- [x] 中文任务 **粗体** 和 `inline code`',
    '',
    '| 名称 | 值 |',
    '| --- | --- |',
    '| 中文 | value |',
    '',
    '```lua',
    'print("hello")',
    '```',
  }
  api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.bo.filetype = 'markdown'
  vim.wo.foldenable = false
  vim.wait(300)
  assert(vim.wo.conceallevel == 0, 'Markdown must show all source characters')
  assert(vim.treesitter.highlighter.active[api.nvim_get_current_buf()], 'syntax highlighting must stay active')
  assert(require('lazy.core.config').plugins['touchup.nvim']._.loaded, 'touchup must load for Markdown')
  assert(vim.fn.exists(':RenderMarkdown') == 0, 'old renderer must not load')

  local suffix_col = assert(lines[3]:find('suffix', 1, true))
  local positions = {}
  for _, row in ipairs({ 1, 3, 5, 7, 11 }) do
    api.nvim_win_set_cursor(0, { row, 0 })
    api.nvim_exec_autocmds('CursorMoved', { buffer = 0 })
    vim.wait(200)
    vim.cmd('redraw!')
    positions[#positions + 1] = vim.fn.screenpos(0, 3, suffix_col).col
  end
  for _, col in ipairs(positions) do
    assert(col == positions[1], 'Moving the cursor must not shift the link suffix')
  end

  -- Opening an existing Markdown buffer must restore the source view in this
  -- window too, not only when FileType first fires.
  local markdown_buf = api.nvim_get_current_buf()
  vim.cmd('new')
  vim.wo.conceallevel = 3
  api.nvim_win_set_buf(0, markdown_buf)
  assert(vim.wo.conceallevel == 0, 'Entering Markdown must reset window-local conceal')
  assert(vim.deep_equal(api.nvim_buf_get_lines(markdown_buf, 0, -1, false), lines), 'Decorations must not change source text')

  print('PASS: Markdown source stays visible, cursor movement is stable, highlighting remains active')
end

local passed, failure = pcall(check_markdown)
if not passed then
  print(failure)
  vim.cmd('cquit 1')
end
vim.cmd('qa!')
