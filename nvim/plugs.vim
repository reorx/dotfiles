call plug#begin('~/.nvim/plugged')
" TODO
" - https://github.com/phaazon/hop.nvim
" - https://github.com/kevinhwang91/nvim-bqf
" - https://github.com/tpope/vim-commentary/blob/master/plugin/commentary.vim
" - https://github.com/kevinhwang91/nvim-hlslens
" - https://github.com/gelguy/wilder.nvim
" - https://github.com/liuchengxu/vista.vim

" generic
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'scrooloose/nerdtree'
"Plug 'w0rp/ale'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'dominikduda/vim_current_word'
"Plug 'chiedo/vim-case-convert'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive', { 'on':  'Gblame' }
Plug 'ntpeters/vim-better-whitespace'
Plug 'ryanoasis/vim-devicons'  " requires a nerd font
"Plug 'easymotion/vim-easymotion'
Plug 'wellle/targets.vim'
Plug 'machakann/vim-sandwich'
Plug 'tpope/vim-repeat'
Plug 'editorconfig/editorconfig-vim'
Plug 'romainl/vim-qf'
Plug 'folke/which-key.nvim'
"Plug 'MattesGroeger/vim-bookmarks'
"
" statistics
Plug 'wakatime/vim-wakatime'
Plug 'ActivityWatch/aw-watcher-vim'
"
" Useful but no frequently used
""Plug 'jlanzarotta/bufexplorer'
"Plug 'jeetsukumaran/vim-buffergator'
"Plug 'yssl/QFEnter'
"
" Completion
"
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-omni'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/vim-vsnip'
"
" LSP
"
Plug 'williamboman/nvim-lsp-installer'
" NOTE replace nvim-lsp-installer with mason in the future
" Plug 'williamboman/mason.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'ray-x/lsp_signature.nvim' " 🐼
" lsp_lines: renders diagnostics using virtual lines on top of the real line of code.
Plug 'https://git.sr.ht/~whynothugo/lsp_lines.nvim'
Plug 'rmagatti/goto-preview'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
"
" Language specific
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" Go
Plug 'fatih/vim-go', { 'for': 'go' }
" Go quicktemplate
"Plug 'codelitt/vim-qtpl'
" Python generic
Plug 'Vimjas/vim-python-pep8-indent', { 'for': 'python' }
Plug 'hdima/python-syntax', { 'for': 'python' }
Plug 'tmhedberg/SimpylFold', { 'for': 'python' }
" Nginx
Plug 'chr4/nginx.vim'
" HTML
Plug 'mattn/emmet-vim', { 'for': 'html' }
" JSX
Plug 'maxmellon/vim-jsx-pretty'
" protobuf
Plug 'uarun/vim-protobuf', { 'for': 'proto' }
" ansible yaml
Plug 'pearofducks/ansible-vim', { 'for': 'yaml' }

" colorscheme
Plug 'chriskempson/base16-vim'
Plug 'kristijanhusak/vim-hybrid-material'
Plug 'itchyny/landscape.vim'
Plug 'haishanh/night-owl.vim'
Plug 'arcticicestudio/nord-vim'
Plug 'lifepillar/vim-gruvbox8'


call plug#end()

" ------
" Config - LSP
" ------

set completeopt=menuone

lua require('cmp-config')
lua require('lsp-config')

" ------
" Config - Other
" ------

lua require('misc')

" colorscheme
set background=dark

let $NVIM_TUI_ENABLE_TRUE_COLOR=1
"colorscheme base16-default-dark
"colorscheme hybrid_reverse
colorscheme night-owl
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
let g:fzf_preview_window = ['right:50%', 'ctrl-f']
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.8, 'border': 'rounded' } }
" use Ctrl-V Ctrl-/ to determine the keycode in vim
noremap <c-/> :Files<cr>
noremap <leader>/ :Buffers<cr>
"nnoremap <silent><Leader>rg :Rg <C-R><C-W><CR>
vnoremap <silent><leader>f <Esc>:Rg <C-R>=GetVisualSelection()<CR><CR>
" show mappings for the current mode, see https://github.com/junegunn/fzf.vim/pull/20
nmap <leader>? <plug>(fzf-maps-n)
xmap <leader>? <plug>(fzf-maps-x)
omap <leader>? <plug>(fzf-maps-o)

" vim-qf
nmap <leader>qp <Plug>(qf_qf_previous)
nmap <leader>qn  <Plug>(qf_qf_next)
" can replace 'milkypostman/vim-togglelist'
nmap <leader>qq <Plug>(qf_qf_toggle)

" buffergator
let g:buffergator_viewport_split_policy="T"
let g:buffergator_hsplit_size=13
let g:buffergator_sort_regime="mru"
let g:buffergator_suppress_mru_switch_into_splits_keymaps=1

" QFEnter
let g:qfenter_keymap = {}
let g:qfenter_keymap.vopen = ['<C-v>']
let g:qfenter_keymap.hopen = ['<C-CR>', '<C-s>', '<C-x>']
let g:qfenter_keymap.topen = ['<C-t>']

" python-syntax
let python_highlight_builtins = 1
let python_highlight_exceptions = 1
let python_highlight_string_format = 1
let python_highlight_indent_errors = 1
let python_highlight_doctests = 1
let python_print_as_function = 1

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

"echo winwidth('%')

" current word
let g:vim_current_word#enabled = 1
hi CurrentWord ctermbg=gray guibg=gray25
autocmd ColorScheme * hi CurrentWord ctermbg=gray guibg=gray25
" change visual mode selection color
hi Visual guifg=White guibg=SteelBlue gui=none

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

"au FileType go nmap <Leader>i <Plug>(go-info)
"au FileType go nmap <Leader>gd <Plug>(go-doc)

" better whitespace
let g:better_whitespace_ctermcolor='gray'
let g:better_whitespace_guicolor='gray40'

" sandwich
let g:sandwich_no_default_key_mappings = 1
"
" add
nmap <leader>sa <Plug>(sandwich-add)
xmap <leader>sa <Plug>(sandwich-add)
omap <leader>sa <Plug>(sandwich-add)
"
" delete
nmap <leader>sd <Plug>(sandwich-delete)
xmap <leader>sd <Plug>(sandwich-delete)
nmap <leader>sdb <Plug>(sandwich-delete-auto)
"
" replace
nmap <leader>sr <Plug>(sandwich-replace)
xmap <leader>sr <Plug>(sandwich-replace)
nmap <leader>srb <Plug>(sandwich-replace-auto)

" bookmarks

"highlight BookmarkLine ctermbg=194 ctermfg=NONE
highlight BookmarkLine    cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight Bookmark    cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
let g:bookmark_sign_disabled = 1
"let g:bookmark_highlight_lines = 1
