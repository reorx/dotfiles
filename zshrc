# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="steeef"
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
plugins=(git pip)

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
export PYTHONENVS=$HOME/Envs/Python
# export PATH=$PYTHONENVS/bin:$PATH
# Prefer US English and use UTF-8
export LC_ALL="en_US.UTF-8"
export LANG="en_US"
# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh

unsetopt correct_all

# for virtualenvwrapper
export VIRTUALENVWRAPPER_PYTHON=$PYTHONENVS/bin/python
export VIRTUALENVWRAPPER_VIRTUALENV=$PYTHONENVS/bin/virtualenv
export WORKON_HOME=$PYTHONENVS
export PROJECT_HOME=$HOME/workspace/current
source $PYTHONENVS/bin/virtualenvwrapper.sh

alias fb="nautilus"
alias enca_utf8="enca -L zh_CN -x utf-8"
alias pdb="python -m pdb"
alias vim="vim -p"
alias tree="tree --dirsfirst --filelimit 20"
# List only directories
alias lsd='ls -l | grep "^d"'
alias lla='ls -la'
# File size
alias fs="stat -f \"%z bytes\""

# Solarized color terminal theme setup
# eval `dircolors ~/.dircolors`

ssh_hosts=(
reorx@reorx.me,
sa@yue.fm
)
zstyle ':completion:*:ssh-hosts' users-hosts $ssh_hosts

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
hash -d picture="/home/reorx/Pictures"
hash -d download="/home/reorx/Downloads"
hash -d document="/home/reorx/Documents"
hash -d dropbox="/home/reorx/Dropbox"
hash -d workspace="/home/reorx/workspace"

hash -d current="/home/reorx/workspace/current"
hash -d lab="/home/reorx/workspace/lab"

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
