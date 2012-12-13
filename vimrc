" Author: reorx

" Should at the top since it will affect bundles.vim
"set t_Co=256

""""""""""""""""
" Load Bundles "
""""""""""""""""

" so that it can be easily accessed
let $MYBUNDLES='~/.vim/bundles.vim'
source $MYBUNDLES


"""""""""""
" General "
"""""""""""
" Encoding
set encoding=utf-8
set fileencodings=utf-8,chinese,latin-1
set fileencoding=utf-8
set fencs=utf-8,chinese

syntax on
filetype on
filetype plugin indent on " required by Vundle

set history=100
set nobackup
set autoread " When a file has been detected to have been changed outside of Vim and
"              it has not been changed inside of Vim, automatically read it again.
"              When the file has been deleted this is not done.

set ff=unix
set backspace=indent,eol,start

" Indent
set smarttab " a <Tab> in front of a line inserts blanks according to
"              'shiftwidth'.  'tabstop' or 'softtabstop' is used in other places
set shiftwidth=4 " Number of spaces to use for each step of (auto)indent.
set tabstop=4 " Number of spaces that a <Tab> in the file counts for.
set softtabstop=4  " Number of spaces that a <Tab> counts for while performing editing
"                    operations, like inserting a <Tab> or using <BS>.
set autoindent " Copy indent from current line when starting a new line
set expandtab " In Insert mode: Use the appropriate number of spaces to insert a
"               <Tab>.  Spaces are used in indents with the '>' and '<' commands and
"               when 'autoindent' is on.  To insert a real tab when 'expandtab' is
"               on, use CTRL-V<Tab>
"               Set 'tabstop' and 'shiftwidth' to whatever you prefer and use
"               'expandtab'.  This way you will always insert spaces.  The
"               formatting will never be messed up when 'tabstop' is changed.
set smartindent " Do smart autoindenting when starting a new line.  Works for C-like
"                 programs, but can also be used for other languages.  'cindent' does
"                 something like this, works better in most cases, but is more strict

" Search
set hlsearch
set incsearch
set smartcase
set ignorecase
set scrolloff=5

" Tabs
set tabpagemax=7
set showtabline=2
map tn :tabnew .<cr>
map tc :tabclose<cr>

" Fold
set foldmethod=indent
set foldlevel=2

" Storage
" centralize backups, swapfiles and undo history
set backupdir=~/.vim/.backups
set directory=~/.vim/.swaps
if exists("&undodir")
    set undodir=~/.vim/.undo
endif

" File Specials
autocmd FileType text setlocal textwidth=80
autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
autocmd FileType jade setlocal shiftwidth=2 tabstop=2
autocmd FileType stylus setlocal shiftwidth=2 tabstop=2

" Display
set ruler " Show the line and column number of the cursor position, separated by a comma.
set showcmd " Show (partial) command in the last line of the screen.
set cmdheight=1 " Number of screen lines to use for the command-line.
set number " Print the line number in front of each line.
set laststatus=2 " The value of this option influences when the last window will have a
"                  status line:
"                    0: never
"                    1: only if there are at least two windows
"                    2: always
set cursorline " Highlight the screen line of the cursor with CursorLine
set wildmenu " When 'wildmenu' is on, command-line completion operates in an enhanced
"              mode.  On pressing 'wildchar' (usually <Tab>) to invoke completion,
"              the possible matches are shown just above the command line, with the
"              first match highlighted (overwriting the status line, if there is
"              one).  Keys that show the previous/next match, such as <Tab> or
"              CTRL-P/CTRL-N, cause the highlight to move to the appropriate match.
"set wildchar=
"set wildmode=
set completeopt=menu,preview " A comma separated list of options for Insert mode completion
" tab characters display dot
set list!
set listchars=tab:>-
" highlight trailing whitespace
autocmd ColorScheme * highlight TrailWhitespace ctermbg=red guibg=red
highlight TrailWhitespace ctermbg=red guibg=red
match TrailWhitespace /\s\+$/

