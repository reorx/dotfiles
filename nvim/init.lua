require('config.lazy')
require('config.cmp')
--require('config.lsp')
require('config.lsp_old')

vim.cmd[[
  source ~/.config/nvim/nvimrc
  let $MYVIMRC='~/.nvim/nvimrc'
  let $MYLUA='~/.nvim/lua'
  let $MYLAZY='~/.nvim/lua/config/lazy.lua'
  let $MYPLUGS='~/.nvim/lua/plugins'
]]
