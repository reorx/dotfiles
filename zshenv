# reset path to prevent inherit duplication
# WARN but reset path will prevent /etc/zprofile from working,
# thus paths added in .zshrc_local won't be effective for new spawned zsh (e.g. from fzf)
#export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

source "$HOME/.cargo/env"
