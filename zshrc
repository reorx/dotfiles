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

# --- zsh startup optimization (2026-07) ------------------------------------
# Startup used to waste ~500ms because compinit rebuilt .zcompdump on EVERY
# shell. Two separate causes, both fixed here + one system-level fix:
#
# (a) /opt/homebrew/share/zsh{,/site-functions} were group-writable, so
#     compaudit flagged them insecure and `compinit -i` silently dropped them
#     from fpath. The dump was then written with the reduced file count but
#     validated against the full one on the next startup -> never matched ->
#     full rebuild (800 compdef calls + compdump write) every time.
#     System fix (redo if brew ever restores group-write):
#       chmod -R go-w /opt/homebrew/share/zsh
#
# (b) brew shellenv (in ~/.zprofile) exports FPATH, so nested shells (zellij
#     panes, zsh-in-zsh) inherit the parent's fully-built fpath while fresh
#     login shells start from the system default. The two contexts disagree on
#     the completion file count and keep invalidating each other's dump.
#     Fixed by resetting fpath to a fixed baseline before compinit runs (in
#     oh-my-zsh) and un-exporting FPATH so it stops leaking into children.
fpath=(/opt/homebrew/share/zsh/site-functions /usr/local/share/zsh/site-functions /usr/share/zsh/site-functions /usr/share/zsh/$ZSH_VERSION/functions)
typeset +x FPATH

# Skip compaudit's security audit (~10-20ms): it stats every completion dir
# and file looking for insecure ownership/permissions, which is pointless on a
# single-user machine (and the homebrew dir permissions are already fixed).
# ZSH_DISABLE_COMPFIX alone is NOT enough: it makes omz run `compinit -u`
# instead of `compinit -i`, but both still run the audit -- only `compinit -C`
# skips it, and omz doesn't expose that. So we stub compaudit out before
# oh-my-zsh autoloads it (zsh's autoload silently keeps an existing function).
# The stub must still populate _i_files (list of completion files in fpath):
# the real compaudit computes it as a side effect and compinit compares its
# count against the header of .zcompdump to decide whether to rebuild.
# To restore the real one: unfunction compaudit; autoload -Uz compaudit
ZSH_DISABLE_COMPFIX=true
compaudit() { _i_files=( "${(@)^fpath:/.}"/^([^_]*|*~|*.zwc)(N) ); _i_wdirs=(); _i_wfiles=(); return 0 }
# ----------------------------------------------------------------------------

source $ZSH/oh-my-zsh.sh


#######
# zsh #
#######

# use pure prompt
fpath+=$HOME/.zsh-pure
autoload -U promptinit; promptinit
prompt pure

# --- cmux (libghostty) prompt-redraw workaround ---------------------------
# cmux mishandles `zle reset-prompt` for Pure's two-line prompt: every in-place
# redraw leaves a stale preprompt, so it accumulates (1→2→3…) on each command,
# git dir or not (Pure's async vcs_info forces a redraw every command). iTerm2
# and Ghostty.app render the same config fine, so it's a cmux terminal bug.
#
# Fix: no-op Pure's reset_prompt — the single chokepoint for every async
# `zle .reset-prompt` (pure.zsh). The prompt is then only drawn by precmd
# (normal draw, no reset), which cmux handles correctly. Tradeoff: async git
# info (branch / dirty / ⇡⇣ arrows) refreshes on your *next* prompt instead of
# updating the current one live — no visual drift, info lags by one prompt.
#
# cmux exports CMUX_SURFACE_ID / CMUX_WORKSPACE_ID — gate on that (TERM_PROGRAM
# is just inherited from Ghostty, so it can't distinguish cmux from Ghostty.app).
if [[ -n $CMUX_SURFACE_ID || -n $CMUX_WORKSPACE_ID ]]; then
    prompt_pure_reset_prompt() { }  # cmux: suppress in-place multi-line redraw
fi
# --------------------------------------------------------------------------


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

# make sure programs that respects XDG_CONFIG_HOME uses ~/.config rather than ~/Library/Application Support
export XDG_CONFIG_HOME="$HOME/.config"

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

# Obsidian
export OBSIDIAN_VAULT_PATH="/Users/reorx/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian-Base"
export OBSIDIAN_BACKUP_DIR="/Users/reorx/Library/CloudStorage/OneDrive-Personal/Backups/Obsidian"


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
alias zj=zellij


#################
# Program Inits #
#################

# Load z
eval "$(zoxide init zsh)"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# fd respects .gitignore, see more: https://github.com/sharkdp/fd#hidden-and-ignored-files
export FZF_DEFAULT_COMMAND='fd -t f'
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

# mise
eval "$(/Users/reorx/.local/bin/mise activate zsh)"

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
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# bun completions
[ -s "/Users/reorx/.bun/_bun" ] && source "/Users/reorx/.bun/_bun"

# atuin
. "$HOME/.atuin/bin/env"
# use fzf as the frontend of atuin
# copy from: https://news.ycombinator.com/item?id=35256206
atuin-setup() {
    #if ! which atuin &> /dev/null; then return 1; fi
    bindkey '^H' _atuin_search_widget

    export ATUIN_NOBIND="true"
    # Cache `atuin init zsh` output instead of eval-ing it on every startup:
    # spawning the atuin binary cost ~20ms per shell. The cache regenerates
    # automatically when the atuin binary is newer than the cache file (i.e.
    # after an atuin upgrade); delete the cache file to force a refresh.
    local atuin_init_cache="$HOME/.cache/atuin-init.zsh"
    if [[ ! -s $atuin_init_cache || $HOME/.atuin/bin/atuin -nt $atuin_init_cache ]]; then
        mkdir -p "$HOME/.cache"
        atuin init zsh > "$atuin_init_cache"
    fi
    source "$atuin_init_cache"
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

# postgres
export PATH="/opt/homebrew/opt/postgresql@18/bin:$PATH"

# colima
export COLIMA_HOME="$HOME/.config/colima"


####################
# Load other zshrc #
####################

# Load other parts of zshrc
#source $HOME/.zshrc_nvm
source $HOME/.zshrc_os
source $HOME/.zshrc_fn
source $HOME/.zshrc_fn_fzf
if [ -e "$HOME/.zshrc_local" ]; then
    source $HOME/.zshrc_local
fi


# profiling end
#zprof
