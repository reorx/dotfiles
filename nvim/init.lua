-- Nvim init file --

-- 终端下一律用 OSC 52 复制,穿透 tmux/mosh 到本地剪贴板;GUI(Neovide)
-- 不设 g:clipboard,走默认的 pbcopy。不用 SSH_TTY 判断:tmux 等场景下它不可靠。
-- paste 本机用 pbpaste 读真实剪贴板;服务器上退回无名寄存器桩函数,
-- 避免 "+p 触发 OSC 52 查询在终端里挂起(远程粘贴走终端自己的 Cmd+V)。
if not vim.g.neovide then
  local osc52 = require('vim.ui.clipboard.osc52')
  local function paste_from_unnamed()
    return { vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('') }
  end
  local paste = vim.fn.executable('pbpaste') == 1
    and { ['+'] = { 'pbpaste' }, ['*'] = { 'pbpaste' } }
    or { ['+'] = paste_from_unnamed, ['*'] = paste_from_unnamed }
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = { ['+'] = osc52.copy('+'), ['*'] = osc52.copy('*') },
    paste = paste,
  }
end

-- Vim configuration
vim.cmd.source(vim.fn.stdpath('config') .. '/nvimrc')

-- Load lazy.nvim
require('config.lazy')
