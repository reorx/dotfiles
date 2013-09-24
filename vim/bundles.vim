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
" complement
Bundle 'SuperTab-continued.'
" easy commentting
Bundle 'mattn/zencoding-vim'
Bundle 'scrooloose/nerdcommenter'
Bundle 'humiaozuzu/fcitx-status'
" bracket highlighting
Bundle 'kien/rainbow_parentheses.vim'
" indentation ruler
Bundle 'nathanaelkane/vim-indent-guides'
" key maps
Bundle 'tpope/vim-unimpaired'
" manipulate surrounding marks
Bundle 'tpope/vim-surround'
"Bundle 'Lokaltog/vim-easymotion'
" align
"Bundle 'godlygeek/tabular'
" session management
"Bundle 'sessionman.vim'
" quick edit
"Bundle 'Shougo/neocomplcache'

" Component
" code tags
Bundle 'majutsushi/tagbar'
" syntax checking
Bundle 'scrooloose/syntastic'
" directory tree
Bundle 'scrooloose/nerdtree'
" text searching like grep
Bundle 'mileszs/ack.vim'
" file searching
Bundle 'kien/ctrlp.vim'
" bottom status line
Bundle 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
" change tracking
Bundle 'sjl/gundo.vim'
" start page
Bundle 'mhinz/vim-startify'
""git wrapper
"Bundle 'tpope/vim-fugitive'
"Bundle 'fs111/pydoc.vim'
"Bundle 'benmills/vimux'
"Bundle 'jistr/vim-nerdtree-tabs'
"Bundle 'Lokaltog/vim-powerline'

" Syntax
Bundle 'ChrisYip/Better-CSS-Syntax-for-Vim'
Bundle 'lepture/vim-javascript'
"Bundle 'digitaltoad/vim-jade'
"Bundle 'wavded/vim-stylus'
"Bundle 'skammer/vim-css-color'
"Bundle 'plasticboy/vim-markdown'

" Colorschems
Bundle 'guns/xterm-color-table.vim'
Bundle 'chriskempson/vim-tomorrow-theme'

" Make gvim-only colorschemes work transparently in terminal vim
"if !has("gui_running") && &t_Co == 256
    "Bundle 'godlygeek/csapprox'
    "let g:CSApprox_attr_map = { 'bold' : 'bold', 'italic' : '', 'sp' : '' }
"endif

" 256 Only
"Bundle 'rickharris/vim-monokai'
"Bundle 'endel/vim-github-colorscheme'
"Bundle 'reorx/vim-colors-solarized'
"Bundle 'chriskempson/vim-tomorrow-theme'
"Bundle 'Lokaltog/vim-distinguished'
"Bundle 'rickharris/vim-blackboard'
"Bundle 'tpope/vim-vividchalk'
"Bundle 'chriskempson/base16-vim'
