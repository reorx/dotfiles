##############################################################################
# oh-my-zsh
##############################################################################

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
if [ "$TERM_PROGRAM" = "HyperTerm" ]; then
    ZSH_THEME="pure"
else
    ZSH_THEME="new_steeef"
fi
#ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$HOME/.oh-my-zsh-custom

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=( autoenv2 )

source $ZSH/oh-my-zsh.sh


##############################################################################
# my zsh
##############################################################################

# Load other parts of zshrc
source $HOME/.zshrc_os

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

# virtualenv
export VIRTUAL_ENV_DISABLE_PROMPT="true"

# virtualenvwrapper
VIRTUALENVWRAPPER_SCRIPT=/usr/local/bin/virtualenvwrapper.sh
if [ -e "$VIRTUALENVWRAPPER_SCRIPT" ]; then
    export WORKON_HOME=$HOME/.venv
    export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python2
    export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv
    source $VIRTUALENVWRAPPER_SCRIPT
fi

# pew (virtualenvwrapper alternative)
#type pew >/dev/null 2>&1 && source $(pew shell_config)

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='ag -l -g ""'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--exact --no-mouse"
_fzf_compgen_path() {
  ag -g "" "$1"
}

# tag
if (( $+commands[tag] )); then
  tag() { command tag "$@"; source ${TAG_ALIAS_FILE:-/tmp/tag_aliases} 2>/dev/null }
  alias ag=tag
fi

#########################
# Environment Variables #
#########################

# Prefer US English and use UTF-8
export LC_ALL="en_US.UTF-8"
export LANG=en_US.UTF-8

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

# exa
if [[ -x /usr/local/bin/exa ]]; then
  alias ls='exa'
  alias l='exa -lg --time-style=long-iso --git'
  alias ll='exa -lga --time-style=long-iso --git'
# else
#   alias ls='ls --color=auto -N'
#   alias l='ls -lF --time-style=long-iso'
#   alias ll='ls -alF --time-style=long-iso'
fi


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

sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
    zle end-of-line
}
zle -N sudo-command-line
bindkey "\e\e" sudo-command-line

#
#suite_virtualenv() {
#    if [ -e .virtualenv ]; then
#        name=$(cat .virtualenv)
#        if [ $VIRTUAL_ENV ]; then
#            if [ "$name" = "$(basename $VIRTUAL_ENV)" ]; then
#                return
#            fi
#        fi
#        workon $name
#    fi
#}
#cd () {
#    builtin cd "$@" && suite_virtualenv
#}
#suite_virtualenv

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

# Syntax-highlight JSON strings or files
function json() {
    if [ -p /dev/stdin ]; then
        # piping, e.g. `echo '{"foo":42}' | json`
        python -mjson.tool | pygmentize -l javascript
    else
        # e.g. `json '{"foo":42}'`
        python -mjson.tool <<< "$*" | pygmentize -l javascript
    fi
}

# Get a character's Unicode code point
function codepoint() {
    perl -e "use utf8; print sprintf('U+%04X', ord(\"$@\"))"
    echo # newline
}

function clean_pyc() {
    find $1 -name '*.pyc' -exec rm {} \;
}

function sshch() {
    # Options explaination
    #   q  Quiet mode.  Causes most warning and diagnostic messages to be suppressed.
    #   T  Disable pseudo-tty allocation.
    #   N  Do not execute a remote command.  This is useful for just forwarding ports (protocol version 2 only).
    #   D  bind address to port
    ssh -qTNv -D 7070 $@
}

function github-clone() {
    git clone git@github.com:$1.git $2
}

function colortable() {
    echo "use \\\x1B or \\\e as prefix, \\\x1B[0m as suffix"
    for x in 0 1 4 5 7 8; do
        for i in `seq 30 37`; do
            for a in `seq 40 47`; do
                echo -ne "\e[$x;$i;$a""m\\\x1B[$x;$i;$a""m\e[0;37;40m ";
            done;
            echo;
        done;
    done;
    echo;
}

function colorcodes() {
    T='gYw'   # The test text

    echo -e "\n                 40m     41m     42m     43m\
         44m     45m     46m     47m";

    for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
               '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
               '  36m' '1;36m' '  37m' '1;37m';
      do FG=${FGs// /}
      echo -en " $FGs \033[$FG  $T  "
      for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
        do echo -en "$EINS \033[$FG\033[$BG  $T  \033[0m";
      done
      echo;
    done
    echo
}

function colortable256() {
    for i in {0..255} ; do
        printf "\x1b[38;5;${i}mcolour${i}\n"
    done
}

function curlhttpstat() {
    curl -Ss -w'Timeline:
|
|--NAMELOOKUP %{time_namelookup}
|--|--CONNECT %{time_connect}
|--|--|--APPCONNECT %{time_appconnect}
|--|--|--|--PRETRANSFER %{time_pretransfer}
|--|--|--|--|--STARTTRANSFER %{time_starttransfer}
|--|--|--|--|--|--TOTAL %{time_total}
|--|--|--|--|--|--REDIRECT %{time_redirect}

Speed: %{speed_download} Bytes/s
' -o /dev/null $1
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


###########
# Aliases #
###########

alias lsd='ls -ld */'
alias vim="nvim -p"
alias ovim="/usr/local/bin/vim -p"
alias tree="tree --dirsfirst"
alias cleanpyc="find . -name '*.pyc' -exec rm {} \;"
alias cleanpycache="find . -type d -name '__pycache__' -prune -exec rm -r {} \;"

# Load local at last
if [ -e "$HOME/.zshrc_local" ]; then
    source $HOME/.zshrc_local
fi