" get rid of the fucking preview window
set completeopt-=preview


"""""""""""""""""""
" System Specials "
"""""""""""""""""""
if has("win32")
    set rtp+=~/.vim/
    source $VIMRUNTIME/delmenu.vim
    source $VIMRUNTIME/menu.vim
    language messages zh_CN.utf-8
    if has("gui_running")
        set lines=999 columns=100
    endif
endif

if has("gui_running")
    set mouse=a
endif


""""""""""
" Colors "
""""""""""
colorscheme caciano

if has("gui_running")
    set guioptions-=M
    set guioptions-=T
    if !empty(globpath(&rtp, 'colors/github.vim'))
        colorscheme github
    else
        colorscheme murphy
    endif
    if has("win32")
        "set guifont=Consolas:h11:cANSI
        set guifont=Consolas:h11:cDEFAULT
    endif
endif

if has("gui_running") || &t_Co == 256
    highlight Pmenu ctermbg=234 guibg=#606060
    highlight PmenuSel ctermbg=17 guifg=#dddd00
    highlight PmenuSbar ctermbg=17 guibg=#d6d6d6
else
    highlight Pmenu ctermbg=0
    highlight PmenuSel ctermbg=4
    highlight PmenuSbar ctermbg=7
endif


""""""""""""""""""""
" Custom Functions "
""""""""""""""""""""

" Strip trailing whitespace (\ss)
function! StripWhitespace()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    :%s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfunction

" When editing a file, always jump to the last cursor position
autocmd BufReadPost *
      \ if ! exists("g:leave_my_cursor_position_alone") |
      \     if line("'\"") > 0 && line ("'\"") <= line("$") |
      \         exe "normal g'\"" |
      \     endif |
      \ endif

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
let g:nerdtree_tabs_open_on_gui_startup=0

" tagbar
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
au Syntax * RainbowParenthesesLoadBraces

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

" flake8
" let g:flake8_ignore="E501,W806"

" powerline
" let g:Powerline_symbols = 'fancy'

" syntastic
let g:syntastic_python_checker = 'flake8'
let g:syntastic_python_checker_args='--ignore=E501,W404,W801'

"""""""""""
" Keymaps "
"""""""""""
nmap <F8> :TagbarToggle<cr>
nmap <F4> :NERDTreeToggle<cr>
nmap <F7> :GundoToggle<cr>
nmap <F10> :IndentGuidesToggle<cr>
noremap <leader>ss :call StripWhitespace()<CR>
" Save a file as root (,W)
noremap <leader>W :w !sudo tee % > /dev/null<CR>

" easier navigation between split windows
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

map <C-n> :tabnext<cr>
map <C-p> :tabprevious<cr>

" recover from accidental Ctrl-U
inoremap <C-U> <C-G>u<C-U>
inoremap <c-w> <c-g>u<c-w>

" Fix syntax highlighting,
noremap <F5> <Esc>:syntax sync fromstart<CR>
inoremap <F5> <C-o>:syntax sync fromstart<CR>

" :map <F2> :w\|!python %<CR>

""""""""""
" Python "
""""""""""
" Add the virtualenv's site-packages to vim path
if has('python')
py << EOF
import os.path
import sys
import vim
if 'VIRTUAL_ENV' in os.environ:
    project_base_dir = os.environ['VIRTUAL_ENV']
    sys.path.insert(0, project_base_dir)
    activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
    execfile(activate_this, dict(__file__=activate_this))
EOF
endif

"TODO sequence number on tabline

hi TabLine           cterm=underline ctermfg=0    ctermbg=7   gui=underline guibg=#6c6c6c guifg=White
hi TabLineSel        cterm=bold      gui=NONE      guifg=White
hi TabLineFill       cterm=reverse   gui=reverse
" Reload Vimrc
map <silent> <leader>V :source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>
