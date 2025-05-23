set runtimepath+=~/.nvim,~/.nvim/after
set packpath+=~/.nvim

" python support
let g:python3_host_prog='~/.virtualenvs/neovim-python3/bin/python'
"let g:python_host_prog='~/.virtualenvs/neovim-python2/bin/python'

" vars
let $MYVIMRC='~/.nvimrc'
"let $MYPLUGS='~/.nvim/plugs.vim'
let $MYPLUGS='~/.nvim/lua/plugins'
let $MYLUA='~/.nvim/lua'
let $MYLAZY='~/.nvim/lua/config/lazy.lua'

source ~/.nvimrc
"source ~/.nvim/plugs.vim

require("config.lazy")
require("config.cmp-config")
require("config.lsp-config")
