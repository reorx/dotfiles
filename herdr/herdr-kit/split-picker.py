#!/usr/bin/env python3
"""New-pane layout picker (runs inside a popup).

Draws an ASCII preview of four ways to split the pane the action was
invoked from and applies the one picked with a single key press, no
enter: 1 bottom, 2 top, 3 left, 4 right, the new pane taking 25%. A line
below the previews offers the plain halves: v vertical (side by side) and
h horizontal (stacked), Herdr's own naming. q, Esc or ctrl+c cancels.

`herdr pane split` only goes right or down, and --ratio is the share of
the first (top/left) slot. Top and left therefore split with the original
pane in the 25% slot, then swap the two panes: a swap exchanges the panes
but keeps the slot sizes.

A popup gets no HERDR_PANE_ID, so the opener passes the pane to split in
KIT_SPLIT_PANE. The new pane is painted in the active config's ui.accent.
"""

from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import sys
import termios
import tty
from dataclasses import dataclass
from typing import Iterator, Optional

QUARTER, HALF = 0.25, 0.5

# preview box, borders excluded; terminal cells are about twice as tall as wide
INNER_W, INNER_H = 16, 7
BOX_W = INNER_W + 2
MARGIN, GAP = 2, 3
ROW_WIDTH = 2 * MARGIN + 4 * BOX_W + 3 * GAP

SHADE = '░'
HINT = 'press 1-4, v or h to split the current pane · q / esc to cancel'

RESET = '\033[0m'
BOLD = '\033[1m'
DIM = '\033[2m'
FALLBACK_ACCENT = '\033[35m'

CANCEL_KEYS = {b'q', b'\x1b', b'\x03'}


@dataclass(frozen=True)
class Layout:
    key: bytes
    name: str
    direction: str  # herdr split direction: "down" or "right"
    new_first: bool  # the new pane ends up on top / on the left
    share: float  # the new pane's share of the split pane
    note: str = ''

    @property
    def title(self):
        return f'{self.key.decode()} {self.name} {round(self.share * 100)}%'


PREVIEWED = (
    Layout(b'1', 'bottom', 'down', False, QUARTER),
    Layout(b'2', 'top', 'down', True, QUARTER),
    Layout(b'3', 'left', 'right', True, QUARTER),
    Layout(b'4', 'right', 'right', False, QUARTER),
)
HALVES = (
    Layout(b'v', 'vertical', 'right', False, HALF, 'side by side'),
    Layout(b'h', 'horizontal', 'down', False, HALF, 'stacked'),
)
LAYOUTS = {layout.name: layout for layout in PREVIEWED + HALVES}
BY_KEY = {layout.key: layout for layout in LAYOUTS.values()}


def config_path():
    return os.environ.get('HERDR_CONFIG_PATH') or os.path.expanduser('~/.config/herdr/config.toml')


def read_accent():
    """The `accent` value of the [ui] table in the active Herdr config, or None."""
    path = config_path()
    if not os.path.isfile(path):
        return None
    table = None
    with open(path) as f:
        for line in f:
            line = line.strip()
            if line.startswith('['):
                table = line.strip('[]').strip()
                continue
            m = re.match(r'accent\s*=\s*"([^"]*)"', line)
            if m and table == 'ui':
                return m.group(1)
    return None


def accent_style(color):
    """ANSI foreground for a Herdr color ("#rrggbb" or "rgb(r, g, b)"); a plain magenta otherwise."""
    m = re.fullmatch(r'#([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})', (color or '').strip())
    if m:
        rgb = [int(part, 16) for part in m.groups()]
    else:
        m = re.fullmatch(r'rgb\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)', (color or '').strip())
        if not m:
            return FALLBACK_ACCENT
        rgb = [int(part) for part in m.groups()]
    return '\033[38;2;{};{};{}m'.format(*rgb)


def choose(keys: Iterator[bytes]) -> Optional[Layout]:
    """Return the layout of the first key that picks one; None when a key cancels or input ends."""
    for key in keys:
        if key in CANCEL_KEYS:
            return None
        if key in BY_KEY:
            return BY_KEY[key]
    return None


def put_label(cells, row, cols, text, style):
    """Center text in cols of row; it gets a blank cell on each side so it stands out of the shade."""
    if len(text) + 2 <= len(cols):
        text = f' {text} '
    else:
        for c in cols:
            cells[row][c] = (' ', style)
    start = cols[0] + (len(cols) - len(text)) // 2
    for i, ch in enumerate(text):
        cells[row][start + i] = (ch, style)


