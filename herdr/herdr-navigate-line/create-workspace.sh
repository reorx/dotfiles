#!/bin/sh
# Interactive prompt (runs inside a popup pane): ask for a directory under
# ~/Code, then create a Herdr workspace with that directory as its CWD.
# With fzf: pick an existing directory, or type a name not in the list.
# Without fzf: plain read.
set -eu

herdr="${HERDR_BIN_PATH:-herdr}"
base="$HOME/Code"

fail() {
  echo "navigate_line: $1" >&2
  printf 'press enter to close... '
  read -r _ || true
  exit 1
}

if command -v fzf >/dev/null 2>&1; then
  # --print-query: last output line is the selection, or the raw query when
  # nothing matched, so typing a new name also works.
  name=$(cd "$base" && ls -1d -- */ 2>/dev/null | sed 's:/$::' \
    | fzf --prompt 'workspace dir under ~/Code> ' --print-query \
    | tail -n 1) || true
else
  printf 'workspace dir under ~/Code: '
  read -r name
fi

[ -n "${name:-}" ] || exit 0  # cancelled

case $name in
  /*) dir=$name ;;
  '~'*) dir=$HOME${name#'~'} ;;
  *) dir=$base/$name ;;
esac

[ -d "$dir" ] || fail "not a directory: $dir"

exec "$herdr" workspace create --cwd "$dir" --focus
