PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\]:\w\$\[\033[00m\] '

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Below are local configs that could be removed #

export MANPATH=/Users/reorx/AppData/LinuxMan:$MANPATH

BASHSENSIBLE=/Users/reorx/Code/repos/bash-sensible/sensible.bash
if [ -f $BASHSENSIBLE ]; then
    source $BASHSENSIBLE
fi

command -v vg >/dev/null 2>&1 && eval "$(vg eval --shell bash)"
