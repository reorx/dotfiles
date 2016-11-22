#!/bin/bash

conffile="$1"
if [ -z "$conffile" ]; then
    echo "Usage: add-resurrect.sh CONFFILE"
    exit 1
fi
resurrectdir=".tmux-resurrect"

if [ ! -e "$resurrectdir" ]; then
    git clone https://github.com/tmux-plugins/tmux-resurrect "$resurrectdir"
fi

echo "
# tmux resurrect
run-shell ~/.tmux-resurrect/resurrect.tmux
" >> "$conffile"