def preview(layout, accent=FALLBACK_ACCENT):
    """One preview box as styled lines, borders included; the new pane is shaded."""
    horizontal = layout.direction == 'down'  # the divider is a horizontal line
    size = INNER_H if horizontal else INNER_W
    new_size = round((size + 1) * layout.share)
    div = new_size if layout.new_first else size - new_size - 1
    new_span = range(0, div) if layout.new_first else range(div + 1, size)
    cur_span = range(div + 1, size) if layout.new_first else range(0, div)

    cells = []
    for r in range(INNER_H):
        row = []
        for c in range(INNER_W):
            pos = r if horizontal else c
            if pos == div:
                row.append(('─' if horizontal else '│', DIM))
            elif pos in new_span:
                row.append((SHADE, accent))
            else:
                row.append((' ', ''))
        cells.append(row)

    all_rows, all_cols = range(INNER_H), range(INNER_W)
    for span, text, style in ((new_span, 'new', accent), (cur_span, 'current', '')):
        rows, cols = (span, all_cols) if horizontal else (all_rows, span)
        put_label(cells, rows[len(rows) // 2], cols, text, style)

    top, bottom = ['─'] * INNER_W, ['─'] * INNER_W
    if not horizontal:
        top[div], bottom[div] = '┬', '┴'
    lines = [DIM + '┌' + ''.join(top) + '┐' + RESET]
    for r, row in enumerate(cells):
        left, right = ('├', '┤') if horizontal and r == div else ('│', '│')
        body = ''.join(f'{style}{ch}{RESET}' if style else ch for ch, style in row)
        lines.append(f'{DIM}{left}{RESET}{body}{DIM}{right}{RESET}')
    lines.append(DIM + '└' + ''.join(bottom) + '┘' + RESET)
    return lines


def styled_title(layout, accent, width=0):
    """The layout title with the key highlighted, centered in width cells (no padding by default)."""
    text = layout.title
    width = max(width, len(text))
    left = (width - len(text)) // 2
    key, rest = text.split(' ', 1)
    label = ' ' * left + f'{BOLD}{accent}{key}{RESET} {rest}' + ' ' * (width - len(text) - left)
    return label + (f' {DIM}({layout.note}){RESET}' if layout.note else '')


def render(cols, accent=FALLBACK_ACCENT):
    """Popup content: the previews in one row and the halves below, or a plain list when the popup is too narrow."""
    pad = ' ' * MARGIN
    hint = f'{pad}{DIM}{HINT}{RESET}'
    if cols < ROW_WIDTH:
        return [''] + [pad + styled_title(layout, accent) for layout in PREVIEWED + HALVES] + ['', hint]

    sep = ' ' * GAP
    boxes = [preview(layout, accent) for layout in PREVIEWED]
    lines = ['', pad + sep.join(styled_title(layout, accent, BOX_W) for layout in PREVIEWED)]
    lines += [pad + sep.join(box[i] for box in boxes) for i in range(len(boxes[0]))]
    halves = pad + sep.join(styled_title(layout, accent) for layout in HALVES)
    return lines + ['', halves, hint]


def herdr_result(herdr, *args):
    out = subprocess.run([herdr, *args], check=True, stdout=subprocess.PIPE, text=True).stdout
    return json.loads(out)['result'] if out.strip() else {}


def apply_layout(herdr, layout, target):
    """Split target the way layout says and focus the new pane; return its id."""
    cwd = herdr_result(herdr, 'pane', 'get', target)['pane'].get('cwd')
    if herdr_result(herdr, 'pane', 'layout', '--pane', target)['layout'].get('zoomed'):
        herdr_result(herdr, 'pane', 'zoom', target, '--off')

    # the original pane keeps the first (top/left) slot of the split
    ratio = layout.share if layout.new_first else 1 - layout.share
    args = ['pane', 'split', target, '--direction', layout.direction, '--ratio', f'{ratio:g}']
    if cwd:
        args += ['--cwd', cwd]
    args.append('--no-focus' if layout.new_first else '--focus')
    new = herdr_result(herdr, *args)['pane']['pane_id']

    if layout.new_first:
        herdr_result(herdr, 'pane', 'swap', '--source-pane', new, '--target-pane', target)
        towards_new = 'up' if layout.direction == 'down' else 'left'
        herdr_result(herdr, 'pane', 'focus', '--pane', target, '--direction', towards_new)
    return new


def pick(lines):
    """Show lines, then read single key presses (no enter) until one picks or cancels."""
    fd = sys.stdin.fileno()
    saved = termios.tcgetattr(fd)
    # TCSANOW keeps a key pressed while the popup was opening; the default
    # TCSAFLUSH would drop it. Clearing the screen wipes its echo.
    tty.setcbreak(fd, termios.TCSANOW)
    try:
        sys.stdout.write('\033[H\033[2J\033[?25l' + '\n'.join(lines))
        sys.stdout.flush()
        return choose(iter(lambda: os.read(fd, 1), b''))
    except KeyboardInterrupt:
        return None
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, saved)
        sys.stdout.write('\033[?25h')
        sys.stdout.flush()


def fail(message):
    print(f'\nkit: {message}', file=sys.stderr)
    try:
        input('press enter to close... ')
    except (KeyboardInterrupt, EOFError):
        pass
    return 1


def main():
    herdr = os.environ.get('HERDR_BIN_PATH', 'herdr')
    target = os.environ.get('KIT_SPLIT_PANE')
    if not target:
        return fail('no pane to split (KIT_SPLIT_PANE is unset)')

    accent = accent_style(read_accent())
    layout = pick(render(shutil.get_terminal_size().columns, accent))
    if layout is None:
        return 0

    try:
        apply_layout(herdr, layout, target)
    except subprocess.CalledProcessError as e:
        return fail(f'{" ".join(e.cmd[1:3])} failed (exit {e.returncode})')
    return 0


if __name__ == '__main__':
    sys.exit(main())
