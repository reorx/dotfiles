" Author: reorx

" ============================================================================
" General
" ============================================================================

" Encoding
set encoding=utf-8
set fileencodings=utf-8,chinese,latin-1
set fileencoding=utf-8
set fencs=utf-8,chinese

syntax on
filetype on

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
inoremap # X<BS>#

" Search
set hlsearch
set incsearch
set smartcase
set ignorecase
set scrolloff=5

" Tabs
set tabpagemax=7
set showtabline=2
set splitright " To make vsplit put the new buffer on the right of the current buffer:

" Fold
set foldmethod=indent
"set foldlevel=2
set nofoldenable

" Storage
" centralize backups, swapfiles and undo history
"set backupdir=~/.vim/.backups
"set directory=~/.vim/.swaps
"set undodir=~/.vim/.undo

" File Specials
autocmd FileType text setlocal textwidth=80
autocmd FileType crontab setlocal nowritebackup

au BufRead,BufNewFile *.json set ft=json syntax=javascript
au BufRead,BufNewFile *.conf set ft=dosini
au BufRead,BufNewFile *.pac set ft=javascript

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

" netrw
let g:netrw_liststyle = 3

" A comma separated list of options for Insert mode completion
set completeopt=menu
" get rid of the fucking preview window
"set completeopt-=preview

" tab characters display dot
set list!
set listchars=tab:>-

"set list listchars=tab:»·

" highlight trailing whitespace
autocmd ColorScheme * highlight TrailWhitespace ctermbg=red guibg=red
highlight TrailWhitespace ctermbg=red guibg=red
match TrailWhitespace /\s\+$/

set mouse=a

" Prevent flashing when execute external command from vim
set shellpipe=&>


" ============================================================================
" System Specials "
" ============================================================================

"if has("win32")
    "set rtp+=~/.vim/
    "source $VIMRUNTIME/delmenu.vim
    "source $VIMRUNTIME/menu.vim
    "language messages zh_CN.utf-8
    "if has("gui_running")
        "set lines=999 columns=100
    "endif
"endif

"if has("unix")
"    let s:uname = system("uname")
"    if s:uname == "Darwin\n"
"        " This will make vim and system sharing the same clipboard,
"        " if this option is disabled, `:set paste` can be used to
"        " to do ^ + C paste decently.
"        set clipboard=unnamed
"    endif
"endif


" ============================================================================
" UI
" ============================================================================

" TODO NOTE
" define your colors
"if !exists("autocmd_colorscheme_loaded")
"  let autocmd_colorscheme_loaded = 1
"  "autocmd ColorScheme * highlight Todo   ctermbg=LightGrey guibg=#BDBDBD ctermfg=DarkRed     guifg=#DD6676
"  "autocmd ColorScheme * highlight Debug  ctermbg=LightGrey guibg=#BDBDBD ctermfg=DarkBlue    guifg=#96BADC
"  autocmd ColorScheme * highlight Todo   ctermbg=DarkRed guibg=#BDBDBD ctermfg=LightGrey guifg=#DD6676
"  autocmd ColorScheme * highlight Debug  ctermbg=DarkBlue guibg=#BDBDBD ctermfg=LightGrey guifg=#96BADC
"endif


" Should at the top since it will affect bundles.vim (maybe?)
if $TERM == "xterm-256color"
    set t_Co=256
elseif $TERM == "screen-256color"
    set t_Co=256
endif

if &t_Co == 256
    set background=dark
    highlight Pmenu ctermbg=234 guibg=#606060
    highlight PmenuSel ctermbg=17 guifg=#dddd00
    highlight PmenuSbar ctermbg=17 guibg=#d6d6d6
else
    colorscheme caciano
    highlight Pmenu ctermbg=0
    highlight PmenuSel ctermbg=4
    highlight PmenuSbar ctermbg=7
endif

if has("gui_running")
    set guioptions-=M
    set guioptions-=T
endif

