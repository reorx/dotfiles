call plug#begin('~/.nvim/plugged')

" generic
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'scrooloose/nerdtree'
"Plug 'w0rp/ale'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'majutsushi/tagbar', { 'on':  'TagbarToggle' }
Plug 'dominikduda/vim_current_word'
" TODO use Plug 'Shougo/neosnippet.vim'
"Plug 'SirVer/ultisnips'
"Plug 'chiedo/vim-case-convert'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive', { 'on':  'Gblame' }
Plug 'ntpeters/vim-better-whitespace'
Plug 'ryanoasis/vim-devicons'  " requires a nerd font
"Plug 'easymotion/vim-easymotion'
Plug 'wellle/targets.vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'wakatime/vim-wakatime'
Plug 'ActivityWatch/aw-watcher-vim'
Plug 'editorconfig/editorconfig-vim'
"Plug 'MattesGroeger/vim-bookmarks'
"
" Useful but no frequently used
""Plug 'jlanzarotta/bufexplorer'
"Plug 'jeetsukumaran/vim-buffergator'
""Plug 'itchyny/vim-qfedit'
"Plug 'romainl/vim-qf'
"Plug 'yssl/QFEnter'
"
" Completion
"
Plug 'williamboman/nvim-lsp-installer'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-omni'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/vim-vsnip'
Plug 'ray-x/lsp_signature.nvim'
"
" Language specific
" Go
Plug 'fatih/vim-go', { 'for': 'go' }
"
" Go quicktemplate
"Plug 'codelitt/vim-qtpl'
"
" Python generic
Plug 'Vimjas/vim-python-pep8-indent', { 'for': 'python' }
Plug 'hdima/python-syntax', { 'for': 'python' }
Plug 'tmhedberg/SimpylFold', { 'for': 'python' }
"
" Nginx
Plug 'chr4/nginx.vim'
"
" HTML
Plug 'mattn/emmet-vim', { 'for': 'html' }
"
" JSX
Plug 'maxmellon/vim-jsx-pretty'
"
" PICO-8
"Plug 'justinj/vim-pico8-syntax'
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

" utils
Plug 'folke/which-key.nvim'


call plug#end()

" ------
" Config - Completion
" ------

set completeopt=menuone


" Completion
lua <<EOF
-- Customize how diagnostics are displayed
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = false,
})

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '<space>p', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', '<space>n', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>l', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', '<space>D', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', '<space>d', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>g', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>F', vim.lsp.buf.formatting, bufopts)
end


-- Setup lsp installer
require("nvim-lsp-installer").setup {}


-- Setup lspconfig.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

require('lspconfig')['pyright'].setup{
  on_attach = on_attach,
}
require('lspconfig')['tsserver'].setup{
  on_attach = on_attach,
}
require('lspconfig')['ansiblels'].setup{
  on_attach = on_attach,
}
require('lspconfig')['html'].setup{
  on_attach = on_attach,
  capabilities = capabilities,
}
require('lspconfig')['cssls'].setup{
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Setup lsp_signature
require "lsp_signature".setup({
  -- add you config here
})


-- Setup nvim-cmp.
local cmp = require'cmp'

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

cmp.setup({
  -- REQUIRED - you must specify a snippet engine
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  -- Supertab-like completion.
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-c>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert
    }),
    ['<Tab>'] = function(fallback)
      if not cmp.select_next_item() then
        if vim.bo.buftype ~= 'prompt' and has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end
    end,
  }),
  -- Groups of sources.
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'omni' },
    {
      name = 'beancount',
      option = { account = '~/Documents/Ledger/wzyboy.bean' },
    },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'emoji' },
  }),
  -- Looks.
  formatting = {
    format = function(entry, vim_item)
      vim_item.menu = ({
        omni = '[O]',
        path = '[P]',
        vsnip = '[S]',
        emoji = '[絵]',
        buffer = '[B]',
        nvim_lsp = '[LSP]',
      })[entry.source.name]
      return vim_item
    end,
  },
})
EOF

" ------
" Config - Other
" ------

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
nmap <c-_> :Files<cr>
noremap <leader>/ :Buffers<cr>
nnoremap <silent><Leader>rg :Rg <C-R><C-W><CR>
vnoremap <silent><leader>f <Esc>:Rg <C-R>=GetVisualSelection()<CR><CR>
" show mappings for the current mode, see https://github.com/junegunn/fzf.vim/pull/20
nmap <leader>? <plug>(fzf-maps-n)
xmap <leader>? <plug>(fzf-maps-x)
omap <leader>? <plug>(fzf-maps-o)

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

" vim-qf
nmap <leader><Up> <Plug>(qf_qf_previous)
nmap <leader><Down>  <Plug>(qf_qf_next)
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
let g:tagbar_width = 35
nmap <F8> :TagbarToggle<CR>
"echo winwidth('%')

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

" bookmarks

"highlight BookmarkLine ctermbg=194 ctermfg=NONE
highlight BookmarkLine    cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight Bookmark    cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
let g:bookmark_sign_disabled = 1
"let g:bookmark_highlight_lines = 1
