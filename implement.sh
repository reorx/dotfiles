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
DOTFILES=( zsh vim git python moc wget )
LINESHIFT="  "
INITED_FILE=".inited"


# Functions
function ln2home() {
    SOURCE="$PWD/$1"
    TARGET="$HOME/.$1"
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
        rm $TARGET
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
    sudo apt-get install $1
}


function active_install() {
    if [ ! $(installed $1) ]; then
        install $1
    fi
}


function impl_zsh() {
    active_install zsh
    ln2home oh-my-zsh
    ln2home oh-my-zsh-custom
    ln2home zshrc
}


function impl_vim() {
    active_install vim
    active_install ctags
    ln2home vim
    ln2home vimrc
    #(
    #vim +BundleInstall +qall
    #)
    vim -c "execute \"BundleInstall\" | q | q"
}


function impl_git() {
    ln2home gitconfig
    ln2home gitignore_global
}


function impl_python() {
    ln2home pythonrc.py
}


function impl_moc() {
    active_install moc
    ln2home moc
}


function impl_wget() {
    active_install wget
    ln2home wgetrc
}


function update_git() {
    git pull
    git submodule init
    git submodule update
}


function conf_zsh() {
    local user="$(whoami)"
    read -p "Do you want to set to this user $user(yourself) [yY]?" -n 1
    if [[ $REPLY =~ ^[Yy]$ || ! $REPLY ]]; then
        echo
        read -p "input username: " $user
    fi
    sudo usermod -s /bin/zsh $user
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
    for i in ${DOTFILES[@]}; do
        echo "Setting $i's dotfiles"
        eval "impl_$i"
    done
    rehash
}


# Preparations
if [ ! $(installed git) ]; then
    echo 'git must be installed !'
    exit
fi

cd "$(dirname "$0")"

# Main

while getopts ":hTius:c:" opt; do
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

            echo 'Step 2. Configure zsh'
            conf_zsh

            echo "\nAll done!"
            exit
            ;;
        u)
            check_repos

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
