# Dotfiles

## Setup

prerequisite:
- git clone
- git submodule update --init

### zsh

requires:
- fzf (brew)
  - Run `$(brew --prefix)/opt/fzf/install` after install
- fd (brew)
- pyenv (github)

Link files and folders:
- oh-my-zsh/ -> ~/.oh-my-zsh
- oh-my-zsh-custom/ -> ~/.oh-my-zsh-custom
- pure/ -> ~/.zsh-pure
- z/ -> ~/.z
- zshrc -> ~/.zshrc
- zshrc_os -> ~/.zshrc_mac
- zshrc_fzf -> ~/.zshrc_fzf

### bash

requires:
- base-sensible: `git clone git@github.com:mrzool/bash-sensible.git .bash-sensible`

Link files:
- bashrc -> ~/.bashrc

### tmux

requires:
- tpm: `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`

Link files:
- tmux.conf -> ~/.tmux.conf

Post install:
- start tmux and press `prefix + I` to fetch plugins

### a local build python 3

```
PYTHON_CONFIGURE_OPTS="--enable-framework" pyenv install 3.9.2
```

> It seems this process is very smooth in the newest macOS (Big Sur), for old issues and other platforms, check [[pyenv install python]] in Obsidian-Base.

### nvim

requires:
- python (a local build python 3)
  - virtualenv for nvim python provider

    ```
    mkdir ~/.virtualenvs
    cd ~/.virtualenvs
    python -m venv neovim-python3
    pve-activate
    pip install pynvim
    ```

Link:
- nvim/ -> ./.nvim
- nvimrc -> ./.nvimrc
- `cd ~/.config/nvim && ln -s ~/.nvim/init.vim .`

Run:
```
:PlugInstall
:UpdateRemotePlugins
```

Install LSP for certain language

```
nvim a.py
:LspInstallServer
```

### vim

Link:
- vimrc -> ~/.vimrc

> Note: Because nvim has been a successful replace for vim,
> this vimrc stopped to provide plugins to keep a minimal basic configuration
