#!/usr/bin/env python3
"""New-pane layout picker (runs inside a popup).

Draws an ASCII preview of four ways to split the pane the action was
invoked from and applies the one picked with a single key press, no
enter: 1 bottom, 2 top, 3 left, 4 right, the new pane taking 25%.
q, Esc or ctrl+c cancels.

`herdr pane split` only goes right or down, and --ratio is the share of
the first (top/left) slot. Top and left therefore split with the original
pane in the 25% slot, then swap the two panes: a swap exchanges the panes
but keeps the slot sizes.

A popup gets no HERDR_PANE_ID, so the opener passes the pane to split in
KIT_SPLIT_PANE.
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
import termios
import tty
from dataclasses import dataclass
from typing import Iterator, Optional

NEW_SHARE = 0.25

# preview box, borders excluded; terminal cells are about twice as tall as wide
INNER_W, INNER_H = 16, 7
BOX_W = INNER_W + 2
MARGIN, GAP = 2, 3
ROW_WIDTH = 2 * MARGIN + 4 * BOX_W + 3 * GAP

SHADE = '░'
HINT = 'press 1-4 to split the current pane · q / esc to cancel'

RESET = '\033[0m'
BORDER_STYLE = '\033[2m'
NEW_STYLE = '\033[38;2;236;72;153m'  # herdr ui.accent
KEY_STYLE = '\033[1;38;2;236;72;153m'
HINT_STYLE = '\033[2m'

CANCEL_KEYS = {b'q', b'\x1b', b'\x03'}


@dataclass(frozen=True)
class Layout:
    key: bytes
    name: str
    direction: str  # herdr split direction: "down" or "right"
    new_first: bool  # the new pane ends up on top / on the left

    @property
    def title(self):
        return f'{self.key.decode()} {self.name} {round(NEW_SHARE * 100)}%'


LAYOUTS = {
    layout.name: layout
    for layout in (
        Layout(b'1', 'bottom', 'down', False),
        Layout(b'2', 'top', 'down', True),
        Layout(b'3', 'left', 'right', True),
        Layout(b'4', 'right', 'right', False),
    )
}
BY_KEY = {layout.key: layout for layout in LAYOUTS.values()}


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


def preview(layout):
    """One preview box as styled lines, borders included; the new pane is shaded."""
    horizontal = layout.direction == 'down'  # the divider is a horizontal line
    size = INNER_H if horizontal else INNER_W
    new_size = round((size + 1) * NEW_SHARE)
    div = new_size if layout.new_first else size - new_size - 1
    new_span = range(0, div) if layout.new_first else range(div + 1, size)
    cur_span = range(div + 1, size) if layout.new_first else range(0, div)

    cells = []
    for r in range(INNER_H):
        row = []
        for c in range(INNER_W):
            pos = r if horizontal else c
            if pos == div:
                row.append(('─' if horizontal else '│', BORDER_STYLE))
            elif pos in new_span:
                row.append((SHADE, NEW_STYLE))
            else:
                row.append((' ', ''))
        cells.append(row)

    all_rows, all_cols = range(INNER_H), range(INNER_W)
    for span, text, style in ((new_span, 'new', NEW_STYLE), (cur_span, 'current', '')):
        rows, cols = (span, all_cols) if horizontal else (all_rows, span)
        put_label(cells, rows[len(rows) // 2], cols, text, style)

    top, bottom = ['─'] * INNER_W, ['─'] * INNER_W
    if not horizontal:
        top[div], bottom[div] = '┬', '┴'
    lines = [BORDER_STYLE + '┌' + ''.join(top) + '┐' + RESET]
    for r, row in enumerate(cells):
        left, right = ('├', '┤') if horizontal and r == div else ('│', '│')
        body = ''.join(f'{style}{ch}{RESET}' if style else ch for ch, style in row)
        lines.append(f'{BORDER_STYLE}{left}{RESET}{body}{BORDER_STYLE}{right}{RESET}')
    lines.append(BORDER_STYLE + '└' + ''.join(bottom) + '┘' + RESET)
    return lines


def styled_title(layout, width):
    """The layout title with the key highlighted, centered in width cells."""
    text = layout.title
    left = (width - len(text)) // 2
    key, rest = text.split(' ', 1)
    return ' ' * left + f'{KEY_STYLE}{key}{RESET} {rest}' + ' ' * (width - len(text) - left)


def render(cols):
    """Popup content: all previews in one row, or a plain list when the popup is too narrow."""
    pad = ' ' * MARGIN
    hint = f'{pad}{HINT_STYLE}{HINT}{RESET}'
    layouts = list(LAYOUTS.values())
    if cols < ROW_WIDTH:
        return [''] + [pad + styled_title(layout, len(layout.title)) for layout in layouts] + ['', hint]

    sep = ' ' * GAP
    boxes = [preview(layout) for layout in layouts]
    lines = ['', pad + sep.join(styled_title(layout, BOX_W) for layout in layouts)]
    lines += [pad + sep.join(box[i] for box in boxes) for i in range(len(boxes[0]))]
    return lines + ['', hint]


def herdr_result(herdr, *args):
    out = subprocess.run([herdr, *args], check=True, stdout=subprocess.PIPE, text=True).stdout
    return json.loads(out)['result'] if out.strip() else {}


def apply_layout(herdr, layout, target):
    """Split target the way layout says and focus the new pane; return its id."""
    cwd = herdr_result(herdr, 'pane', 'get', target)['pane'].get('cwd')
    if herdr_result(herdr, 'pane', 'layout', '--pane', target)['layout'].get('zoomed'):
        herdr_result(herdr, 'pane', 'zoom', target, '--off')

    # the original pane keeps the first (top/left) slot of the split
    ratio = NEW_SHARE if layout.new_first else 1 - NEW_SHARE
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

    layout = pick(render(shutil.get_terminal_size().columns))
    if layout is None:
        return 0

    try:
        apply_layout(herdr, layout, target)
    except subprocess.CalledProcessError as e:
        return fail(f'{" ".join(e.cmd[1:3])} failed (exit {e.returncode})')
    return 0


if __name__ == '__main__':
    sys.exit(main())
