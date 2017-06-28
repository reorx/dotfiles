call plug#begin('~/.nvim/plugged')

Plug 'ervandew/supertab'
Plug 'vim-airline/vim-airline'
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'chriskempson/base16-vim'
Plug 'scrooloose/nerdtree'
Plug 'w0rp/ale'
Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
Plug 'kristijanhusak/vim-hybrid-material'
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'Vimjas/vim-python-pep8-indent', { 'for': 'python' }
Plug 'hdima/python-syntax', { 'for': 'python' }
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-jedi', { 'for': 'python' }

call plug#end()

" ------
" Config
" ------

" nerdtree
nmap <F4> :NERDTreeFind<cr>
let g:NERDTreeWinSize = 25

" ale
let g:ale_lint_on_text_changed = 'never'
let g:ale_linters = {
\   'javascript': ['eslint'],
\   'python': ['flake8'],
\   'go': ['gometalinter', 'gofmt'],
\}
let g:ale_go_gometalinter_options = '--fast'
" Error codes reference: http://flake8.readthedocs.org/en/latest/warnings.html
" E265: block comment should start with ‘# ‘
" E501: line too long (<n> characters)
" W404: 'from <module> import ``*``' used; unable to detect undefined names
let g:ale_python_flake8_options = '--ignore=E265,E501'
nmap <c-]> :ALENextWrap<cr>
nmap <c-[> :ALEPreviousWrap<cr>

" fzf
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)
nmap <c-_> :Files<cr>

" python-syntax
let python_highlight_builtins = 1
let python_highlight_exceptions = 1
let python_highlight_string_format = 1
let python_highlight_indent_errors = 1
let python_highlight_doctests = 1
let python_print_as_function = 1

" supertab
let g:SuperTabDefaultCompletionType = '<c-n>'

" deoplete
"let g:deoplete#disable_auto_complete = 0
let g:deoplete#enable_at_startup = 1
let g:deoplete#auto_complete_start_length = 3
let g:deoplete#max_list = 15
let g:deoplete#max_abbr_width = 50
let g:deoplete#sources#jedi#show_docstring = 1
