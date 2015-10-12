"""""""""""""""""""
" Vundle
"
"" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
"""""""""""""""""""

set nocompatible               " be iMproved
filetype off                   " required!

set rtp+=~/.vim/bundle/Vundle.vim/
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Bundles (from top to bottom in importance sequence)

" Newly installed
"Plugin 'SirVer/ultisnips'
"Plugin 'honza/vim-snippets'
"Plugin 'Valloric/YouCompleteMe'
"Plugin 'Shougo/neocomplete.vim'

" Enhancement
" complement
Plugin 'ervandew/supertab'
" quick editing
Plugin 'mattn/emmet-vim'
" easy commentting
Plugin 'scrooloose/nerdcommenter'
" bracket highlighting
Plugin 'kien/rainbow_parentheses.vim'
" indentation ruler
Plugin 'nathanaelkane/vim-indent-guides'
" key maps
Plugin 'tpope/vim-unimpaired'
" manipulate surrounding marks
Plugin 'tpope/vim-surround'
Plugin 'myusuf3/numbers.vim'
" rst improvements
"Plugin 'Rykka/riv.vim'

"Plugin 'Lokaltog/vim-easymotion'
" align
" session management
"Plugin 'sessionman.vim'

" Component
" code tags
Plugin 'majutsushi/tagbar'
" syntax checking
Plugin 'scrooloose/syntastic'
" directory tree
Plugin 'scrooloose/nerdtree'
" text searching like grep
Plugin 'rking/ag.vim'
" file searching
Plugin 'kien/ctrlp.vim'
Plugin 'dyng/ctrlsf.vim'
" bottom status line
Plugin 'Lokaltog/vim-powerline'
"Plugin 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
"Plugin 'bling/vim-airline'
" change tracking
Plugin 'sjl/gundo.vim'
" start page
Plugin 'mhinz/vim-startify'
" Snippet
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'tomtom/tlib_vim'
Plugin 'garbas/vim-snipmate'
"Plugin 'maksimr/vim-jsbeautify'
"Plugin 'einars/js-beautify'
Plugin 'rizzatti/dash.vim'
Plugin 'embear/vim-localvimrc'

""git wrapper
"Plugin 'tpope/vim-fugitive'
"Plugin 'fs111/pydoc.vim'
"Plugin 'benmills/vimux'
"Plugin 'jistr/vim-nerdtree-tabs'
"Plugin 'Lokaltog/vim-powerline'

" Syntax
Plugin 'hdima/python-syntax'
Plugin 'derekwyatt/vim-scala'
Plugin 'othree/html5.vim'
Plugin 'ChrisYip/Better-CSS-Syntax-for-Vim'
Plugin 'lepture/vim-javascript'
Plugin 'kchmck/vim-coffee-script'

"Plugin 'jeroenbourgois/vim-actionscript'
Plugin 'digitaltoad/vim-jade'
"Plugin 'wavded/vim-stylus'
"Plugin 'skammer/vim-css-color'
Plugin 'godlygeek/tabular'  " Required by vim-markdown
Plugin 'plasticboy/vim-markdown'

" Colorschems
Plugin 'guns/xterm-color-table.vim'
Plugin 'chriskempson/vim-tomorrow-theme'

" Make gvim-only colorschemes work transparently in terminal vim
"if !has("gui_running") && &t_Co == 256
    "Plugin 'godlygeek/csapprox'
    "let g:CSApprox_attr_map = { 'bold' : 'bold', 'italic' : '', 'sp' : '' }
"endif

" 256 Only
"Plugin 'rickharris/vim-monokai'
"Plugin 'endel/vim-github-colorscheme'
"Plugin 'reorx/vim-colors-solarized'
"Plugin 'chriskempson/vim-tomorrow-theme'
"Plugin 'Lokaltog/vim-distinguished'
"Plugin 'rickharris/vim-blackboard'
"Plugin 'tpope/vim-vividchalk'
"Plugin 'chriskempson/base16-vim'


call vundle#end()            " required
filetype plugin indent on    " required


"""""""""""
" Plugins "
"""""""""""
" nerdtree
let NERDTreeWinPos='left'
let NERDTreeWinSize=25
let NERDTreeAutoCenter=1
let NERDChristmasTree=1
let NERDTreeShowHidden=0
let NERDTreeChDirMode=1
let NERDTreeMouseMode=2
let NERDTreeIgnore = ['\.pyc$']
let g:nerdtree_tabs_open_on_gui_startup=0

" tagbar
let g:tagbar_sort=0
let g:tagbar_left=0
let g:tagbar_width=25

" localvimrc
let g:localvimrc_ask=0

"indent guide
let g:indent_guides_start_level=2
let g:indent_guides_guide_size=1
let g:indent_guides_auto_colors=0
hi IndentGuidesOdd  guibg=darkgrey ctermbg=darkgrey
hi IndentGuidesEven guibg=darkgrey ctermbg=darkgrey

