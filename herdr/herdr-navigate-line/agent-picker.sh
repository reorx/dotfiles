#!/bin/sh
# Interactive agent picker (runs inside a popup pane): list every agent
# as "title [status]", filter by typing, focus the selection on enter.
# With fzf: fuzzy filter. Without fzf: numbered list + read.
set -eu

herdr="${HERDR_BIN_PATH:-herdr}"

lines=$("$herdr" agent list | python3 format-agent-lines.py)

if [ -z "$lines" ]; then
  echo "navigate_line: no agents" >&2
  printf 'press enter to close... '
  read -r _ || true
  exit 0
fi

if command -v fzf >/dev/null 2>&1; then
  sel=$(printf '%s\n' "$lines" \
    | fzf --prompt 'agent> ' --delimiter '\t' --with-nth 2.. \
    ) || exit 0  # cancelled
else
  i=0
  printf '%s\n' "$lines" | while IFS="$(printf '\t')" read -r _ label; do
    i=$((i + 1))
    printf '%2d  %s\n' "$i" "$label"
  done
  printf 'agent number: '
  read -r num
  [ -n "${num:-}" ] || exit 0  # cancelled
  sel=$(printf '%s\n' "$lines" | sed -n "${num}p")
  [ -n "$sel" ] || { echo "navigate_line: no such agent: $num" >&2; exit 1; }
fi

pane=$(printf '%s\n' "$sel" | cut -f1)
exec "$herdr" agent focus "$pane"
