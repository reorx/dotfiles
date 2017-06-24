call plug#begin('~/.nvim/plugged')

Plug 'ervandew/supertab'
Plug 'vim-airline/vim-airline'
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'chriskempson/base16-vim'
Plug 'scrooloose/nerdtree'
Plug 'w0rp/ale'
Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
Plug 'davidhalter/jedi-vim', { 'for': 'python' }
Plug 'kristijanhusak/vim-hybrid-material'

call plug#end()

" ------
" Config
" ------

" nerdtree
nmap <F4> :NERDTreeToggle<cr>

" ale
let g:ale_lint_on_text_changed = 'never'
let g:ale_linters = {
\   'javascript': ['eslint'],
\   'python': ['flake8'],
\}

" fzf
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)
nmap <c-_> :Files<cr>
