call plug#begin('~/.nvim/plugged')

" generic
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'scrooloose/nerdtree'
Plug 'w0rp/ale'
Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim'
Plug 'Shougo/echodoc.vim'
Plug 'majutsushi/tagbar'
Plug 'dominikduda/vim_current_word'
Plug 'SirVer/ultisnips'
Plug 'wakatime/vim-wakatime'
"Plug 'chiedo/vim-case-convert'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive', { 'on':  'Gblame' }
"Plug 'jlanzarotta/bufexplorer'
Plug 'jeetsukumaran/vim-buffergator'
Plug 'mhinz/vim-grepper'
"Plug 'itchyny/vim-qfedit'
Plug 'romainl/vim-qf'
Plug 'yssl/QFEnter'
Plug 'ntpeters/vim-better-whitespace'
Plug 'ryanoasis/vim-devicons'  " requires a nerd font
Plug 'easymotion/vim-easymotion'
Plug 'wellle/targets.vim'
Plug 'tpope/vim-surround'

" completion
Plug 'ervandew/supertab'
"
" plan 1: deoplete
"Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
"
" plan 2: ncm2 + LanguageClient-neovim
Plug 'ncm2/ncm2'
Plug 'roxma/nvim-yarp'
Plug 'autozimu/LanguageClient-neovim', { 'branch': 'next', 'do': 'bash install.sh', }

" language specific
" Go
Plug 'fatih/vim-go', { 'for': 'go' }
"
" Go quicktemplate
Plug 'codelitt/vim-qtpl'
"
" Python generic
Plug 'Vimjas/vim-python-pep8-indent', { 'for': 'python' }
Plug 'hdima/python-syntax', { 'for': 'python' }
Plug 'tmhedberg/SimpylFold', { 'for': 'python' }
"
" Python jedi-vim (works independently with completion)
"Plug 'davidhalter/jedi-vim', { 'for': 'python' }
"
" Python deoplete-jedi + jedi-vim (works with deoplete, jedi-vim provides `go to definition`
"Plug 'zchee/deoplete-jedi', { 'for': 'python' }
"Plug 'davidhalter/jedi-vim', { 'for': 'python' }  " enable when you need `go to definition`
"
" Nginx
Plug 'chr4/nginx.vim'
"
" HTML
Plug 'mattn/emmet-vim', { 'for': 'html' }
"
" PICO-8
Plug 'justinj/vim-pico8-syntax'
" protobuf
Plug 'uarun/vim-protobuf', { 'for': 'proto' }
" robot
Plug 'mfukar/robotframework-vim'

" colorscheme
Plug 'chriskempson/base16-vim'
Plug 'kristijanhusak/vim-hybrid-material'
Plug 'itchyny/landscape.vim'

call plug#end()

" ------
" Config - Completion
" ------

" supertab
"let g:SuperTabDefaultCompletionType = '<c-n>'
let g:SuperTabDefaultCompletionType = 'context'
let g:SuperTabContextDefaultCompletionType = '<c-n>'
let g:SuperTabLongestHighlight = 1
"let g:SuperTabLongestEnhanced = 1

" ncm
" enable ncm2 for all buffers
autocmd BufEnter * call ncm2#enable_for_buffer()
" :help Ncm2PopupOpen for more information
"set completeopt=noinsert,menuone,noselect,longest
au User Ncm2PopupOpen set completeopt=noinsert,menuone,noselect
au User Ncm2PopupClose set completeopt=menuone,longest

" lsc
let g:LanguageClient_serverCommands = {
    \ 'javascript': ['/usr/local/bin/javascript-typescript-stdio'],
    \ 'python': ['/Users/reorx/.venv/pyls/bin/pyls'],
    \ }
let g:LanguageClient_loggingFile = '/tmp/lsc.log'
let g:LanguageClient_loggingLevel = 'DEBUG'
let g:LanguageClient_diagnosticsList = 'Location'
" lsc keys
noremap <leader>d :call LanguageClient_textDocument_definition()<CR>
noremap <leader>g :call LanguageClient_textDocument_typeDefinition()<CR>
noremap <leader>h :call LanguageClient_textDocument_hover()<CR>
noremap <leader>f :call LanguageClient_contextMenu()<CR>

" deoplete
"let g:deoplete#disable_auto_complete = 0
let g:deoplete#enable_at_startup = 1
let g:deoplete#auto_complete_start_length = 3
let g:deoplete#max_list = 15
let g:deoplete#max_abbr_width = 50
let g:deoplete#sources#jedi#show_docstring = 1

" jedi (only for go to definition)
let g:jedi#completions_enabled = 0

