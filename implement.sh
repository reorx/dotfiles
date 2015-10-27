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
ALL_DOTFILES=( zsh vim git python moc wget tmux )
IMPL_DOTFILES=( zsh vim git python wget tmux )
LINESHIFT="  "
INITED_FILE=".inited"

# Determine system
# Supported systems: mac, ubuntu
if [ "$(uname)" == "Darwin" ]; then
    OS="mac"
else
    # release_info=$(cat /etc/*-release)
    # if $release_info match 'ubuntu'
    OS="ubuntu"

    # OS="unknown"
fi

# TODO colorful print


# Functions
function ln2home() {
    SOURCE="$PWD/$1"
    if [ "$2" ]; then
        TARGET="$HOME/$2"
    else
        TARGET="$HOME/.$1"
    fi
    if [ -e "$TARGET" ]; then
        if [ $FORCE_SET ]; then
            echo "$TARGET exists, force override it"
            BACKUP="$HOME/.$1.dotfilebak"
            echo "Backup to $BACKUP"
            # To ensure BACKUP is no exist, or may cause link chain recurive
            if [ -e "$BACKUP" ]; then
                rm -rf $BACKUP
            fi
            mv $TARGET $BACKUP
        else
            echo "Unlinked file $TARGET exists, no force, skip"
            return 0
        fi
    elif [ -h "$TARGET" ]; then
        echo "$TARGET is a broken link, rm it"
        rm -f $TARGET
    fi

    echo "Create link $TARGET -> $SOURCE"
    ln -s $SOURCE $TARGET
}


function installed() {
    if type -P $1 &>/dev/null; then
        echo 1
    else
        return "0"
    fi
}


function install() {
    if [ "$OS" == "mac" ]; then
        if ! type "brew" > /dev/null; then
            echo "You must have brew installed on your mac to \
                  be able to install $1 by command"
            exit
        fi
    elif [ "$OS" == "ubuntu" ]; then
        # release_info=$(cat /etc/*-release)
        # if $release_info match 'ubuntu'
        if ! type "apt-get" > /dev/null; then
            echo "No apt-get? WTF!"
            exit
        fi
        sudo apt-get install $1
    else
        echo "Sorry, does not support linux dist other than ubuntu yet"
    fi
}


function install_if_not_exist() {
    if [ ! $(installed $1) ]; then
        install $1
    fi
}


function impl_zsh() {
    install_if_not_exist zsh
    ln2home shell-colors
    ln2home oh-my-zsh
    ln2home oh-my-zsh-custom
    ln2home zshrc
    ln2home zshrc_fzf
    ln2home zshrc_$OS .zshrc_os
    ln2home z
}


function impl_vim() {
    install_if_not_exist vim
    install_if_not_exist ctags
    ln2home vim
    ln2home vimrc
}


function impl_git() {
    ln2home gitconfig
    ln2home gitignore_global
}


function impl_python() {
    ln2home pythonrc.py
}


function impl_moc() {
    install_if_not_exist moc
    ln2home moc
}


function impl_wget() {
    install_if_not_exist wget
    ln2home wgetrc
}

function impl_tmux {
    ln2home tmux.conf
}


function conf_zsh() {
    local user="$(whoami)"
    read -p "Do you want to set to this user $user(yourself) [yY]?" -n 1
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo
    elif [ $REPLY ]; then
        echo
        read -p "input username: " user
    fi
    sudo usermod -s /bin/zsh $user
}


function conf_vim() {
    #(
    #vim +BundleInstall +qall
    #)
    vim -c "execute \"BundleInstall\" | q | q"
}


function update_git() {
    git pull
    git submodule init
    git submodule update
}


function show_help() {
    cat <<EOF
Usage: implement.sh [-i | -s name | -c name | -h]
       require option arguments
       non-option arguments is not needed
Options:
-i : Initialize everything, for virgin system.
-u : Update all dotfiles implementations.
-s : Set dotfiles specially.
-c : Configure with <name>.
-h : Show help information.
EOF
}


function check_repos() {
    if [ ! -e $INITED_FILE ]; then
        echo "init repos first"
        update_git
        touch $INITED_FILE
        # If this is done before command `update_git`,
        # there will be no need to redo update,
        # set a flag for later use.
        FIRST_TIME="true"
    fi
}


function set_dotfiles() {
    for i in ${IMPL_DOTFILES[@]}; do
        echo "Setting $i's dotfiles"
        eval "impl_$i"
    done
}


# Preparations
if [ ! $(installed git) ]; then
    echo 'git must be installed !'
    exit
fi

cd "$(dirname "$0")"

# Main

while getopts ":hTiuxs:c:" opt; do
    case $opt in
        h)
            show_help
            exit
            ;;
        T)
            echo "self test" >&2
            exit
            ;;
        i)
            check_repos

            echo "Initialize"

            echo "Step 1. Set dotfiles"
            set_dotfiles

            read -p "Do you want to configure zsh to your default shell [yY]?" -n 1
            if [[ $REPLY =~ ^[Yy]$ || ! $REPLY ]]; then
                conf_zsh
            fi

            read -p "Do you want to configure vim and its bundles [yY]?" -n 1
            if [[ $REPLY =~ ^[Yy]$ || ! $REPLY ]]; then
                conf_vim
            fi

            echo "\nAll done!"
            exit
            ;;
        u)
            FORCE_SET="true"

            echo "Update dotfiles"
            set_dotfiles

            exit
            ;;
        s)
            echo "Set $OPTARG"

            FORCE_SET="true"

            eval "impl_$OPTARG"

            exit
            ;;
        c)
            echo "Configure $OPTARG"

            eval "conf_$OPTARG"

            exit
            ;;
        x)
            echo "Delete all backup files"
            rm -f $HOME/.*.dotfilebak

            exit
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            exit 1
            ;;
    esac
done

echo "Please input an option"
show_help
