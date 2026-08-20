#!/bin/sh
# Open the create-workspace prompt as a popup pane.
# Actions run headless (no TTY), so the interactive prompt must live in a
# plugin pane; this wrapper only opens that pane.
set -eu

herdr="${HERDR_BIN_PATH:-herdr}"

exec "$herdr" plugin pane open \
  --plugin "$HERDR_PLUGIN_ID" \
  --entrypoint create_workspace_prompt \
  --focus