" ------
" Config - Other
" ------

" colorscheme
set background=dark

"colorscheme base16-default-dark
colorscheme hybrid_reverse
"colorscheme landscape

" nerdtree
let g:NERDTreeWinSize = 25
let NERDTreeIgnore = ['\.pyc$']

function! MyNERDTreeToggle()
    if !g:NERDTree.IsOpen()
        execute 'NERDTreeFind'
    else
        execute 'NERDTreeClose'
    endif
endfunction
nmap <F4> :call MyNERDTreeToggle()<cr>

" fzf
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)
nmap <c-_> :Files<cr>
noremap <leader>/ :Buffers<cr>

" buffergator
let g:buffergator_viewport_split_policy="T"
let g:buffergator_hsplit_size=13
let g:buffergator_sort_regime="mru"
let g:buffergator_suppress_mru_switch_into_splits_keymaps=1

" grepper
runtime plugin/grepper.vim    " initialize g:grepper with default values
let g:grepper.tools = ['ag', 'ag_u', 'git']
let g:grepper.ag_u = {
    \ 'grepprg':    'ag -u --vimgrep',
    \ 'grepformat': '%f:%l:%c:%m,%f:%l:%m',
    \ 'escape': '\^$.*+?()[]{}|',
    \ }
nmap gs <plug>(GrepperOperator)
xmap gs <plug>(GrepperOperator)

" QFEnter
let g:qfenter_keymap = {}
let g:qfenter_keymap.vopen = ['<C-v>']
let g:qfenter_keymap.hopen = ['<C-CR>', '<C-s>', '<C-x>']
let g:qfenter_keymap.topen = ['<C-t>']

" vim-qf
nmap <leader>p <Plug>(qf_qf_previous)
nmap <leader>n  <Plug>(qf_qf_next)
" these two key maps can replace 'milkypostman/vim-togglelist'
nmap <leader>q <Plug>(qf_qf_toggle)
nmap <leader>l <Plug>(qf_loc_toggle)

" python-syntax
let python_highlight_builtins = 1
let python_highlight_exceptions = 1
let python_highlight_string_format = 1
let python_highlight_indent_errors = 1
let python_highlight_doctests = 1
let python_print_as_function = 1

" echodoc
set noshowmode
let g:echodoc#enable_at_startup=1
let g:echodoc#enable_force_overwrite=1

" ale
let g:ale_lint_on_enter = 0
let g:ale_lint_on_text_changed = 'never'
"let g:ale_lint_on_insert_leave = 1
let g:ale_sign_error = 'x'
let g:ale_sign_warning = '~'
let g:ale_echo_msg_format = '[%severity%] %s <%linter%>'
"let g:ale_set_highlights = 0
nmap <leader><Right> :ALENextWrap<CR>
nmap <leader><Left> :ALEPreviousWrap<CR>
" emoji sign
"let g:ale_sign_error = '❗'
"let g:ale_sign_warning = '🔸'
"let g:ale_sign_warning = '⚠️'
"highlight clear ALEErrorSign
"highlight clear ALEWarningSign

let g:ale_linters = {
\   'javascript': [],
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

" tagbar
nmap <F8> :TagbarToggle<CR>

" current word
let g:vim_current_word#enabled = 1
hi CurrentWord ctermbg=gray guibg=gray25
autocmd ColorScheme * hi CurrentWord ctermbg=gray guibg=gray25
" change visual mode selection color
hi Visual guifg=White guibg=SteelBlue gui=none


" UltiSnips
let g:UltiSnipsSnippetDirectories=["ultisnips"]
let g:UltiSnipsExpandTrigger='<c-e>'
let g:UltiSnipsJumpForwardTrigger='<c-f>'
let g:UltiSnipsJumpBackwardTrigger='<c-b>'
let g:UltiSnipsEnableSnipMate=0

" XXX fix yaml indent changed by one of the plugs which I don't know what it is
"autocmd FileType yaml setlocal indentexpr=

" git-gutter
let g:gitgutter_enabled = 0
nmap <F3> :GitGutterToggle<CR>

" vim-go
let g:go_fmt_command = "goimports"
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_interfaces = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_fmt_autosave = 1
let g:go_metalinter_enabled = ['vet', 'errcheck']
let g:go_metalinter_disabled = ['golint']

au FileType go nmap <Leader>i <Plug>(go-info)
au FileType go nmap <Leader>gd <Plug>(go-doc)
au FileType go nmap gd <Plug>(go-def-tab)

" better whitespace
let g:better_whitespace_ctermcolor='gray'
let g:better_whitespace_guicolor='gray40'
