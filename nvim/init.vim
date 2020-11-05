set runtimepath+=~/.nvim,~/.nvim/after
set packpath+=~/.nvim

" python support
let g:python3_host_prog='~/.virtualenvs/neovim-python3/bin/python'
"let g:python_host_prog='~/.virtualenvs/neovim-python2/bin/python'

" vars
let $MYVIMRC='~/.nvimrc'
let $MYPLUGS='~/.nvim/plugs.vim'

source ~/.nvimrc
source ~/.nvim/plugs.vim
