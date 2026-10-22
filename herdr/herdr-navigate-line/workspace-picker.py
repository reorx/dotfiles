#!/usr/bin/env python3
"""Interactive workspace picker with get-or-create (runs inside a popup pane).

Lists every Herdr workspace first, in number order, then the directories
under ~/Code that have no workspace yet. Enter on a workspace focuses it;
enter on a directory focuses the workspace already opened there, or
creates one with that directory as its CWD. Text that matches nothing is
used as a directory: relative to ~/Code, or a full path when it starts
with / or ~.

A workspace's directory ("root") is its git checkout path when Herdr
reports one, otherwise the most common cwd among its panes. A directory
has a workspace when a root equals it or lies inside it.

With fzf: fuzzy filter. Without fzf: numbered list + read.
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
from collections import Counter
from dataclasses import dataclass
from typing import Optional

BASE = os.path.expanduser('~/Code')

RESET = '\033[0m'
WORKSPACE_STYLE = '\033[1;36m'
PATH_STYLE = '\033[2m'
STATUS_STYLES = {
    'working': '\033[33m',
    'blocked': '\033[31m',
    'done': '\033[32m',
    'idle': '\033[2m',
}


@dataclass
class Row:
    """One picker line; target is "ws:<workspace_id>" or "dir:<path>"."""

    target: str
    workspace: Optional[dict] = None
    root: Optional[str] = None
    name: str = ''


def workspace_root(workspace, panes):
    checkout = (workspace.get('worktree') or {}).get('checkout_path')
    if checkout:
        return checkout
    # most_common keeps first-seen order on ties, so the first pane wins
    cwds = Counter(p['cwd'] for p in panes if p['workspace_id'] == workspace['workspace_id'] and p.get('cwd'))
    if not cwds:
        return None
    return cwds.most_common(1)[0][0]


def list_dirs(base):
    if not os.path.isdir(base):
        return []
    return sorted(e.name for e in os.scandir(base) if not e.name.startswith('.') and e.is_dir())


def contains(parent, path):
    """True when path is parent or inside it; both must be realpaths."""
    return path == parent or path.startswith(parent.rstrip('/') + '/')


def build_rows(workspaces, panes, base, dir_names):
    rows = [Row(f'ws:{w["workspace_id"]}', workspace=w, root=workspace_root(w, panes)) for w in workspaces]
    real_roots = [os.path.realpath(r.root) for r in rows if r.root]
    for name in dir_names:
        path = os.path.join(base, name)
        real = os.path.realpath(path)
        if not any(contains(real, root) for root in real_roots):
            rows.append(Row(f'dir:{path}', name=name))
    return rows


def status_text(workspace):
    status = workspace['agent_status']
    return '' if status == 'unknown' else f'[{status}]'


def display_path(root, label, base):
    """Where the workspace lives, when its label does not already say so."""
    if not root:
        return ''
    real_root = os.path.realpath(root)
    real_base = os.path.realpath(base)
    if real_root == os.path.join(real_base, label):
        return ''
    if contains(real_base, real_root):
        return os.path.relpath(real_root, real_base)
    home = os.path.expanduser('~')
    if contains(home, root):
        return '~' + root[len(home) :]
    return root


def styled(text, style):
    return f'{style}{text}{RESET}' if style and text.strip() else text


def format_workspace(row, base, num_width, label_width, status_width):
    w = row.workspace
    mark = '*' if w['focused'] else ' '
    cells = [(f'{w["label"]:<{label_width}}', WORKSPACE_STYLE)]
    if status_width:
        cells.append((f'{status_text(w):<{status_width}}', STATUS_STYLES.get(w['agent_status'], '')))
    cells.append((display_path(row.root, w['label'], base), PATH_STYLE))
    while len(cells) > 1 and not cells[-1][0].strip():
        cells.pop()
    cells[-1] = (cells[-1][0].rstrip(), cells[-1][1])
    return f'{mark} {w["number"]:>{num_width}}  ' + '  '.join(styled(text, style) for text, style in cells)


def format_lines(rows, base):
    """One "<target>\\t<display>" line per row; the picker hides the target."""
    workspace_rows = [r for r in rows if r.workspace]
    num_width = max((len(str(r.workspace['number'])) for r in workspace_rows), default=0)
    label_width = max((len(r.workspace['label']) for r in workspace_rows), default=0)
    status_width = max((len(status_text(r.workspace)) for r in workspace_rows), default=0)
    lines = []
    for r in rows:
        if r.workspace:
            display = format_workspace(r, base, num_width, label_width, status_width)
        else:
            display = f'  {"":>{num_width}}  {r.name}'
        lines.append(f'{r.target}\t{display}')
    return lines


def find_workspace(path, workspaces, panes):
    """The workspace opened at path, else the first one opened inside it."""
    real = os.path.realpath(path)
    inside = None
    for w in workspaces:
        root = workspace_root(w, panes)
        if not root:
            continue
        real_root = os.path.realpath(root)
        if real_root == real:
            return w
        if inside is None and contains(real, real_root):
            inside = w
    return inside


def resolve_target(target, workspaces, panes, base):
    """Return ("focus", workspace_id) or ("create", dir) for a picked target or typed text."""
    if target.startswith('ws:'):
        return 'focus', target[len('ws:') :]
    if target.startswith('dir:'):
        path = target[len('dir:') :]
    else:
        # join drops base when the expanded text is already absolute
        path = os.path.join(base, os.path.expanduser(target))
    path = os.path.normpath(path)
    if not os.path.isdir(path):
        raise NotADirectoryError(f'not a directory: {path}')
    w = find_workspace(path, workspaces, panes)
    if w:
        return 'focus', w['workspace_id']
    return 'create', path


def herdr_result(herdr, *args):
    out = subprocess.run([herdr, *args], check=True, capture_output=True, text=True).stdout
    return json.loads(out)['result']


def pick_fzf(lines):
    """Return the picked target, the typed text when nothing matched, or '' when cancelled."""
    proc = subprocess.run(
        [
            'fzf',
            '--ansi',
            '--prompt',
            'workspace> ',
            '--delimiter',
            '\t',
            '--with-nth',
            '2..',
            '--tiebreak',
            'index',
            '--print-query',
        ],
        input='\n'.join(lines) + '\n',
        stdout=subprocess.PIPE,
        text=True,
    )
    if proc.returncode not in (0, 1):  # 130: cancelled
        return ''
    # --print-query: first line is the query, the second the selection (empty when nothing matched)
    out = proc.stdout.split('\n')
    if len(out) > 1 and out[1]:
        return out[1].split('\t', 1)[0]
    return out[0].strip()


def pick_numbered(lines):
    for i, line in enumerate(lines, 1):
        display = line.split('\t', 1)[1]
        print(f'{i:3d}  {display}')
    answer = input('workspace number, or dir under ~/Code: ').strip()
    if answer.isdigit() and 1 <= int(answer) <= len(lines):
        return lines[int(answer) - 1].split('\t', 1)[0]
    return answer


def fail(message):
    print(f'navigate_line: {message}', file=sys.stderr)
    try:
        input('press enter to close... ')
    except (KeyboardInterrupt, EOFError):
        pass
    return 1


def main():
    herdr = os.environ.get('HERDR_BIN_PATH', 'herdr')
    workspaces = herdr_result(herdr, 'workspace', 'list')['workspaces']
    # leave out this picker's own pane, whose cwd is the plugin dir
    panes = [p for p in herdr_result(herdr, 'pane', 'list')['panes'] if p['pane_id'] != os.environ.get('HERDR_PANE_ID')]
    lines = format_lines(build_rows(workspaces, panes, BASE, list_dirs(BASE)), BASE)

    pick = pick_fzf if shutil.which('fzf') else pick_numbered
    try:
        target = pick(lines)
    except (KeyboardInterrupt, EOFError):
        return 0
    if not target:
        return 0

    try:
        action, value = resolve_target(target, workspaces, panes, BASE)
    except NotADirectoryError as e:
        return fail(str(e))
    if action == 'focus':
        os.execvp(herdr, [herdr, 'workspace', 'focus', value])
    os.execvp(herdr, [herdr, 'workspace', 'create', '--cwd', value, '--focus'])


if __name__ == '__main__':
    sys.exit(main())
