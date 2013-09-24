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
Bundle 'Lokaltog/vim-powerline'
"Bundle 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}
"Bundle 'bling/vim-airline'
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


filetype plugin indent on  " re-enable


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

" neocomplcache
" Disable AutoComplPop. Comment out this line if AutoComplPop is not installed.
"let g:acp_enableAtStartup=0
"let g:neocomplcache_enable_at_startup=1
"let g:neocomplcache_disable_auto_complete=1
"let g:neocomplcache_max_list=20
"let g:neocomplcache_enable_ignore_case=0
"let g:neocomplcache_min_syntax_length=3
"autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
"autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
"autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
"autocmd FileType python setlocal omnifunc=pythoncomplete#Complete

" supertab compatibility with neocomplcache
"let g:SuperTabDefaultCompletionType = '<C-X><C-U>'
"let g:SuperTabRetainCompletionType=2

" airline
" let g:airline_powerline_fonts = 1

" powerline
let g:Powerline_symbols = 'compatible'

" syntastic
let g:syntastic_python_checkers = ['flake8']
let g:syntastic_python_flake8_args='--ignore=E501,W404,W801'
let g:syntastic_mode_map = { 'mode': 'active',
                           \ 'active_filetypes': ['python', 'javascript'],
                           \ 'passive_filetypes': ['rst'] }
" Not setting the loclist by default is the intended behaviour. Previously we did set it, but syntastic isnt the only plugin using loclists. See #324
let g:syntastic_always_populate_loc_list=1

" ack
set shellpipe=&>

" ctrlp
let g:ctrlp_map = '<c-i>'

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
