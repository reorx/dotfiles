# vim: set ft=zsh:

#############
# Profiling #
#############

# profiling start
#zmodload zsh/zprof

# old way
#RC_DEBUG="true"
RC_DEBUG="false"

function _timestamp_ms() {
    if [[ "$(uname)" == "Darwin" ]]; then
        echo $(gdate +%s%3N)
    else
        echo $(date +%s%3N)
    fi
}
if [[ $RC_DEBUG == "true" ]]; then
    # source with timer
    function source() {
        local ts=$(_timestamp_ms)
        builtin source $1
        local te=$(_timestamp_ms)
        echo "$(($te - $ts))ms: source $1"
    }
    # eval with timer
    #function eval() {
    #    local ts=$(_timestamp_ms)
    #    builtin eval $1
    #    local te=$(_timestamp_ms)
    #    echo "$(($te - $ts))ms: eval $1"
    #}
fi

#############
# oh-my-zsh #
#############

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.ohmyzsh

# Settings ref: https://github.com/ohmyzsh/ohmyzsh/wiki/Settings

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
ZSH_THEME=""  # disable ZSH theme, for pure

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Use this setting to disable the Oh My Zsh logic to automatically set ls color
# output based on the system you're running and which ls commands are available.
DISABLE_LS_COLORS=true


# Plugins
# use ohmyzsh's nvm plugin to enable lazy loading of nvm, thus the zsh startup could be quick af
#zstyle ':omz:plugins:nvm' lazy yes
#plugins=( nvm )

source $ZSH/oh-my-zsh.sh


#######
# zsh #
#######

# use pure prompt
fpath+=$HOME/.zsh-pure
autoload -U promptinit; promptinit
prompt pure


# Disable autocorrect
unsetopt correct_all

# Auto rehash
#zstyle ":completion:*:commands" rehash 1

# History search
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

# SSH completion
zstyle ':completion:*:ssh-hosts' users-hosts $ssh_hosts
hosts=$(awk '/^Host / {printf("%s ",$2)}' ~/.ssh/config 2>/dev/null)
zstyle ':completion:*:hosts' hosts $ssh_hosts

# widget
run-and-copy-stdout-widget() {
    local buf="${BUFFER}"
    zle push-line # Clear buffer. Auto-restored on next prompt.
    BUFFER="${buf} | pbcopy"
    zle accept-line
    unset buf # ensure this doesn't end up appearing in prompt expansion
    zle reset-prompt
    return 0
}
zle -N run-and-copy-stdout-widget
bindkey '^Y' run-and-copy-stdout-widget


#########################
# Environment Variables #
#########################

export PATH="$HOME/.local/bin:$PATH"

# Prefer US English and use UTF-8
export LC_ALL="en_US.UTF-8"
export LANG=en_US.UTF-8

# Less
export LESSCHARSET=utf-8
export LESS='-R'
#export LESSOPEN='|~/.lessfilter %s'
export LESS_TERMCAP_mb=$(printf "\e[1;31m")
export LESS_TERMCAP_md=$(printf "\e[1;31m")
export LESS_TERMCAP_me=$(printf "\e[0m")
export LESS_TERMCAP_se=$(printf "\e[0m")
export LESS_TERMCAP_so=$(printf "\e[1;44;33m")
export LESS_TERMCAP_ue=$(printf "\e[0m")
export LESS_TERMCAP_us=$(printf "\e[1;32m")
# For more about termcap see:
# https://www.gnu.org/software/termutils/manual/termcap-1.3/html_chapter/termcap_4.html
# http://boredzo.org/blog/archives/2016-08-15/colorized-man-pages-understood-and-customized

export EDITOR=nvim

# mosh
export MOSH_PREDICTION_DISPLAY=always

# httpstat
export HTTPSTAT_SHOW_BODY=false
export HTTPSTAT_SHOW_IP=true
export HTTPSTAT_SHOW_SPEED=true
export HTTPSTAT_SAVE_BODY=true

