#!/usr/bin/env python3
"""Create a tab right after the current one and focus it.

`herdr tab create` always appends at the end of the workspace, and the CLI
has no `tab move`; the socket API does (`tab.move` with a 0-based
`insert_index`), so this script talks to the socket directly. No label is
passed: Herdr auto-numbers unlabeled tabs by position, so the ordinals stay
in order after the insert.
"""
import json
import os
import socket
import sys


def request(sock_path, method, params):
    """Send one request over the Herdr socket and return the parsed reply."""
    conn = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    conn.connect(sock_path)
    conn.sendall((json.dumps({"id": "navigate_line", "method": method, "params": params}) + "\n").encode())
    buf = b""
    while not buf.endswith(b"\n"):
        chunk = conn.recv(65536)
        if not chunk:
            break
        buf += chunk
    conn.close()
    reply = json.loads(buf)
    if "error" in reply:
        raise RuntimeError(f"{method}: {reply['error'].get('message', reply['error'])}")
    return reply["result"]


def main():
    sock_path = os.environ.get("HERDR_SOCKET_PATH")
    workspace_id = os.environ.get("HERDR_WORKSPACE_ID")
    current_tab = os.environ.get("HERDR_TAB_ID")
    if not (sock_path and workspace_id and current_tab):
        print("navigate_line: HERDR_SOCKET_PATH, HERDR_WORKSPACE_ID and HERDR_TAB_ID are required", file=sys.stderr)
        return 1

    tabs = [t["tab_id"] for t in request(sock_path, "tab.list", {"workspace_id": workspace_id})["tabs"]]
    created = request(sock_path, "tab.create", {"workspace_id": workspace_id, "focus": True})
    new_tab = created["tab"]["tab_id"]

    # Unknown current tab or current tab already last: the appended tab is
    # already in the right place.
    if current_tab in tabs and tabs.index(current_tab) + 1 < len(tabs):
        request(sock_path, "tab.move", {"tab_id": new_tab, "insert_index": tabs.index(current_tab) + 1})
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, RuntimeError) as e:
        print(f"navigate_line: {e}", file=sys.stderr)
        sys.exit(1)
