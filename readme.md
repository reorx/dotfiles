# Dotfiles

reorx's configuration for the whole command line.

## Auto Setup

Setup all dotfiles:

```bash
$ ./implement.sh -i
```

Setup a specific software::

```bash
$ ./implement.sh -s nvim
```

## Manually Setup

prerequisite:
- git clone
- git submodule update --init

### zsh

requires:
- fzf (brew)
  - Run `$(brew --prefix)/opt/fzf/install` after install
- fd (brew)
- zoxide (brew)
- [pyenv](https://github.com/pyenv/pyenv#installation)
- nvm

Link files and folders:
- oh-my-zsh/ -> ~/.oh-my-zsh
- oh-my-zsh-custom/ -> ~/.oh-my-zsh-custom
- pure/ -> ~/.zsh-pure
- zshenv -> ~/.zshenv
- zshrc -> ~/.zshrc
- zshrc\_os -> ~/.zshrc\_mac

Note about zsh startup files:
 
> There are five startup files that zsh will read commands from:
> 
> - `$ZDOTDIR/.zshenv`
> 
>   `.zshenv` is sourced on all invocations of the shell, unless the -f option is set. It should contain commands to set the command search path, plus other important environment variables. `.zshenv' should not contain commands that produce output or assume the shell is attached to a tty.
> - `$ZDOTDIR/.zprofile`
> - `$ZDOTDIR/.zshrc`
> 
>   `.zshrc` is sourced in interactive shells. It should contain commands to set up aliases, functions, options, key bindings, etc.
> - `$ZDOTDIR/.zlogin`
> 
>   `.zlogin` is sourced in login shells. It should contain commands that should be executed only in login shells. `.zlogout' is sourced when login shells exit. `.zprofile' is similar to `.zlogin', except that it is sourced before `.zshrc'. `.zprofile' is meant as an alternative to `.zlogin' for ksh fans; the two are not intended to be used together, although this could certainly be done if desired. `.zlogin' is not the place for alias definitions, options, environment variable settings, etc.; as a general rule, it should not change the shell environment at all. Rather, it should be used to set the terminal type and run a series of external commands (fortune, msgs, etc).
> - `$ZDOTDIR/.zlogout`
> 
>   If ZDOTDIR is not set, then the value of HOME is used; this is the usual case.


### fzf

Link files:
- zshrc\_fzf -> ~/.zshrc\_fzf
- bin/batctx -> ~/.local/bin
- bin/frg -> ~/.local/bin
- bin/frgi -> ~/.local/bin

Show fzf related commands:
```
$ fcmds
fzf commands:
  fpreview        preview searched files
  fkill           kill searched processes
  fed             open searched files with EDITOR
  frg             filter rg result, open with EDITOR
  frgi            interactive rg search, open with EDITOR
```

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

> Note: Because nvim has been a successful replacement for vim,
> this vimrc stopped to provide plugins, keeps a minimal basic configuration
