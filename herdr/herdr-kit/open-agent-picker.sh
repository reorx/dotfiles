#!/bin/sh
# Open the agent picker as a popup pane.
# Actions run headless (no TTY), so the interactive picker must live in a
# plugin pane; this wrapper only opens that pane.
set -eu

herdr="${HERDR_BIN_PATH:-herdr}"

exec "$herdr" plugin pane open \
  --plugin "$HERDR_PLUGIN_ID" \
  --entrypoint agent_picker \
  --focus
