#!/bin/sh
# Move the pane this action was invoked from into its own new tab, like
# tmux break-pane. A pane that is already alone in its tab is left
# untouched; a zoomed tab is unzoomed before the move.
set -eu

herdr="${HERDR_BIN_PATH:-herdr}"

if [ -z "${HERDR_PANE_ID:-}" ]; then
  echo "navigate_line: no pane in invocation context" >&2
  exit 1
fi

layout=$("$herdr" pane layout --pane "$HERDR_PANE_ID")

# The layout JSON has one "pane_id" key per pane in the tab.
pane_count=$(printf '%s' "$layout" | grep -o '"pane_id"' | wc -l)
if [ "$pane_count" -le 1 ]; then
  echo "navigate_line: pane is already alone in its tab" >&2
  exit 0
fi

case $layout in
  *'"zoomed":true'*) "$herdr" pane zoom "$HERDR_PANE_ID" --off ;;
esac

exec "$herdr" pane move "$HERDR_PANE_ID" --new-tab --focus
