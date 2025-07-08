require('config.lazy')
require('config.cmp')
--require('config.lsp')
require('config.lsp_old')

function vim.getVisualSelection()
  local current_clipboard_content = vim.fn.getreg('"')

  vim.cmd('noau normal! "vy"')
  local text = vim.fn.getreg('v')
  vim.fn.setreg('v', {})

  vim.fn.setreg('"', current_clipboard_content)

  text = string.gsub(text, "\n", "")
  if #text > 0 then
    return text
  else
    return ''
  end
end

vim.cmd[[
  source ~/.config/nvim/nvimrc
  let $MYVIMRC='~/.nvim/nvimrc'
  let $MYLUA='~/.nvim/lua'
  let $MYLAZY='~/.nvim/lua/config/lazy.lua'
  let $MYPLUGS='~/.nvim/lua/plugins'
]]
