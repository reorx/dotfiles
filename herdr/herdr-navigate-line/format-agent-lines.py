#!/usr/bin/env python3
"""Read `herdr agent list` JSON on stdin, print one line per agent:

    <pane_id>\t<title padded>  [<status>]

The first tab-separated field is the focus target; the picker hides it
from display (fzf --with-nth 2..) and cuts it back out on selection.
"""

import json
import sys


def main():
    agents = json.load(sys.stdin)['result']['agents']
    width = max((len(a['terminal_title']) for a in agents), default=0)
    for a in agents:
        mark = '*' if a['focused'] else ' '
        print(f'{a["pane_id"]}\t{mark} {a["terminal_title"]:<{width}}  [{a["agent_status"]}]')


if __name__ == '__main__':
    main()
