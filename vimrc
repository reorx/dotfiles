" File Encoding
set encoding=utf-8
set fileencodings=utf-8,chinese,latin-1

set fileencoding=utf-8

if has("win32")
    source $VIMRUNTIME/delmenu.vim
    source $VIMRUNTIME/menu.vim
    language messages zh_CN.utf-8
endif
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
"Bundle 'gmarik/vundle'

" basics
Bundle 'SuperTab-continued.'
Bundle 'taglist.vim'
Bundle 'nvie/vim-flake8'
Bundle 'mattn/zencoding-vim'
Bundle 'scrooloose/nerdtree'
Bundle 'jistr/vim-nerdtree-tabs'

Bundle 'sessionman.vim'
Bundle 'scratch.vim'
Bundle 'scrooloose/nerdcommenter'
" required by FuzzyFinder
" Bundle 'L9'
" Bundle 'FuzzyFinder'

Bundle 'Reorx/vim-colors-solarized'
" Bundle 'jade.vim'
Bundle 'digitaltoad/vim-jade'
Bundle 'wavded/vim-stylus'
" Bundle 'wavded/vim-stylus'
" Bundle 'skammer/vim-css-color'
Bundle 'lepture/vim-javascript'


"""""""""""
" Plugins "
"""""""""""
" flake8
autocmd FileType python map <buffer> <F9> :call Flake8()<CR>
autocmd BufWritePost *.py call Flake8()
let g:flake8_ignore="E501,W293"
" supertab
" Havn't got how it works, and cause problems when after dot char
" let g:SuperTabDefaultCompletionType = "context"
" nerdtree
let NERDTreeWinPos='left'
let NERDTreeWinSize=25
let NERDTreeAutoCenter=1
let NERDChristmasTree=1
let NERDTreeShowHidden=0
let NERDTreeChDirMode=1
let NERDTreeMouseMode=2
"let NERDTreeQuitOnOpen=1
map <silent> <F4> :NERDTreeToggle<cr>
" taglist
let Tlist_Inc_Winwidth=0
" let Tlist_WinWidth=20
let Tlist_Auto_Highlight_Tag=1
let Tlist_Show_One_File=1
let Tlist_Use_Right_Window=1
let Tlist_Exit_OnlyWindow=1
let Tlist_Auto_Open=0
let Tlist_Enable_Fold_Column=1
let Tlist_Auto_Update=1
" let Tlist_Use_SingleClick = 1
map <silent> <F8> :TlistToggle<cr>


" Extra
"set list!
"set listchars=tab:··,trail:·

" System
set nocompatible

" General
set nobackup
set history=5
set autoread " When a file has been detected to have been changed outside of Vim and
"              it has not been changed inside of Vim, automatically read it again.
"              When the file has been deleted this is not done.
syntax on
filetype plugin indent on " required by Vundle


set ff=unix

set backspace=indent,eol,start
" Indent
set smarttab " a <Tab> in front of a line inserts blanks according to
"              'shiftwidth'.  'tabstop' or 'softtabstop' is used in other places
set shiftwidth=4 " Number of spaces to use for each step of (auto)indent.
set tabstop=4 " Number of spaces that a <Tab> in the file counts for. 
set softtabstop=4  " Number of spaces that a <Tab> counts for while performing editing
"                    operations, like inserting a <Tab> or using <BS>.
set expandtab " In Insert mode: Use the appropriate number of spaces to insert a
"               <Tab>.  Spaces are used in indents with the '>' and '<' commands and
"               when 'autoindent' is on.  To insert a real tab when 'expandtab' is
"               on, use CTRL-V<Tab>
"               Set 'tabstop' and 'shiftwidth' to whatever you prefer and use
"               'expandtab'.  This way you will always insert spaces.  The
"               formatting will never be messed up when 'tabstop' is changed.
" set smartindent " Do smart autoindenting when starting a new line.  Works for C-like
"                 programs, but can also be used for other languages.  'cindent' does
"                 something like this, works better in most cases, but is more strict
set autoindent " Copy indent from current line when starting a new line
retab " Replace all sequences of white-space containing a
"       <Tab> with new strings of white-space using the new
"       tabstop value given.  If you do not specify a new
"       tabstop size or it is zero, Vim uses the current value
"       of 'tabstop'.
"       The current value of 'tabstop' is always used to
"       compute the width of existing tabs.
"       With !, Vim also replaces strings of only normal
"       spaces with tabs where appropriate.
"       With 'expandtab' on, Vim replaces all tabs with the
"       appropriate number of spaces.
"       This command sets 'tabstop' to the new value given,
"       and if performed on the whole file, which is default,
"       should not make any visible change.
"       Careful: This command modifies any <Tab> characters
"       inside of strings in a C program.  Use "\t" to avoid
"       this (that's a good habit anyway).
"       ":retab!" may also change a sequence of spaces by
"       <Tab> characters, which can mess up a printf().
"       {not in Vi}
"       Not available when |+ex_extra| feature was disabled at
"       compile time.

" Search
set hlsearch
set incsearch
set smartcase

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
set guioptions-=M
set guioptions-=T
set guifontset=Monospace\ 9

" Color
"
" set t_Co=256

" try to fild solarized on global path
if !empty(globpath(&rtp, 'colors/caciano.vim'))
    colorscheme caciano
elseif !empty(globpath(&rtp, 'colors/solarized.vim'))
    " let g:solarized_termcolors=256
    set background=dark
    colorscheme solarized
else
    colorscheme torte
endif

highlight Pmenu ctermbg=238 gui=bold
highlight ExtraWhitespace ctermbg=black guibg=black
" highlight TheTabShift ctermbg=red guibg=red

autocmd ColorScheme * highlight ExtraWhitespace ctermbg=black guibg=black
" autocmd ColorScheme * highlight TheTabShift ctermbg=red guibg=red

match ExtraWhitespace /\s\+$/
" match TheTabShift /\t/

" Fold
"set fold
set foldmethod=indent


" Options
"set noswapfile

" setlocal omnifunc=pysmell


" Tabs
set tabpagemax=7
set showtabline=2
map <C-n> :tabnext<cr>
map <C-p> :tabprevious<cr>
map tn :tabnew .<cr>
map tc :tabclose<cr>


" Files
autocmd FileType text setlocal textwidth=80
autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
autocmd FileType jade setlocal shiftwidth=2 tabstop=2
autocmd FileType stylus setlocal shiftwidth=2 tabstop=2

" Keymaps
inoremap <C-U> <C-G>u<C-U>
" Fix syntax highlighting,
" further reading: http://vim.wikia.com/wiki/Fix_syntax_highlighting?diff=33340&oldid=prev
noremap <F5> <Esc>:syntax sync fromstart<CR>
inoremap <F5> <C-o>:syntax sync fromstart<CR>


" Centralize backups, swapfiles and undo history
set backupdir=~/.vim/.backups
set directory=~/.vim/.swaps
if exists("&undodir")
	set undodir=~/.vim/.undo
endif
" Ignore case of searches
set ignorecase

" Strip trailing whitespace (,ss)
function! StripWhitespace()
	let save_cursor = getpos(".")
	let old_query = getreg('/')
	:%s/\s\+$//e
	call setpos('.', save_cursor)
	call setreg('/', old_query)
endfunction
noremap <leader>ss :call StripWhitespace()<CR>
" Save a file as root (,W)
noremap <leader>W :w !sudo tee % > /dev/null<CR>
