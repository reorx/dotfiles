"""""""""""""""""""
" Vundle
"
" Brief help
" :BundleList          - list configured bundles
" :BundleInstall(!)    - install(update) bundles
" :BundleSearch(!) foo - search(or refresh cache first) for foo
" :BundleClean(!)      - confirm(or auto-approve) removal of unused bundles
"
" see :h vundle for more details or wiki for FAQ
" NOTE: comments after Bundle command are not allowed..
"""""""""""""""""""
set nocompatible               " be iMproved
filetype off                   " required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Bundles (from top to bottom in importance sequence)
" required!
Bundle 'gmarik/vundle'

" Enhancement
Bundle 'SuperTab-continued.'
"Bundle 'Shougo/neocomplcache'
Bundle 'mattn/zencoding-vim'
Bundle 'scrooloose/nerdcommenter'
Bundle 'godlygeek/tabular'
"Bundle 'sessionman.vim'
Bundle 'humiaozuzu/fcitx-status'
Bundle 'kien/rainbow_parentheses.vim'
Bundle 'nathanaelkane/vim-indent-guides'
"Bundle 'Lokaltog/vim-easymotion'
"Bundle 'mileszs/ack.vim'
Bundle 'tpope/vim-markdown'

" Component
Bundle 'majutsushi/tagbar'
Bundle 'scrooloose/syntastic'
Bundle 'scrooloose/nerdtree'
"Bundle 'jistr/vim-nerdtree-tabs'
Bundle 'Lokaltog/vim-powerline'
Bundle 'sjl/gundo.vim'
"Bundle 'kien/ctrlp.vim'
"Bundle 'tpope/vim-fugitive'  "git wrapper
"Bundle 'fs111/pydoc.vim'
"Bundle 'benmills/vimux'

" Syntax
Bundle 'digitaltoad/vim-jade'
Bundle 'wavded/vim-stylus'
Bundle 'lepture/vim-javascript'
" Bundle 'skammer/vim-css-color'

" Colors
Bundle 'guns/xterm-color-table.vim'
Bundle 'rickharris/vim-monokai'
Bundle 'chriskempson/vim-tomorrow-theme'
if !has("gui_running") && &t_Co == 256
    Bundle 'godlygeek/csapprox'
    "let g:CSApprox_attr_map = { 'bold' : 'bold', 'italic' : '', 'sp' : '' }
endif
if has("gui_running") || &t_Co == 256
    Bundle 'endel/vim-github-colorscheme'
    Bundle 'reorx/vim-colors-solarized'
    Bundle 'chriskempson/vim-tomorrow-theme'
    Bundle 'Lokaltog/vim-distinguished'
    Bundle 'rickharris/vim-blackboard'
    Bundle 'tpope/vim-vividchalk'
    "Bundle 'chriskempson/base16-vim'
endif
