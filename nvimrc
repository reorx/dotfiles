" ============================================================================
" UI
" ============================================================================

" Should at the top since it will affect bundles.vim (maybe?)
if $TERM == "xterm-256color"
    set t_Co=256
elseif $TERM == "screen-256color"
    set t_Co=256
endif

if has("termguicolors")
    set termguicolors
endif

" Ruler
set colorcolumn=79


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
set splitbelow

" Fold
set foldmethod=indent
"set foldlevel=2
set nofoldenable

" Display
set ruler " Show the line and column number of the cursor position, separated by a comma.
set showcmd " Show (partial) command in the last line of the screen.
set cmdheight=1 " Number of screen lines to use for the command-line.
set rnu " relative number
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

" A comma separated list of options for Insert mode completion
set completeopt=menuone,longest
" get rid of the fucking preview window
"set completeopt-=preview

" Storage
" centralize backups, swapfiles and undo history
set backupdir=~/.nvim/.backups
set directory=~/.nvim/.swaps
if exists("&undodir")
    set undodir=~/.nvim/.undo
endif

" File Specials
"autocmd FileType text setlocal textwidth=80
autocmd FileType javascript setlocal shiftwidth=2 tabstop=2
autocmd FileType crontab setlocal nowritebackup
autocmd FileType yaml setlocal shiftwidth=2 tabstop=2 indentexpr=
autocmd FileType html setlocal shiftwidth=2 tabstop=2 indentexpr=
autocmd FileType scss setlocal shiftwidth=2 tabstop=2 indentexpr=
autocmd FileType pico8 setlocal noexpandtab shiftwidth=2 tabstop=2 softtabstop=2

"autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
au BufRead,BufNewFile */nginx*/*.conf set ft=nginx
au BufRead,BufNewFile */supervisor/*.conf set ft=dosini
au BufRead,BufNewFile *.conf set ft=dosini
au BufRead,BufNewFile *.pac set ft=javascript

" When editing a file, always jump to the last cursor position
autocmd BufReadPost *
      \ if ! exists("g:leave_my_cursor_position_alone") |
      \     if line("'\"") > 0 && line ("'\"") <= line("$") |
      \         exe "normal g'\"" |
      \     endif |
      \ endif

" Misc
set mouse=a

" Prevent flashing when execute external command from vim
set shellpipe=&>

" netrw
let g:netrw_liststyle = 3

" quickfix list auto height
au FileType qf call AdjustWindowHeight(3, 10)
function! AdjustWindowHeight(minheight, maxheight)
  exe max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
endfunction


" ============================================================================
" Highlight
" ============================================================================

" Line number
highlight LineNr term=bold gui=NONE guifg=gray25 guibg=gray13

" Highlight TODO, FIXME, NOTE, etc.
autocmd Syntax * call matchadd('Todo',  '\W\zs\(TODO\|FIXME\|CHANGED\|XXX\|BUG\|HACK\)')
autocmd Syntax * call matchadd('Debug', '\W\zs\(NOTE\|INFO\|IDEA\)')

" Diff
highlight DiffAdd    cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffDelete cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffChange cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffText   cterm=bold ctermfg=10 ctermbg=88 gui=none guifg=bg guibg=Red

" tab characters display dot
set list!
set listchars=tab:>-
"	<- a tab char

" highlight tab char
autocmd ColorScheme * highlight Whitespace ctermbg=gray guibg=gray10 guifg=gray20
highlight Whitespace ctermbg=gray guibg=gray10 guifg=gray20

" highlight trailing whitespace (now controlled by vim-better-whitespace)
"autocmd ColorScheme * highlight TrailWhitespace ctermbg=red guibg=gray40
"highlight TrailWhitespace ctermbg=red guibg=gray40
"match TrailWhitespace /\s\+$/

" ============================================================================
" Custom Functions
" ============================================================================

" Strip trailing whitespace (\ss)
function! StripWhitespace()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    :%s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfunction


" ============================================================================
" Keymaps
" ============================================================================

" paste without overwritting register
" https://stackoverflow.com/q/290465/596206
xnoremap p pgvy

" Fix syntax highlighting
noremap <F5> <Esc>:syntax sync fromstart<CR>
inoremap <F5> <C-o>:syntax sync fromstart<CR>

"let mapleader = "\\"
let mapleader = " "
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
"nmap <Leader>n :tabn<CR>
"nmap <Leader>p :tabp<CR>

" recover from accidental Ctrl-U
inoremap <C-U> <C-G>u<C-U>
inoremap <c-w> <c-g>u<c-w>


" ============================================================================
" Commands
" ============================================================================

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


func! Hello(who)
    if a:who=='world'
        echo "Hello ".a:who
    endif
endfu
com! -nargs=1 Hello call Hello(<f-args>)


" Snippets (deprecated since using UltiSnips)
com! Noqa call setline('.', getline('.') . '  # NOQA')
"com! HeadUTF call append(line('.')-1, '# coding: utf-8')
"com! HeadPython call append(line('.')-1, '#!/usr/bin/env python')
"com! PythonMain call append(line('.'), "if __name__ == '__main__':")


" Edit configs
func! MyVimrc()
    execute "edit $MYVIMRC"
endfu
com! MyVimrc call MyVimrc()

func! MyPlugs()
    execute "edit $MYPLUGS"
endfu
com! MyPlugs call MyPlugs()
