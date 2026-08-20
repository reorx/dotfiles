#!/bin/sh
# Forward key combos to the pane this action was invoked from.
# Usage: send-keys.sh <key>...  (key combos in Herdr syntax, e.g. ctrl+a, alt+f)
set -eu

herdr="${HERDR_BIN_PATH:-herdr}"

if [ -z "${HERDR_PANE_ID:-}" ]; then
  echo "navigate_line: no pane in invocation context" >&2
  exit 1
fi

exec "$herdr" pane send-keys "$HERDR_PANE_ID" "$@"
