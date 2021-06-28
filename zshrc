# vim: set ft=zsh:
##############################################################################
# oh-my-zsh
##############################################################################

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
ZSH_THEME=""  # disable ZSH theme, for pure

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$HOME/.oh-my-zsh-custom

plugins=( autoenv2 )
#plugins=( autoenv2 forgit )

source $ZSH/oh-my-zsh.sh


##############################################################################
# my zsh
##############################################################################
# use pure prompt
fpath+=$HOME/.zsh-pure
autoload -U promptinit; promptinit
prompt pure

# Load other parts of zshrc
source $HOME/.zshrc_os
source $HOME/.zshrc_fzf

# Load shell color
#SHELL_COLOR="$HOME/.shell-colors/base16-default.dark.sh"
#[[ -s $SHELL_COLOR ]] && source $SHELL_COLOR

function _timestamp_ms() {
    if [[ "$(uname)" == "Darwin" ]]; then
        echo $(gdate +%s%3N)
    else
        echo $(date +%s%3N)
    fi
}

#RC_DEBUG="true"
RC_DEBUG="false"

if [[ $RC_DEBUG == "true" ]]; then
    # source with timer
    function source() {
        local ts=$(_timestamp_ms)
        builtin source $1
        local te=$(_timestamp_ms)
        echo "$(($te - $ts))ms: source $1"
    }

    # eval with timer
    #function eval() {
    #    local ts=$(_timestamp_ms)
    #    builtin eval $1
    #    local te=$(_timestamp_ms)
    #    echo "$(($te - $ts))ms: eval $1"
    #}
fi

#################
# Program Inits #
#################

# Load z
export _Z_DATA=$HOME/.z-data
source $HOME/.z/z.sh

# Python
if [ -e $HOME/.pythonrc.py ]; then
    export PYTHONSTARTUP=$HOME/.pythonrc.py
fi

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# fd respects .gitignore
export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# other opts: "--exact"
export FZF_DEFAULT_OPTS="--height 50% --no-mouse"

# Use fd for listing path candidates.
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# tag
if (( $+commands[tag] )); then
  export TAG_SEARCH_PROG=ag  # replace with rg for ripgrep
  tag() { command tag "$@"; source ${TAG_ALIAS_FILE:-/tmp/tag_aliases} 2>/dev/null }
  alias ag=tag  # replace with rg for ripgrep
fi

#########################
# Environment Variables #
#########################

# Prefer US English and use UTF-8
export LC_ALL="en_US.UTF-8"
export LANG=en_US.UTF-8

# Less
export LESSCHARSET=utf-8
export LESS='-R'
#export LESSOPEN='|~/.lessfilter %s'
export LESS_TERMCAP_mb=$(printf "\e[1;31m")
export LESS_TERMCAP_md=$(printf "\e[1;31m")
export LESS_TERMCAP_me=$(printf "\e[0m")
export LESS_TERMCAP_se=$(printf "\e[0m")
export LESS_TERMCAP_so=$(printf "\e[1;44;33m")
export LESS_TERMCAP_ue=$(printf "\e[0m")
export LESS_TERMCAP_us=$(printf "\e[1;32m")
# For more about termcap see:
# https://www.gnu.org/software/termutils/manual/termcap-1.3/html_chapter/termcap_4.html
# http://boredzo.org/blog/archives/2016-08-15/colorized-man-pages-understood-and-customized

export EDITOR=nvim

# mosh
export MOSH_PREDICTION_DISPLAY=always

# httpstat
export HTTPSTAT_SHOW_BODY=false
export HTTPSTAT_SHOW_IP=true
export HTTPSTAT_SHOW_SPEED=true
export HTTPSTAT_SAVE_BODY=true

# csvless
export CSVLESS_MAX_COLUMN_WIDTH=64
export CSVLESS_LINE_NUMBERS=1
export CSVLESS_TABLE_STYLE=markdown

# exa
if [[ -x /usr/local/bin/exa ]]; then
  alias ls='exa'
  alias l='exa -lg --time-style=long-iso --git'
  alias ll='exa -lga --time-style=long-iso --git'
elif [[ $(uname -s) == Linux ]]; then
  alias ls='ls --color=auto -N'
  alias l='ls -lF --time-style=long-iso'
  alias ll='ls -alF --time-style=long-iso'

  # ls colors, described as: foreground, background
  #               1. directory: bold blue
  #               | 2. symbolic link: magenta
  #               | | 3. socket: red, bold blue
  #               | | | 4. pipe: black, bold blue
  #               | | | | 5. executable: red
  #               | | | | | 6. block special: default, bold blue
  #               | | | | | | 7. character special: light grey, bold blue
  #               | | | | | | | 8. executable with setuid bit set: light grey, bold red
  #               | | | | | | | | 9. executable with setgid bit set: black, bold brown
  #               | | | | | | | | | 10. directory writable to others, with sticky bit: black, bold green
  #               | | | | | | | | | | 11. directory writable to others, without sticky bit: black, brown
  #               | | | | | | | | | | |
  export LSCOLORS=ExfxbEaEbxxEhEhBaDaCad
fi

# disable virtualenv default PS1
#export VIRTUAL_ENV_DISABLE_PROMPT="true"
# unset so that pure.zsh can work
unset VIRTUAL_ENV_DISABLE_PROMPT

