#!/bin/sh
# Interactive workspace picker (runs inside a popup pane): list every
# workspace as "number label [status]", filter by typing, focus the
# selection on enter.
# With fzf: fuzzy filter. Without fzf: numbered list + read.
set -eu

herdr="${HERDR_BIN_PATH:-herdr}"

lines=$("$herdr" workspace list | python3 format-workspace-lines.py)

if [ -z "$lines" ]; then
  echo "navigate_line: no workspaces" >&2
  printf 'press enter to close... '
  read -r _ || true
  exit 0
fi

if command -v fzf >/dev/null 2>&1; then
  sel=$(printf '%s\n' "$lines" \
    | fzf --prompt 'workspace> ' --delimiter '\t' --with-nth 2.. \
    ) || exit 0  # cancelled
else
  i=0
  printf '%s\n' "$lines" | while IFS="$(printf '\t')" read -r _ label; do
    i=$((i + 1))
    printf '%2d  %s\n' "$i" "$label"
  done
  printf 'workspace number: '
  read -r num
  [ -n "${num:-}" ] || exit 0  # cancelled
  sel=$(printf '%s\n' "$lines" | sed -n "${num}p")
  [ -n "$sel" ] || { echo "navigate_line: no such workspace: $num" >&2; exit 1; }
fi

ws=$(printf '%s\n' "$sel" | cut -f1)
exec "$herdr" workspace focus "$ws"
