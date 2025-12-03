# If not running interactively, don't do anything (from Arch Linux)
[[ $- != *i* ]] && return

PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\]:\w\$\[\033[00m\] '
export EDITOR=vim

# Disable scroll lock, release key binds of C-S/C-Q
stty -ixon

BASHSENSIBLE=$HOME/.bash-sensible/sensible.bash
[ -f $BASHSENSIBLE ] && source $BASHSENSIBLE


osname="$(uname -s)"
# Linux special
if [[ "$osname" == Linux ]]; then
    # enable color support of ls and also add handy aliases
    if [ -x /usr/bin/dircolors ]; then
        test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
        alias ls='ls --color=auto'
    fi
# MacOS special
elif [[ "$osname" == Darwin ]]; then
    export MANPATH=$HOME/AppData/LinuxMan:$MANPATH
fi

# aliases
alias l="ls -la"

# atuin
. "$HOME/.atuin/bin/env"
[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
eval "$(atuin init bash)"

# Load local at last
if [ -e "$HOME/.bashrc_local" ]; then
    source $HOME/.bashrc_local
fi
