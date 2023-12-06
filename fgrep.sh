#FZF_PREVIEW_CONTEXT_CMD='cat {1}'
FZF_PREVIEW_CONTEXT_CMD='sed -n -e "$(({2}-10)),$(({2}+10) p" -e "$(({2}+10)) q" {1}'

grep -Rn "$@" | fzf -d: \
    --ansi \
    --height 100% \
    --color "hl:-1:underline,hl+:-1:underline:reverse" \
    --bind="enter:execute:$EDITOR +{2} {1}" \
    --preview="[[ -n {1} ]] && $FZF_PREVIEW_CONTEXT_CMD"
