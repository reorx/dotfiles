-- Run from the repository root:
-- nvim --headless -c 'luafile nvim/tests/nvim_tree.lua'
--
-- Starts a child nvim with the real config on a directory (like `nvim .`) and
-- drives it with real key input, so nvim-tree's startup hijack, the leader
-- mapping and which-key are all exercised.

local root = vim.fn.tempname()
vim.fn.mkdir(root .. '/sub', 'p')
root = vim.uv.fs_realpath(root)
vim.fn.writefile({ 'a' }, root .. '/a.txt')
vim.fn.writefile({ 'b' }, root .. '/sub/b.txt')

local chan = vim.fn.jobstart({ vim.v.progpath, '--embed', '--headless', root }, { rpc = true, cwd = root })

local function child(code, ...)
  return vim.rpcrequest(chan, 'nvim_exec_lua', code, { ... })
end

local function input(keys)
  vim.rpcrequest(chan, 'nvim_input', keys)
end

local STATE = [[
  local api = require('nvim-tree.api')
  local node = vim.bo.filetype == 'NvimTree' and api.tree.get_node_under_cursor() or nil
  return {
    ft = vim.bo.filetype,
    tree_visible = api.tree.is_visible(),
    wins = #vim.api.nvim_tabpage_list_wins(0),
    buf = vim.uv.fs_realpath(vim.api.nvim_buf_get_name(0)) or '',
    node = node and node.absolute_path or '',
  }
]]

local function wait_state(desc, pred)
  local state
  local ok = vim.wait(5000, function()
    state = child(STATE)
    return pred(state)
  end, 50)
  assert(ok, desc .. ', got ' .. vim.inspect(state))
  return state
end

-- Put the tree cursor on the node whose absolute path is `path`.
local function tree_cursor_to(path)
  local found = child([[
    local api = require('nvim-tree.api')
    for lnum = 1, vim.fn.line('$') do
      vim.api.nvim_win_set_cursor(0, { lnum, 0 })
      local node = api.tree.get_node_under_cursor()
      if node and node.absolute_path == ... then return true end
    end
    return false
  ]], path)
  assert(found, 'tree must list ' .. path)
end

local function check_nvim_tree()
  local a, b = root .. '/a.txt', root .. '/sub/b.txt'

  -- `nvim <dir>` shows the tree; <CR> on a file opens it and hides the tree.
  wait_state('opening a directory must show the tree', function(s) return s.ft == 'NvimTree' end)
  tree_cursor_to(a)
  input('<CR>')
  local s = wait_state('<CR> must open the file', function(s) return s.buf == a end)
  assert(not s.tree_visible, '<CR> must hide the tree after opening a file')
  assert(s.wins == 1, 'the file must take the whole tab, got ' .. s.wins .. ' windows')

  -- <leader>e opens the tree focused on the current file, even when it is
  -- inside a collapsed directory.
  child('vim.cmd.edit(...)', b)
  input('<Space>e')
  s = wait_state('<leader>e must focus the tree', function(s) return s.ft == 'NvimTree' end)
  assert(s.node == b, '<leader>e must put the cursor on the current file, got ' .. s.node)

  -- <leader>e inside the tree closes it again.
  input('<Space>e')
  s = wait_state('<leader>e in the tree must close it', function(s) return not s.tree_visible end)
  assert(s.buf == b, 'closing the tree must return to the file')

  -- Opening a file from the sidebar tree also hides it.
  input('<Space>e')
  wait_state('<leader>e must reopen the tree', function(s) return s.ft == 'NvimTree' end)
  tree_cursor_to(a)
  input('<CR>')
  s = wait_state('<CR> in the sidebar must open the file', function(s) return s.buf == a end)
  assert(not s.tree_visible, '<CR> in the sidebar must hide the tree')
  assert(s.wins == 1, 'the file must reuse the previous window, got ' .. s.wins .. ' windows')

  -- <leader>e must not share a prefix with any other normal-mode mapping,
  -- otherwise nvim waits for 'timeoutlen' before toggling the tree.
  local clashes = child([[
    local out = {}
    for _, m in ipairs(vim.api.nvim_get_keymap('n')) do
      if m.lhs ~= ' e' and vim.startswith(m.lhs, ' e') then out[#out + 1] = m.lhs end
    end
    for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, 'n')) do
      if vim.startswith(m.lhs, ' e') then out[#out + 1] = m.lhs end
    end
    return out
  ]])
  assert(#clashes == 0, '<leader>e clashes with ' .. vim.inspect(clashes))
  local rhs = child([[return vim.fn.maparg(' e', 'n')]])
  assert(rhs:find('NvimTreeFindFileToggle', 1, true), '<leader>e must toggle the tree on the current file, got ' .. rhs)

  print('PASS: <CR> opens files and hides the tree; <leader>e toggles the tree focused on the current file')
end

local passed, failure = pcall(check_nvim_tree)
pcall(vim.rpcrequest, chan, 'nvim_command', 'qa!')
vim.fn.jobstop(chan)
vim.fn.delete(root, 'rf')
if not passed then
  print(failure)
  vim.cmd('cquit 1')
end
vim.cmd('qa!')
