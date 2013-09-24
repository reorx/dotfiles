# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

ZSH_CUSTOM=$HOME/.oh-my-zsh-custom

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="new_steeef"
#ZSH_THEME="bira"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(pip fabric supervisor)

source $ZSH/oh-my-zsh.sh

# for virtualenv, use my own prompt
VIRTUAL_ENV_DISABLE_PROMPT="true"

# oh-my-zsh theme fix
PROMPT=$'
%{$purple%}%n%{$reset_color%} at %{$orange%}%m%{$reset_color%} in %{$limegreen%}%~%{$reset_color%} $vcs_info_msg_0_
$ '

function GET_RPROMPT() {
    if [ "$VIRTUAL_ENV" ]; then
        echo "%{${fg_bold[white]}%}(env: %{${fg[blue]}%}`basename \"$VIRTUAL_ENV\"`%{${fg_bold[white]}%})%{${reset_color}%}"
    fi
}
#RPROMPT="${GET_RPROMPT} $RPROMPT"
RPROMPT='$(GET_RPROMPT)'

export NODE_PATH=/usr/lib/node_modules
export PYTHONENV=$HOME/Envs/Python
export PYTHONSTARTUP=$HOME/.pythonrc.py
export PATH=$PYTHONENV/bin:$PATH

function switch_python() {
    if [[ ${PATH#$PYTHONENV/bin} == $PATH ]]; then
        echo 'Switch to make-installed Python'
        export PATH=$PYTHONENV/bin:$PATH
    else
        echo 'Switch to system Python'
        export PATH=${PATH#$PYTHONENV/bin}
    fi

}

# Prefer US English and use UTF-8
export LC_ALL="en_US.UTF-8"
export LANG="en_US"

unsetopt correct_all

# for virtualenvwrapper
export VIRTUALENVWRAPPER_PYTHON=$PYTHONENV/bin/python
export VIRTUALENVWRAPPER_VIRTUALENV=$PYTHONENV/bin/virtualenv
export WORKON_HOME=$PYTHONENV/virtualenvs
export PROJECT_HOME=$HOME/workspace/current
source $PYTHONENV/bin/virtualenvwrapper.sh

alias fb="nautilus"
alias enca_utf8="enca -L zh_CN -x utf-8"
alias pdb="python -m pdb"
alias vim="vim -p"
alias tree="tree --dirsfirst"
# List only directories
alias lsd='ls -l | grep "^d"'
alias lla='ls -la'
# File size
alias fs="stat -f \"%z bytes\""

alias sublime="/home/reorx/Softwares/SublimeText2/sublime_text"
alias t='python ~/workspace/lab/t/t.py --task-dir /home/reorx/Documents/Tasks --list tasks.txt --delete-if-empty'
alias ack="ack-grep"


# History search
bindkey "^[[A" history-search-backward

bindkey "^[[B" history-search-forward

# Solarized color terminal theme setup
# eval `dircolors ~/.dircolors`

ssh_hosts=(
    reorx.com
    yue.fm
)
#zstyle ':completion:*:ssh-hosts' users-hosts $ssh_hosts
#hosts=$(awk '/^Host / {printf("%s ",$2)}' ~/.ssh/config 2>/dev/null)
zstyle ':completion:*:hosts' hosts $ssh_hosts


sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
    zle end-of-line                 #光标移动到行末
}
zle -N sudo-command-line
bindkey "\e\e" sudo-command-line

suite_virtualenv() {
    if [ -e .virtualenv ]; then
        name=$(cat .virtualenv)
        if [ $VIRTUAL_ENV ]; then
            if [ "$name" = "$(basename $VIRTUAL_ENV)" ]; then
                return
            fi
        fi
        workon $name
    fi
}
cd () {
    builtin cd "$@" && suite_virtualenv
}
suite_virtualenv

hash -d desktop="/home/reorx/Desktop"
hash -d music="/home/reorx/Music"
hash -d pictures="/home/reorx/Pictures"
hash -d downloads="/home/reorx/Downloads"
hash -d documents="/home/reorx/Documents"
hash -d softwares="/home/reorx/Softwares"
hash -d dropbox="/home/reorx/Dropbox"
hash -d workspace="/home/reorx/workspace"

hash -d current="/home/reorx/workspace/current"
hash -d lab="/home/reorx/workspace/lab"
hash -d sohu="/home/reorx/workspace/sohu"

# Create a data URL from an image (works for other file types too, if you tweak the Content-Type afterwards)
dataurl() {
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

function use_proxy() {
    export http_proxy="$(cat ~/.shell_proxy)"
}

function dp() {
    dolphin $@ &
}

function github-clone() {
    git clone git@github.com:$1.git $2
}
