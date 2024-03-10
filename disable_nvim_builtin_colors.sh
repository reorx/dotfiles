#!/bin/bash

# Directory path
base_path="/opt/homebrew/Cellar/neovim"

# Loop over directories in the path
for dir in $(ls $base_path); do
  # Check if the directory exists
  if [ -d "$base_path/$dir/share/nvim/runtime/colors" ]; then
    # Change to the directory
    dir_path="$base_path/$dir/share/nvim/runtime/colors"
    cd "$dir_path"
    # Rename all .vim files to .vim.disabled
    for file in *.vim; do
      if [ "$file" != "default.vim" ]; then
        mv "$file" "${file%.vim}.vim.disabled"
      fi
    done
    echo "Done $dir_path:"
    ls *.vim
  fi
done
