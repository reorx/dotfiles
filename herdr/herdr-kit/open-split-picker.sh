#!/bin/sh
# Open the new-pane layout picker as a popup.
# A popup process gets no HERDR_PANE_ID, so the pane this action was
# invoked from is passed to it in KIT_SPLIT_PANE.
set -eu

herdr="${HERDR_BIN_PATH:-herdr}"

if [ -z "${HERDR_PANE_ID:-}" ]; then
  echo "kit: no pane in invocation context" >&2
  exit 1
fi

exec "$herdr" plugin pane open \
  --plugin "$HERDR_PLUGIN_ID" \
  --entrypoint split_picker \
  --env "KIT_SPLIT_PANE=$HERDR_PANE_ID" \
  --focus
