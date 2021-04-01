PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\]:\w\$\[\033[00m\] '

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Below are local configs that could be removed #

export MANPATH=$HOME/AppData/LinuxMan:$MANPATH

BASHSENSIBLE=$HOME/.bash-sensible/sensible.bash
[ -f $BASHSENSIBLE ] && source $BASHSENSIBLE
