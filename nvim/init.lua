-- Nvim init file --

-- Utility functions used by plugins
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

-- Load lazy.nvim
require('config.lazy')

-- Vim configuration
vim.cmd[[
  source ~/.config/nvim/nvimrc
  let $MYVIMRC='~/.nvim/nvimrc'
  let $MYLUA='~/.nvim/lua'
  let $MYLAZY='~/.nvim/lua/config/lazy.lua'
  let $MYPLUGS='~/.nvim/lua/plugins'
]]
