call plug#begin('~/.nvim/plugged')

" generic
Plug 'ervandew/supertab'
Plug 'vim-airline/vim-airline'
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'scrooloose/nerdtree'
Plug 'w0rp/ale'
Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
Plug 'majutsushi/tagbar'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'dominikduda/vim_current_word'
Plug 'jiangmiao/auto-pairs'
Plug 'SirVer/ultisnips'
Plug 'wakatime/vim-wakatime'
Plug 'chiedo/vim-case-convert'
" colorscheme
Plug 'chriskempson/base16-vim'
Plug 'kristijanhusak/vim-hybrid-material'
" language specific
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'Vimjas/vim-python-pep8-indent', { 'for': 'python' }
Plug 'hdima/python-syntax', { 'for': 'python' }
Plug 'zchee/deoplete-jedi', { 'for': 'python' }
Plug 'tmhedberg/SimpylFold', { 'for': 'python' }
Plug 'chr4/nginx.vim'
Plug 'codelitt/vim-qtpl'
Plug 'mattn/emmet-vim', { 'for': 'html' }


call plug#end()

" ------
" Config
" ------

" colorscheme
set background=dark
if has("termguicolors")
    set termguicolors
endif
"colorscheme base16-default-dark
colorscheme hybrid_reverse

" nerdtree
nmap <F4> :NERDTreeFind<cr>
let g:NERDTreeWinSize = 25

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

" ale
let g:ale_lint_on_text_changed = 'never'
let g:ale_sign_error = '❗'
"let g:ale_sign_warning = '🔸'
let g:ale_sign_warning = '⚠️'
let g:ale_echo_msg_format = '[%severity%] %s <%linter%>'
let g:ale_set_highlights = 0
highlight clear ALEErrorSign
highlight clear ALEWarningSign
nmap <leader>] :ALENextWrap<CR>
nmap <leader>[ :ALEPreviousWrap<CR>

let g:ale_linters = {
\   'javascript': ['eslint'],
\   'python': ['flake8'],
\   'go': ['gometalinter', 'gofmt'],
\   'html': ['htmlhint'],
\}
let g:ale_go_gometalinter_options = '--fast'
" Error codes reference: http://flake8.readthedocs.org/en/latest/warnings.html
" E265: block comment should start with ‘# ‘
" E501: line too long (<n> characters)
" W404: 'from <module> import ``*``' used; unable to detect undefined names
let g:ale_python_flake8_options = '--ignore=E265,E501'

" airline
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.linenr = ''

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#tab_nr_type = 1
let g:airline#extensions#tabline#show_close_button = 0

let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#tagbar#enabled = 0
let g:airline#extensions#whitespace#enabled = 1
let g:airline#extensions#whitespace#symbol = '|'
let g:airline#extensions#default#layout = [
  \ [ 'a', 'error', 'warning', 'b', 'c' ],
  \ [ 'x', 'y', 'z' ]
  \ ]

" tagbar
nmap <F8> :TagbarToggle<CR>

" current word
let g:vim_current_word#enabled = 1
hi CurrentWord guibg=gray25

" UltiSnips
let g:UltiSnipsSnippetDirectories=["ultisnips"]
let g:UltiSnipsExpandTrigger='<c-e>'
let g:UltiSnipsJumpForwardTrigger='<c-f>'
let g:UltiSnipsJumpBackwardTrigger='<c-b>'
let g:UltiSnipsEnableSnipMate=0

" auto-pairs
"let g:AutoPairs = {'(':')', '[':']', '{':'}',"'":"'",'"':'"', '`':'`'}
"let g:AutoPairsShortcutToggle = '<leader>p'

" XXX fix yaml indent changed by one of the plugs which I don't know what it is
autocmd FileType yaml setlocal indentexpr=
