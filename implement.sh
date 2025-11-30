#!/bin/bash
#
# Author: reorx
#
# Usage
#   commands:
#     initialize
#       do everything on a just installed computer, use with -f to
#       reset all and cover existings.
#     set ,arg
#     configure ,arg


# Global variables
# Change this varible to choose the targets you want
PROFILE_macos=( zsh git fzf vim nvim tmux misc bin )
PROFILE_linux_server=( bash git vim tmux_server misc bin )
LINESHIFT="  "
INITED_FILE=".inited"

NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'

function paint() {
    echo -e "${!1}${2}${NOCOLOR}"
}

# Determine system
v_uname="$(uname)"
if [ "$v_uname" == "Darwin" ]; then
    OS="mac"
else
    OS="${v_uname,,}"
fi
# for M1 chip mac, ARCH is arm64
ARCH="$(uname -m)"


# Logics

function set_dotfiles() {
    local items=($1)
    for i in "${items[@]}"; do
        paint GREEN "Setting $i's dotfiles"
        eval "impl_$i"
    done
}

function impl_zsh() {
    ln2home ohmyzsh
    ln2home pure .zsh-pure
    ln2home z
    ln2home "zprofile.$ARCH" .zprofile
    # ln2home zshenv
    ln2home zshrc
    ln2home zshrc_nvm
    ln2home zshrc_fn
    ln2home zshrc_fn_fzf
    ln2home zshrc_$OS .zshrc_os
}

function impl_bash() {
    ln2home bashrc
    local install_path=~/.bash-sensible
    if [ -e "$install_path" ]; then
        paint BLUE "$install_path exists, skip"
    else
        echo "Download git repo to $install_path"
        git clone https://github.com/mrzool/bash-sensible.git "$install_path"
    fi
}

function impl_fzf() {
    local install_path=~/.fzf
    if [ -e "$install_path" ]; then
        paint BLUE "$install_path exists, skip"
    else
        echo "Download git repo to $install_path"
        git clone --depth 1 https://github.com/junegunn/fzf.git "$install_path"
        $install_path/install
    fi
}

function impl_vim() {
    ln2home vim
    ln2home vimrc
}

function impl_nvim() {
    ln2config nvim
}

function impl_fd() {
    create_link "$PWD/fd" ~/.config/fd
}

function impl_git() {
    ln2home gitconfig
    ln2home gitignore_global
}

function impl_wezterm {
    mkdir -p ~/.config/wezterm
    create_link "$PWD/wezterm.lua" ~/.config/wezterm/wezterm.lua
}

function impl_tmux {
    ln2home tmux.conf
    impl_tpm
}

function impl_tmux_server {
    ln2home tmux.server.conf .tmux.conf
}

function impl_tpm {
    local install_path=~/.tmux/plugins/tpm
    if [ -e "$install_path" ]; then
        paint BLUE "$install_path exists, skip"
    else
        echo "Download git repo to $install_path"
        mkdir -p "$(dirname $install_path)"
        git clone https://github.com/tmux-plugins/tpm "$install_path"
    fi
}

function impl_bin {
    local source_dir="$PWD/bin"
    local target_dir=~/.local/bin
    mkdir -p "$target_dir"
    for cmd in $(ls "$source_dir"); do
        create_link "$source_dir/$cmd" "$target_dir/$cmd"
    done
}

function impl_misc {
    ln2home ignore
}

# Utils

function ln2home() {
    local source="$PWD/$1"
    if [ "$2" ]; then
        local target="$HOME/$2"
    else
        local target="$HOME/.$1"
    fi
    create_link $source $target
}

function ln2config() {
    local source="$PWD/$1"
    if [ "$2" ]; then
        local target="$HOME/.config/$2"
    else
        local target="$HOME/.config/$1"
    fi
    create_link $source $target
}

function create_link() {
    local source="$1"
    local target="$2"
    if [ -e "$target" ]; then
        if [ -L "$target" ]; then
            paint BLUE "$target link exists, skip"
            return 0
        fi

        paint ORANGE "$target exists, force override it"
        local BACKUP=$(dirname "$target")/$(basename "$target").dotfilebak
        echo "Backup to $BACKUP"
        # To prevent creating recursive link
        if [ -e "$BACKUP" ]; then
            rm -rf $BACKUP
        fi
        mv $target $BACKUP
    elif [ -h "$target" ]; then
        paint ORANGE "$target is a broken link, rm it"
        rm -f $target
    fi

    echo "Create link $target -> $source"
    ln -s $source $target
}

function installed() {
    type "$1" >/dev/null 2>&1
}

function require_installed() {
    if (installed "$1"); then
        true
    else
        paint RED "$1 must be installed !"
        exit 1
    fi
}

function show_help() {
    cat <<EOF
Usage: implement.sh [-p profile | -s dotfile | -h]
       require option arguments
       non-option arguments is not needed
Options:
-p : Set specified profile, available: macos, linux_server
-s : Set specified dotfile.
-h : Show help information.
EOF
}

function check_git_submodules() {
    if [ ! -e $INITED_FILE ]; then
        paint GREEN "Init submodules first"
        git submodule update --init
        touch $INITED_FILE
    fi
}


# Main

require_installed git

# cd to where implment.sh located in
cd "$(dirname "$0")"

while getopts ":hp:s:" opt; do
    case $opt in
        h)
            show_help
            exit
            ;;
        p)
            varname="PROFILE_$OPTARG[@]"
            dotfiles="${!varname}"
            if [ -z "$dotfiles" ]; then
                echo "Invalid profile $OPTARG"
                exit 1
            fi
            paint GREEN "Set profile: $OPTARG"

            if [ "$OPTARG" == "macos" ]; then
                check_git_submodules
            fi

            set_dotfiles "${dotfiles[@]}"

            paint GREEN "\nAll done!"
            exit
            ;;
        s)
            paint GREEN "Set dotfile: $OPTARG"

            eval "impl_$OPTARG"

            exit
            ;;
        \?)
            paint RED "Invalid option: -$OPTARG"
            exit 1
            ;;
        :)
            paint RED "Option -$OPTARG requires an argument."
            exit 1
            ;;
    esac
done

echo "Please input an option"
show_help
