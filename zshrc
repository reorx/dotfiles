# vim: set ft=zsh:
##############################################################################
# oh-my-zsh
##############################################################################
# profiling start
#zmodload zsh/zprof

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.ohmyzsh

# Settings ref: https://github.com/ohmyzsh/ohmyzsh/wiki/Settings

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
ZSH_THEME=""  # disable ZSH theme, for pure

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Use this setting to disable the Oh My Zsh logic to automatically set ls color
# output based on the system you're running and which ls commands are available.
DISABLE_LS_COLORS=true


# Plugins
# use ohmyzsh's nvm plugin to enable lazy loading of nvm, thus the zsh startup could be quick af
zstyle ':omz:plugins:nvm' lazy yes
plugins=( nvm )

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

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# fd respects .gitignore
export FZF_DEFAULT_COMMAND='fd -H -t f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# other opts: "--ezact"
export FZF_DEFAULT_OPTS=( --height "50%" --no-mouse )

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

# eza
if ( type eza >/dev/null 2>&1 ); then
  alias ls='eza'
  alias l='eza -lg --time-style=long-iso --git'
  alias ll='eza -lga --time-style=long-iso --git'
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

function download_benchmark() {
    DOWNLOAD_SPEED=`wget -O /dev/null $1 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}'`
    echo "$DOWNLOAD_SPEED ($1)"
}

function tarczf() {
    tar czf $1.tar.gz $1
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

# openssl function series

function ssl-dates() {
    host=$1;
    port=${2:-443};
    openssl s_client -connect $host:$port -servername $host 2>&1 < /dev/null | openssl x509 -noout -dates
}

function ssl-chain() {
    host=$1;
    port=${2:-443};
    openssl s_client -connect $host:$port -servername $host 2>&1 < /dev/null | sed -n '1,/^---$/d;/^---$/,$!p'
}

function ssl-chain-resolve() {
    host=$1;
    port=${2:-443};
    ip=$3;
    openssl s_client -connect $ip:$port -servername $host 2>&1 < /dev/null | sed -n '1,/^---$/d;/^---$/,$!p'
}

function ssl-text() {
    host=$1;
    port=${2:-443};
    openssl s_client -connect $host:$port -servername $host 2>&1 < /dev/null | openssl x509 -text
}

function ssl-download-crt() {
    host=$1;
    port=${2:-443};
    openssl s_client -connect $host:$port -servername $host 2>&1 < /dev/null |\
        sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $1.crt
}

# docker functions

function divein {
    docker exec -it $1 /bin/bash
}

function runsh {
    docker run -it --rm $1 /bin/sh
}

function imagesize {
    docker image inspect $@ --format='{{.RepoTags}} {{.Size}}'
}

# python functions
#
function uuid {
    python -c 'import uuid; print(str(uuid.uuid4()), end="")'
}

function iso8601 {
    python -c 'import datetime as dt; print(dt.datetime.now().isoformat()[:-3] + "Z")'
}

function urlencode() {
    python -c 'import urllib, sys; print urllib.quote(sys.argv[1])' $1
}

function py_find_packages() {
    python -c 'from setuptools import find_packages; print find_packages()'
}

function b64encode() {
    python -c 'import sys, base64 as b64; print(b64.b64encode(sys.stdin.read().encode()).decode())'
}

function b64decode() {
    python -c 'import sys, base64 as b64; print(b64.b64decode(sys.stdin.read().encode()).decode())'
}

function jsonstr() {
    python -c 'import sys, json; s = sys.stdin.read(); print(json.dumps(s))'
}

# Start an HTTP server from a directory, optionally specifying the port
function server() {
  local port="${1:-8000}"
  open "http://localhost:${port}/"
  # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
  # And serve everything as UTF-8 (although not technically correct, this doesn't break anything for binary files)
  python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port"
}

function link-local-bin() {
    if [ -n "$2" ]; then
        ln -s "$PWD/$1" ~/.local/bin/$2
    else
        ln -s "$PWD/$1" ~/.local/bin
    fi
}

function tmp-upload() {
    local download_url=$(curl --upload-file ./$1 https://transfer.sh/$1)
    echo "curl -o $1 $download_url"
    echo "curl -o $1 $download_url" | pbcopy
    echo "The above command has been copied to clipboard."
}

function tgz-create() {
    local dir="$1"
    local delete_source=""
    if [ "$1" = "-d" ]; then
        dir="$2"
        delete_source="true"
    fi
    local out="${dir%/}.tgz"
    tar czf "$out" "$dir"
    ls -lh "$out"
    if [ -n "$delete_source" ]; then
        echo "Delete source dir $dir"
        rm -rf "$dir"
    fi
}

###########
# Widgets #
###########

run-and-copy-stdout-widget() {
    local buf="${BUFFER}"
    zle push-line # Clear buffer. Auto-restored on next prompt.
    BUFFER="${buf} | pbcopy"
    zle accept-line
    unset buf # ensure this doesn't end up appearing in prompt expansion
    zle reset-prompt
    return 0
}

zle -N run-and-copy-stdout-widget
bindkey '^Y' run-and-copy-stdout-widget

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
alias kill9="kill -9"

# Load local at last
if [ -e "$HOME/.zshrc_local" ]; then
    source $HOME/.zshrc_local
fi


################
# Integrations #
################

# iterm2
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# pnpm
export PNPM_HOME="/Users/reorx/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# atuin
. "$HOME/.atuin/bin/env"
# use fzf as the frontend of atuin
# copy from: https://news.ycombinator.com/item?id=35256206
atuin-setup() {
    #if ! which atuin &> /dev/null; then return 1; fi
    bindkey '^H' _atuin_search_widget

    export ATUIN_NOBIND="true"
    eval "$(atuin init zsh)"
    fzf-atuin-history-widget() {
        local selected num
        setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2>/dev/null

        # local atuin_opts="--cmd-only --limit ${ATUIN_LIMIT:-5000}"
        local atuin_opts="--cmd-only"
        local fzf_opts=(
            --tac
            "-n2..,.."
            --tiebreak=index
            "--query=${LBUFFER}"
            "+m"
            "--bind=ctrl-d:reload(atuin search $atuin_opts -c $PWD),ctrl-r:reload(atuin search $atuin_opts)"
        )

        selected=$(
            eval "atuin search ${atuin_opts}" |
                fzf "${FZF_DEFAULT_OPTS[@]}" "${fzf_opts[@]}"
        )
        local ret=$?
        if [ -n "$selected" ]; then
            # the += lets it insert at current pos instead of replacing
            LBUFFER="${selected}"
        fi
        zle reset-prompt
        return $ret
    }
    zle -N fzf-atuin-history-widget
    bindkey '^R' fzf-atuin-history-widget
}
atuin-setup

# profiling end
#zprof
