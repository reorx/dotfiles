call plug#begin('~/.vim/plugged')

" Editing
Plug 'ervandew/supertab'

" Browsing
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'myusuf3/numbers.vim'
Plug 'junegunn/fzf.vim'
Plug 'nathanaelkane/vim-indent-guides'

" Syntax
Plug 'hdima/python-syntax'
Plug 'stephpy/vim-yaml'
Plug 'fatih/vim-go'
Plug 'chr4/nginx.vim'

" Colorscheme
Plug 'reorx/vim-tomorrow-theme'
Plug 'chriskempson/base16-vim'

" Add plugins to &runtimepath
call plug#end()


" ============================================================================
" Plug Configs
" ============================================================================

" ----------------------------------------------------------------------------
" NERDTree
" ----------------------------------------------------------------------------
let NERDTreeWinPos='left'
let NERDTreeWinSize=25
let NERDTreeAutoCenter=1
let NERDChristmasTree=1
let NERDTreeShowHidden=0
let NERDTreeChDirMode=1
let NERDTreeMouseMode=2
let NERDTreeIgnore = ['\.pyc$']
let g:nerdtree_tabs_open_on_gui_startup=0

" ----------------------------------------------------------------------------
" Indent Guide
" ----------------------------------------------------------------------------
let g:indent_guides_start_level=2
let g:indent_guides_guide_size=1
let g:indent_guides_auto_colors=0
hi IndentGuidesOdd  guibg=darkgrey ctermbg=darkgrey
hi IndentGuidesEven guibg=darkgrey ctermbg=darkgrey

" ----------------------------------------------------------------------------
" airline
" ----------------------------------------------------------------------------
"let g:airline_powerline_fonts = 0
"let g:airline_left_sep = ''
"let g:airline_right_sep = ''
" airline
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.linenr = ''

" other choices: deus, luna, wombat
let g:airline_theme='jellybeans'

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_tabs = 1
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#show_tab_nr = 0
"let g:airline#extensions#tabline#tab_nr_type = 1
let g:airline#extensions#tabline#show_close_button = 0
let g:airline#extensions#tabline#buffers_label = 'b'
let g:airline#extensions#tabline#tabs_label = 't'
"let g:airline#extensions#tabline#fnamemod = ':t'

let g:airline#extensions#virtualenv#enabled = 1
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#tagbar#enabled = 0
let g:airline#extensions#whitespace#enabled = 1
let g:airline#extensions#whitespace#symbol = '|'
let g:airline#extensions#default#layout = [
  \ [ 'a', 'error', 'warning', 'b', 'c' ],
  \ [ 'x', 'y', 'z' ]
  \ ]