# csvless
export CSVLESS_MAX_COLUMN_WIDTH=64
export CSVLESS_LINE_NUMBERS=1
export CSVLESS_TABLE_STYLE=markdown

# virtualenv
if [ "$TERM_PROGRAM" = "vscode" ]; then
    # disable virtualenv default PS1
    export VIRTUAL_ENV_DISABLE_PROMPT="true"
else
    # unset so that pure.zsh can work
    unset VIRTUAL_ENV_DISABLE_PROMPT
fi

# Python
if [ -e $HOME/.pythonrc.py ]; then
    export PYTHONSTARTUP=$HOME/.pythonrc.py
fi


###########
# Aliases #
###########

# eza
if ( type eza >/dev/null 2>&1 ); then
  alias ls='eza'
  alias l='eza -lg --time-style=long-iso --git'
  alias ll='eza -lga --time-style=long-iso --git'
fi
alias lsd='ls -ld */'
alias vim="nvim -p"
alias vim0="/usr/local/bin/vim -p"
# TODO vim1
alias tree="tree --dirsfirst"
alias tree-size="tree -h --du"
alias cleanpyc="find . -name '*.pyc' -exec rm {} \;"
alias cleanpycache="find . -type d -name '__pycache__' -prune -exec rm -r {} \;"
alias kill9="kill -9"


#################
# Program Inits #
#################

# Load z
eval "$(zoxide init zsh)"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# fd respects .gitignore
export FZF_DEFAULT_COMMAND='fd -H -t f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# other opts: "--ezact"
export FZF_DEFAULT_OPTS=( --height "50%" --no-mouse )

# Use fd for listing path candidates.
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# tag
if (( $+commands[tag] )); then
  export TAG_SEARCH_PROG=ag  # replace with rg for ripgrep
  tag() { command tag "$@"; source ${TAG_ALIAS_FILE:-/tmp/tag_aliases} 2>/dev/null }
  alias ag=tag  # replace with rg for ripgrep
fi

# nvm
# see: zshrc_nvm

# pnpm
export PNPM_HOME="/Users/reorx/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# yarn
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# bun
export PATH="$PATH:~/.bun/bin"

# atuin
. "$HOME/.atuin/bin/env"
# use fzf as the frontend of atuin
# copy from: https://news.ycombinator.com/item?id=35256206
atuin-setup() {
    #if ! which atuin &> /dev/null; then return 1; fi
    bindkey '^H' _atuin_search_widget

    export ATUIN_NOBIND="true"
    eval "$(atuin init zsh)"
    fzf-atuin-history-widget() {
        local selected num
        setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2>/dev/null

        # local atuin_opts="--cmd-only --limit ${ATUIN_LIMIT:-5000}"
        local atuin_opts="--cmd-only"
        local fzf_opts=(
            --tac
            "-n2..,.."
            --tiebreak=index
            "--query=${LBUFFER}"
            "+m"
            "--bind=ctrl-d:reload(atuin search $atuin_opts -c $PWD),ctrl-r:reload(atuin search $atuin_opts)"
        )

        selected=$(
            eval "atuin search ${atuin_opts}" |
                fzf "${FZF_DEFAULT_OPTS[@]}" "${fzf_opts[@]}"
        )
        local ret=$?
        if [ -n "$selected" ]; then
            LBUFFER="${selected}"
        fi
        zle reset-prompt
        return $ret
    }
    zle -N fzf-atuin-history-widget
    bindkey '^R' fzf-atuin-history-widget
}
atuin-setup

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# bun completions
[ -s "/Users/reorx/.bun/_bun" ] && source "/Users/reorx/.bun/_bun"


####################
# Load other zshrc #
####################

# Load other parts of zshrc
source $HOME/.zshrc_nvm
source $HOME/.zshrc_os
source $HOME/.zshrc_fn
source $HOME/.zshrc_fn_fzf
if [ -e "$HOME/.zshrc_local" ]; then
    source $HOME/.zshrc_local
fi

# profiling end
#zprof