#######
# zsh #
#######

# Disable autocorrect
unsetopt correct_all

# Auto rehash
#zstyle ":completion:*:commands" rehash 1

# History search
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

# SSH completion
zstyle ':completion:*:ssh-hosts' users-hosts $ssh_hosts
hosts=$(awk '/^Host / {printf("%s ",$2)}' ~/.ssh/config 2>/dev/null)
zstyle ':completion:*:hosts' hosts $ssh_hosts


#############
# Functions #
#############

# Create a data URL from an image (works for other file types too, if you tweak the Content-Type afterwards)
function dataurl() {
  echo "data:image/${1##*.};base64,$(openssl base64 -in "$1")" | tr -d '\n'
}

# Start an HTTP server from a directory, optionally specifying the port
function server() {
  local port="${1:-8000}"
  open "http://localhost:${port}/"
  # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
  # And serve everything as UTF-8 (although not technically correct, this doesn't break anything for binary files)
  python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port"
}

# Get a character's Unicode code point, requires `python3` and `column` on PATH
function codepoint() {
  python3 -c "$(cat << EOF
import sys
import subprocess as sp
def usage(*args):
    if args:
      print(*args)
    print('Usage: codepoint <chars>')
try:
    chars = sys.argv[1]
except IndexError:
    usage('invalid arguments, <chars> missing')
    sys.exit(1)
if chars == '-h':
    usage()
    sys.exit()
def show_char(c):
    print('Char: {}, ')
h = ['Char', 'Ord', 'Hex', 'Code_Point']
d = [h]
for i in chars:
    n = ord(i)
    x = hex(n)
    xs = str(x)[2:]
    if len(xs) < 4:
      xs = '0' * (4 - len(xs)) + xs
    cp = 'U+' + xs
    d.append([i, str(n), str(x), cp])
text = '\n'.join(' '.join(l) for l in d) + '\n'
p = sp.Popen(['column', '-t'], stdin=sp.PIPE, stdout=sp.PIPE, stderr=sp.PIPE)
out, err = p.communicate(text.encode())
if p.returncode == 0:
    print(out.decode())
else:
    print('Out: {}\n\nErr:{}'.format(out.decode(), err.decode()))
    sys.exit(p.returncode)
EOF
)" $@
}

function sshfwd() {
    # Options explaination
    #   q  Quiet mode.  Causes most warning and diagnostic messages to be suppressed.
    #   T  Disable pseudo-tty allocation.
    #   N  Do not execute a remote command.  This is useful for just forwarding ports (protocol version 2 only).
    #   D  bind address to port
    ssh -qTNv -D 7070 $@
}

function colortable256() {
    for i in {0..255} ; do
        printf "\x1b[38;5;${i}mcolour${i}\n"
    done
}

function urlencode() {
    python -c 'import urllib, sys; print urllib.quote(sys.argv[1])' $1
}

function aws-du() {
    aws s3 ls --summarize --human-readable --recursive s3://$@
}

function download_benchmark() {
    DOWNLOAD_SPEED=`wget -O /dev/null $1 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}'`
    echo "$DOWNLOAD_SPEED ($1)"
}

function tarczf() {
    tar czf $1.tar.gz $1
}

function ips() {
    curl ip.cn/$1
}

function py_find_packages() {
    python -c 'from setuptools import find_packages; print find_packages()'
}

function td() {
    local dir="$(basename $PWD)"
    dir="${dir/./-}"
    tmux has-session -t "=$dir" 2>/dev/null 1>&2
    if [ $? -eq 0 ]; then
        tmux a -t "=$dir"
    else
        tmux new -s "$dir"
    fi
}

function tmux-resurrect-reset-last() {
    cd ~/.tmux/resurrect && \
        ln -f -s $(/bin/ls -t tmux_resurrect_*.txt | head -n 1) last && \
        /bin/ls -l last
}


# fbr - checkout git branch (including remote branches), sorted by most recent commit, limit 30 last branches
gco() {
  local branches branch
  branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

fbr() {
  git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)" | fzf
}

function lesshelp() {
    $@ --help | less
}

function pve-new() {
    if [ -n "$1" ]; then
        local venv="${1%/}"
    else
        local venv="venv"
    fi
    echo "Create virtualenv $venv"
    python -m venv "$venv"
    echo "Activiate virtualenv $venv"
    eval "source $venv/bin/activate"
}

function pve-activate() {
    if [ -n "$1" ]; then
        local venv="${1%/}"
    else
        local venv="venv"
    fi
    echo "Activiate virtualenv $venv"
    eval "source $venv/bin/activate"
}

function ssldates() {
    host=$1;
    port=${2:-443};
    openssl s_client -connect $host:$port -servername $host 2>&1 < /dev/null | openssl x509 -noout -dates
}


###########
# Aliases #
###########

alias lsd='ls -ld */'
alias vim="nvim -p"
alias vim0="/usr/local/bin/vim -p"
# TODO vim1
alias tree="tree --dirsfirst"
alias cleanpyc="find . -name '*.pyc' -exec rm {} \;"
alias cleanpycache="find . -type d -name '__pycache__' -prune -exec rm -r {} \;"

# Load local at last
if [ -e "$HOME/.zshrc_local" ]; then
    source $HOME/.zshrc_local
fi

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
