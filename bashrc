PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\]:\w\$\[\033[00m\] '

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export MANPATH=/Users/reorx/AppData/LinuxMan:$MANPATH

BASHSENSIBLE=/Users/reorx/Code/repos/bash-sensible/sensible.bash
if [ -f $BASHSENSIBLE ]; then
    source $BASHSENSIBLE
fi
