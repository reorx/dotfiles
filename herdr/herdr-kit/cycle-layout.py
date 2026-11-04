#!/usr/bin/env python3
"""Rotate the panes of the current tab through preset layouts, like tmux
next-layout (prefix+space) and previous-layout.

Usage: cycle-layout.py next|previous

The presets follow tmux's order: even-horizontal, even-vertical,
main-horizontal, main-vertical, tiled. Presets that draw the same picture
for the current pane count are listed once, so two panes just toggle
between side by side and stacked. Panes keep their order (the split tree's
leaf order), and main-* give the first pane half of the tab.

The current layout is recognized by its shape alone: a resized split still
counts as its layout, and three columns count as even-horizontal however
they were split. A layout that matches no preset goes to the first one
(previous: the last one).

Herdr has no call that rearranges a tab in place: `layout.apply` replaces
the whole tab with fresh shells, and `pane.move` within the same tab
changes nothing. So the panes take a detour that keeps every process
running: all panes but the first move into a holding tab, then come back
one by one, each split off a pane that is already in place. The tab keeps
its id, and Herdr closes the holding tab when its last pane leaves.
"""

from __future__ import annotations

import functools
import json
import os
import socket
import sys

MAIN_SHARE = 0.5
HOLD_LABEL = 'kit-layout'
STEPS = {'next': 1, 'previous': -1}


def request(sock_path, method, params):
    """Send one request over the Herdr socket and return the parsed reply."""
    conn = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    conn.connect(sock_path)
    conn.sendall((json.dumps({'id': 'kit', 'method': method, 'params': params}) + '\n').encode())
    buf = b''
    while not buf.endswith(b'\n'):
        chunk = conn.recv(65536)
        if not chunk:
            break
        buf += chunk
    conn.close()
    reply = json.loads(buf)
    if 'error' in reply:
        raise RuntimeError(f'{method}: {reply["error"].get("message", reply["error"])}')
    return reply['result']


def pane(pane_id):
    return {'type': 'pane', 'pane_id': pane_id}


def split(direction, ratio, first, second):
    """A split node; `ratio` is the share of the first (left or top) slot."""
    return {'type': 'split', 'direction': direction, 'ratio': ratio, 'first': first, 'second': second}


def leaves(node):
    if node['type'] == 'pane':
        return [node['pane_id']]
    return leaves(node['first']) + leaves(node['second'])


def shape(node):
    """What the layout looks like: the tree without ratios, nested splits of one direction merged."""
    if node['type'] == 'pane':
        return node['pane_id']
    children = []
    for child in (node['first'], node['second']):
        sub = shape(child)
        if isinstance(sub, tuple) and sub[0] == node['direction']:
            children.extend(sub[1])
        else:
            children.append(sub)
    return (node['direction'], tuple(children))


def even(direction, nodes):
    """Nodes in a row (`right`) or a column (`down`), each with the same share."""
    if len(nodes) == 1:
        return nodes[0]
    return split(direction, 1 / len(nodes), nodes[0], even(direction, nodes[1:]))


def tiled(panes):
    """tmux's grid: add rows and columns in turn until every pane has a cell, then fill row by row."""
    rows = columns = 1
    while rows * columns < len(panes):
        rows += 1
        if rows * columns < len(panes):
            columns += 1
    cells = [pane(p) for p in panes]
    return even('down', [even('right', cells[i : i + columns]) for i in range(0, len(cells), columns)])


def presets(panes):
    """The preset layouts of these panes in tmux's order, as (name, tree); same-shaped ones are listed once."""
    nodes = [pane(p) for p in panes]
    candidates = [
        ('even-horizontal', even('right', nodes)),
        ('even-vertical', even('down', nodes)),
        ('main-horizontal', split('down', MAIN_SHARE, nodes[0], even('right', nodes[1:]))),
        ('main-vertical', split('right', MAIN_SHARE, nodes[0], even('down', nodes[1:]))),
        ('tiled', tiled(panes)),
    ]
    layouts, shapes = [], []
    for name, tree in candidates:
        if shape(tree) not in shapes:
            layouts.append((name, tree))
            shapes.append(shape(tree))
    return layouts


def next_layout(root, step):
    """The preset `step` places after the current layout (1 next, -1 previous) as (name, tree); None for one pane."""
    panes = leaves(root)
    if len(panes) < 2:
        return None
    layouts = presets(panes)
    shapes = [shape(tree) for _, tree in layouts]
    current = shape(root)
    if current not in shapes:
        return layouts[0 if step > 0 else -1]
    return layouts[(shapes.index(current) + step) % len(layouts)]


def placements(tree):
    """The moves that grow `tree` from its first pane, as (pane, target, direction, ratio).

    A split's second subtree starts with its first pane, split off the first
    pane of the first subtree, which is already in place by then.
    """
    if tree['type'] == 'pane':
        return []
    move = (leaves(tree['second'])[0], leaves(tree['first'])[0], tree['direction'], tree['ratio'])
    return [move] + placements(tree['first']) + placements(tree['second'])


def move(request, pane_id, destination):
    result = request('pane.move', {'pane_id': pane_id, 'destination': destination, 'focus': False})['move_result']
    if not result['changed']:
        raise RuntimeError(f'pane.move {pane_id}: nothing changed ({result.get("reason")})')
    return result


def park(request, panes):
    """Move the panes into a new holding tab, each splitting the largest pane there in half."""
    result = move(request, panes[0], {'type': 'new_tab', 'label': HOLD_LABEL})
    hold = result['created_tab']['tab_id']
    for pane_id in panes[1:]:
        largest = max(result['target_layout']['panes'], key=lambda p: p['rect']['width'] * p['rect']['height'])
        rect = largest['rect']
        # a cell is about twice as tall as wide; split the side that looks longer
        direction = 'right' if rect['width'] >= 2 * rect['height'] else 'down'
        destination = {
            'type': 'tab',
            'tab_id': hold,
            'target_pane_id': largest['pane_id'],
            'split': direction,
            'ratio': 0.5,
        }
        result = move(request, pane_id, destination)


def place(request, tab_id, tree):
    """Bring the parked panes back into the tab, where only the tree's first pane is left."""
    for pane_id, target, direction, ratio in placements(tree):
        destination = {'type': 'tab', 'tab_id': tab_id, 'target_pane_id': target, 'split': direction, 'ratio': ratio}
        move(request, pane_id, destination)


def run(request, pane_id, step):
    """Rearrange the tab of `pane_id` into the preset `step` places away; returns its name, None for one pane."""
    layout = request('layout.export', {'pane_id': pane_id})['layout']
    picked = next_layout(layout['root'], step)
    if picked is None:
        return None
    name, tree = picked
    if layout['zoomed']:
        request('pane.zoom', {'pane_id': pane_id, 'mode': 'off'})
    park(request, leaves(tree)[1:])
    place(request, layout['tab_id'], tree)
    request('pane.focus', {'pane_id': layout['focused_pane_id']})
    return name


def main():
    sock_path = os.environ.get('HERDR_SOCKET_PATH')
    pane_id = os.environ.get('HERDR_PANE_ID')
    if not (sock_path and pane_id):
        print('kit: HERDR_SOCKET_PATH and HERDR_PANE_ID are required', file=sys.stderr)
        return 1
    if sys.argv[1:] not in (['next'], ['previous']):
        print('usage: cycle-layout.py next|previous', file=sys.stderr)
        return 2
    run(functools.partial(request, sock_path), pane_id, STEPS[sys.argv[1]])
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, RuntimeError) as e:
        print(f'kit: {e}', file=sys.stderr)
        sys.exit(1)
