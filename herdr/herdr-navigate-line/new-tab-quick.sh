#!/bin/sh
# Create a tab in the current workspace without a name prompt. The label
# defaults to the tab ordinal (existing tab count + 1).
set -eu

herdr="${HERDR_BIN_PATH:-herdr}"

if [ -z "${HERDR_WORKSPACE_ID:-}" ]; then
  echo "navigate_line: no workspace in invocation context" >&2
  exit 1
fi

# The tab-list JSON has one "tab_id" key per tab in the workspace.
tabs=$("$herdr" tab list --workspace "$HERDR_WORKSPACE_ID")
count=$(printf '%s' "$tabs" | grep -o '"tab_id"' | wc -l)
label=$((count + 1))

exec "$herdr" tab create --workspace "$HERDR_WORKSPACE_ID" --label "$label" --focus