" rainbow parentheses
" 'lightgray' is 'red' originally
let g:rbpt_colorpairs = [
    \ ['brown',       'RoyalBlue3'],
    \ ['Darkblue',    'SeaGreen3'],
    \ ['darkgray',    'DarkOrchid3'],
    \ ['darkgreen',   'firebrick3'],
    \ ['darkcyan',    'RoyalBlue3'],
    \ ['darkred',     'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['brown',       'firebrick3'],
    \ ['gray',        'RoyalBlue3'],
    \ ['black',       'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['Darkblue',    'firebrick3'],
    \ ['darkgreen',   'RoyalBlue3'],
    \ ['darkcyan',    'SeaGreen3'],
    \ ['darkred',     'DarkOrchid3'],
    \ ['lightgray',         'firebrick3'],
    \ ]
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
"au Syntax * RainbowParenthesesLoadBraces

" airline
"let g:airline_powerline_fonts = 0
"let g:airline_left_sep = ''
"let g:airline_right_sep = ''

" powerline
let g:Powerline_symbols = 'compatible'

" CtrlSF
" https://github.com/dyng/ctrlsf.vim
" http://vim.wikia.com/wiki/Mapping_keys_in_Vim_-_Tutorial_(Part_1)
nmap     <C-F>f <Plug>CtrlSFPrompt
vmap     <C-F>f <Plug>CtrlSFVwordPath
vmap     <C-F>F <Plug>CtrlSFVwordExec
nmap     <C-F>n <Plug>CtrlSFCwordPath
nmap     <C-F>p <Plug>CtrlSFPwordPath
nnoremap <C-F>o :CtrlSFOpen<CR>
nnoremap <C-F>t :CtrlSFToggle<CR>
inoremap <C-F>t <Esc>:CtrlSFToggle<CR>

" neocomplete
" let g:neocomplete#enable_at_startup = 1

" syntastic
let g:syntastic_python_checkers = ['flake8']
" Error codes reference: http://flake8.readthedocs.org/en/latest/warnings.html
" E265: block comment should start with ‘# ‘
" E501: line too long (<n> characters)
" W404: 'from <module> import ``*``' used; unable to detect undefined names
" Use `# NOQA` to ignore warnings for certain lines
let g:syntastic_python_flake8_args='--ignore=E265,E501'
let g:syntastic_mode_map = { 'mode': 'active',
                           \ 'active_filetypes': ['python', 'javascript', 'php'],
                           \ 'passive_filetypes': ['rst', 'html'] }
" Not setting the loclist by default is the intended behaviour. Previously we did set it, but syntastic isnt the only plugin using loclists. See #324
let g:syntastic_always_populate_loc_list=1
let g:syntastic_javascript_checkers = ['jshint']

"ultisnips
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
"let g:UltiSnipsExpandTrigger="<tab>"
"let g:UltiSnipsJumpForwardTrigger="<c-b>"
"let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
"let g:UltiSnipsEditSplit="vertical"


" ctrlp
" Ctrl-/
let g:ctrlp_map = '<c-_>'


" vim-snipmate
imap <C-e> <Plug>snipMateNextOrTrigger
smap <C-e> <Plug>snipMateNextOrTrigger

" startify
let g:startify_session_dir = '~/.vim/sessions'
let g:startify_custom_header = [
    \ '                                __ _._.,._.__',
    \ '                          .o8888888888888888P''',
    \ '                        .d88888888888888888K',
    \ '          ,8            888888888888888888888boo._',
    \ '         :88b           888888888888888888888888888b.',
    \ '          `Y8b          88888888888888888888888888888b.',
    \ '            `Yb.       d8888888888888888888888888888888b',
    \ '              `Yb.___.88888888888888888888888888888888888b',
    \ '                `Y888888888888888888888888888888CG88888P"''',
    \ '                  `88888888888888888888888888888MM88P"''',
    \ ' "Y888K    "Y8P""Y888888888888888888888888oo._""""',
    \ '   88888b    8    8888`Y88888888888888888888888oo.',
    \ '   8"Y8888b  8    8888  ,8888888888888888888888888o,',
    \ '   8  "Y8888b8    8888""Y8`Y8888888888888888888888b.',
    \ '   8    "Y8888    8888   Y  `Y8888888888888888888888',
    \ '   8      "Y88    8888     .d `Y88888888888888888888b',
    \ ' .d8b.      "8  .d8888b..d88P   `Y88888888888888888888',
    \ '                                  `Y88888888888888888b.',
    \ '                   "Y888P""Y8b. "Y888888888888888888888',
    \ '                     888    888   Y888`Y888888888888888',
    \ '                     888   d88P    Y88b `Y8888888888888',
    \ '                     888"Y88K"      Y88b dPY8888888888P',
    \ '                     888  Y88b       Y88dP  `Y88888888b',
    \ '                     888   Y88b       Y8P     `Y8888888',
    \ '                   .d888b.  Y88b.      Y        `Y88888',
    \ '                                                  `Y88K',
    \ '                                                    `Y8',
    \ '                                                      ''',
    \ '',
    \ ]
