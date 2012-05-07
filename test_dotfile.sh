#!/bin/bash

rm -rf dotfiles

git clone git@github.com:Reorx/dotfiles.git

cd dotfiles

./implement.sh init -f