if has("autocmd")
  " Highlight TODO, FIXME, NOTE, etc.
  if v:version > 701
    autocmd Syntax * call matchadd('Todo',  '\W\zs\(TODO\|FIXME\|CHANGED\|XXX\|BUG\|HACK\)')
    autocmd Syntax * call matchadd('Debug', '\W\zs\(NOTE\|INFO\|IDEA\)')
  endif
endif

"TODO sequence number on tabline

hi TabLine           cterm=underline ctermfg=0     ctermbg=7   gui=underline guibg=#6c6c6c guifg=White
hi TabLineSel        cterm=bold      gui=NONE      guifg=White
hi TabLineFill       cterm=reverse   gui=reverse

" Diff
highlight DiffAdd    cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffDelete cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffChange cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffText   cterm=bold ctermfg=10 ctermbg=88 gui=none guifg=bg guibg=Red

" Ruler
set colorcolumn=79

" Other highlights
highlight Visual cterm=reverse ctermbg=NONE

" When editing a file, always jump to the last cursor position
autocmd BufReadPost *
      \ if ! exists("g:leave_my_cursor_position_alone") |
      \     if line("'\"") > 0 && line ("'\"") <= line("$") |
      \         exe "normal g'\"" |
      \     endif |
      \ endif

" ============================================================================
" Keymaps
" ============================================================================

" Leader key
"let mapleader = "\\"
let mapleader = " "

" Fix syntax highlighting, TODO with RainbowBraces
noremap <F5> <Esc>:syntax sync fromstart<CR>
inoremap <F5> <C-o>:syntax sync fromstart<CR>
noremap <leader>ss :call StripWhitespace()<CR>

" Save a file as root (,W)
noremap <leader>W :w !sudo tee % > /dev/null<CR>

" easier navigation between split windows
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

map tn :tabnew<cr>
map tc :tabclose<cr>

map <C-n> :tabnext<cr>
map <C-p> :tabprevious<cr>
nmap <Leader>[ :tabp<CR>
nmap <Leader>] :tabn<CR>
"map <C-]> :tabnext<cr>
"map <C-[> :tabprevious<cr>

" recover from accidental Ctrl-U
inoremap <C-U> <C-G>u<C-U>
inoremap <c-w> <c-g>u<c-w>

" Reload Vimrc
map <silent> <leader>V :source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>


" ============================================================================
" Commands
" ============================================================================

" Strip trailing whitespace (\ss)
function! StripWhitespace()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    :%s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfunction

func! DisableAutoIndent()
    setlocal noautoindent
    setlocal nocindent
    setlocal nosmartindent
    setlocal indentexpr=
    echo 'Auto indent is disabled by many ways'
endfu

com! DisableAutoIndent call DisableAutoIndent()

func! SetTabstop(size)
    let &l:tabstop=a:size
    let &l:shiftwidth=a:size
    let &l:softtabstop=a:size
endfu

com! -nargs=1 SetTabstop call SetTabstop(<f-args>)

" Spell check
" http://vimdoc.sourceforge.net/htmldoc/spell.html
" http://vim.wikia.com/wiki/Toggle_spellcheck_with_function_keys

func! ToggleSpell()
    execute "setlocal spell! spelllang=en_us"
endfu

com! ToggleSpell call ToggleSpell()


" Get visual selected text in vim, the only useful answer on the Internet:
" https://stackoverflow.com/a/6271254/596206
function! GetVisualSelection()
    " Why is this not a built-in Vim script function?!
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction

" Edit configs
func! MyVimrc()
    execute "edit $MYVIMRC"
endfu
com! MyVimrc call MyVimrc()

func! MyPlugs()
    execute "edit $MYPLUGS"
endfu
com! MyPlugs call MyPlugs()


" ============================================================================
" Load plugins
" ============================================================================
" NOTE: because nvim has been a successful replace for vim,
" this vimrc stopped to provide plugins to keep a minimal basic configuration

" load plugins (could be removed)
let $MYPLUGS='~/.vim/plugs.vim'
source $MYPLUGS
