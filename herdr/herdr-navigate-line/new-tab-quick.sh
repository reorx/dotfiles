#!/bin/sh
# Create a tab in the current workspace without a name prompt. No label is
# passed: Herdr numbers unlabeled tabs by position, so the ordinal keeps
# following the tab's position after other tabs are inserted or closed.
set -eu

herdr="${HERDR_BIN_PATH:-herdr}"

if [ -z "${HERDR_WORKSPACE_ID:-}" ]; then
  echo "navigate_line: no workspace in invocation context" >&2
  exit 1
fi

exec "$herdr" tab create --workspace "$HERDR_WORKSPACE_ID" --focus
