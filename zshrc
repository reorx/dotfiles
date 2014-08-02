# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

ZSH_CUSTOM=$HOME/.oh-my-zsh-custom

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="new_steeef"

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
plugins=(pip fabric supervisor autoenv2)

export _Z_DATA=$HOME/.z-data

# source .sh s
source $ZSH/oh-my-zsh.sh
source $HOME/.zshrc_osspec
if [ -e $HOME/.zshrc_local ]; then
    # source .zshrc_local
    source $HOME/.zshrc_local
fi
source $HOME/.z/z.sh

# for virtualenv, use my own prompt
VIRTUAL_ENV_DISABLE_PROMPT="true"

#export NODE_PATH=/usr/lib/node_modules
eval "$(rbenv init -)"

# Prefer US English and use UTF-8
export LC_ALL="en_US.UTF-8"
export LANG="en_US"

export LESS='-R'
export LESSOPEN='|~/.lessfilter %s'

# Disable autocorrect
unsetopt correct_all

# Auto rehash
#zstyle ":completion:*:commands" rehash 1

# History search
bindkey "^[[A" history-search-backward

bindkey "^[[B" history-search-forward

zstyle ':completion:*:ssh-hosts' users-hosts $ssh_hosts
hosts=$(awk '/^Host / {printf("%s ",$2)}' ~/.ssh/config 2>/dev/null)
zstyle ':completion:*:hosts' hosts $ssh_hosts


sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
    zle end-of-line
}
zle -N sudo-command-line
bindkey "\e\e" sudo-command-line

#suite_virtualenv() {
    #if [ -e .virtualenv ]; then
        #name=$(cat .virtualenv)
        #if [ $VIRTUAL_ENV ]; then
            #if [ "$name" = "$(basename $VIRTUAL_ENV)" ]; then
                #return
            #fi
        #fi
        #workon $name
    #fi
#}
#cd () {
    #builtin cd "$@" && suite_virtualenv
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

if [ -e $HOME/.rvm/bin ]; then
    # Add RVM to PATH for scripting
    PATH=$PATH:$HOME/.rvm/bin
fi

# Aliases

alias lsd='ls -l | grep "^d"'
alias vim="vim -p"
alias tree="tree --dirsfirst"
