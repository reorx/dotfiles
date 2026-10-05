#!/usr/bin/env python3
"""Read `herdr workspace list` JSON on stdin, print one line per workspace:

    <workspace_id>\t<mark> <number>  <label padded>  [<agent status>]

The first tab-separated field is the focus target; the picker hides it
from display (fzf --with-nth 2..) and cuts it back out on selection.
The status is omitted when it is "unknown" (no agent in the workspace).
"""

import json
import sys


def main():
    workspaces = json.load(sys.stdin)['result']['workspaces']
    num_width = max((len(str(w['number'])) for w in workspaces), default=0)
    label_width = max((len(w['label']) for w in workspaces), default=0)
    for w in workspaces:
        mark = '*' if w['focused'] else ' '
        status = '' if w['agent_status'] == 'unknown' else f'[{w["agent_status"]}]'
        line = f'{mark} {w["number"]:>{num_width}}  {w["label"]:<{label_width}}  {status}'
        print(f'{w["workspace_id"]}\t{line.rstrip()}')


if __name__ == '__main__':
    main()
