" Author: reorx

" Should at the top since it will affect bundles.vim (maybe?)
set t_Co=256


" ============================================================================
" Load Bundles
" ============================================================================

" So that it can be easily accessed
"let $MYBUNDLES='~/.vim/bundles.vim'
"source $MYBUNDLES
let $MYPLUGS='~/.vim/plugs.vim'
source $MYPLUGS


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
autocmd FileType crontab setlocal nowritebackup

au BufRead,BufNewFile */sites-available/* set ft=nginx
au BufRead,BufNewFile */sites-enabled/* set ft=nginx
au BufRead,BufNewFile nginx.conf set ft=nginx
au BufRead,BufNewFile */nginx*/*.conf set ft=nginx

au BufRead,BufNewFile */supervisor/*.conf set ft=dosini

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

if has("unix")
    let s:uname = system("uname")
    if s:uname == "Darwin\n"
        " This will make vim and system sharing the same clipboard,
        " if this option is disabled, `:set paste` can be used to
        " to do ^ + C paste decently.
        set clipboard=unnamed
    endif
endif


" ============================================================================
" UI
" ============================================================================

" TODO NOTE
" define your colors
if !exists("autocmd_colorscheme_loaded")
  let autocmd_colorscheme_loaded = 1
  "autocmd ColorScheme * highlight Todo   ctermbg=LightGrey guibg=#BDBDBD ctermfg=DarkRed     guifg=#DD6676
  "autocmd ColorScheme * highlight Debug  ctermbg=LightGrey guibg=#BDBDBD ctermfg=DarkBlue    guifg=#96BADC
  autocmd ColorScheme * highlight Todo   ctermbg=DarkRed guibg=#BDBDBD ctermfg=LightGrey guifg=#DD6676
  autocmd ColorScheme * highlight Debug  ctermbg=DarkBlue guibg=#BDBDBD ctermfg=LightGrey guifg=#96BADC
endif

if &t_Co == 256
    colorscheme Tomorrow-Night-Bright
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

" When editing a file, always jump to the last cursor position
autocmd BufReadPost *
      \ if ! exists("g:leave_my_cursor_position_alone") |
      \     if line("'\"") > 0 && line ("'\"") <= line("$") |
      \         exe "normal g'\"" |
      \     endif |
      \ endif

function! MyToHtml(line1, line2)
  " make sure to generate in the correct format
  let old_css = 1
  if exists('g:html_use_css')
    let old_css = g:html_use_css
  endif
  let g:html_use_css = 0

  " generate and delete unneeded lines
  exec a:line1.','.a:line2.'TOhtml'
  %g/<body/normal k$dgg

  " convert body to a table
  %s/<body\s*\(bgcolor="[^"]*"\)\s*text=\("[^"]*"\)\s*>/<table \1 cellPadding=0><tr><td><font color=\2>/
  %s#</body>\(.\|\n\)*</html>#\='</font></td></tr></table>'#i

  " restore old setting
  let g:html_use_css = old_css
endfunction
command! -range=% MyToHtml :call MyToHtml(<line1>,<line2>)


" ============================================================================
" Keymaps
" ============================================================================

nmap <F8> :TagbarToggle<cr>
nmap <F4> :NERDTreeToggle<cr>
nmap <F7> :GundoToggle<cr>
nmap <F10> :IndentGuidesToggle<cr>

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

" :map <F2> :w\|!python %<CR>

" Reload Vimrc
map <silent> <leader>V :source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>

" Spell check
" http://vimdoc.sourceforge.net/htmldoc/spell.html
" http://vim.wikia.com/wiki/Toggle_spellcheck_with_function_keys


" ============================================================================
" Python
" ============================================================================

" Add the virtualenv's site-packages to vim path
if has('python')
py << EOF
import os
import sys
import vim
if 'VIRTUAL_ENV' in os.environ:
    env_base_dir = os.environ['VIRTUAL_ENV']
    sys.path.insert(0, env_base_dir)
    activate_this = os.path.join(env_base_dir, 'bin/activate_this.py')
    execfile(activate_this, dict(__file__=activate_this))
EOF
endif
