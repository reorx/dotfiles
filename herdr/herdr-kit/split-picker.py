#!/usr/bin/env python3
"""New-pane layout picker (runs inside a popup).

Two single key presses, no enter, pick where the new pane goes and how
much of the current pane it takes:

1. the side: 1 top, 2 right, 3 bottom, 4 left (clockwise from the top)
2. the size: 1 25%, 2 50%, 3 75%, or space for 50%; backspace goes back

Each step draws an ASCII preview of its choices. q, Esc or ctrl+c cancels.

`herdr pane split` only goes right or down, and --ratio is the share of
the first (top/left) slot. Top and left therefore split with the original
pane in a slot of the new pane's size, then swap the two panes: a swap
exchanges the panes but keeps the slot sizes.

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
from typing import Callable, Iterator, Optional

QUARTER, HALF, THREE_QUARTERS = 0.25, 0.5, 0.75

SIDE_KEYS = {b'1': 'top', b'2': 'right', b'3': 'bottom', b'4': 'left'}
SIZES = {b'1': QUARTER, b'2': HALF, b'3': THREE_QUARTERS}  # previewed in this order
SIZE_KEYS = {**SIZES, b' ': HALF}
CANCEL_KEYS = {b'q', b'\x1b', b'\x03'}
BACK_KEYS = {b'\x7f', b'\x08'}

# preview box, borders excluded; terminal cells are about twice as tall as wide.
# The divider takes one cell, the rest (14 wide, 6 high) halves evenly.
INNER_W, INNER_H = 15, 7
BOX_W = INNER_W + 2
MARGIN, GAP = 2, 3
ROW_WIDTH = 2 * MARGIN + 4 * BOX_W + 3 * GAP

SHADE = '░'
SIDE_HINT = 'press 1-4 to pick the side of the new pane · q / esc to cancel'
SIZE_HINT = 'press 1-3, or space for 50% · backspace to go back · q / esc to cancel'

RESET = '\033[0m'
BOLD = '\033[1m'
DIM = '\033[2m'
FALLBACK_ACCENT = '\033[35m'


@dataclass(frozen=True)
class Layout:
    side: str  # where the new pane goes: top, right, bottom or left
    share: float  # the new pane's share of the split pane

    @property
    def direction(self):
        """The herdr split direction: "down" stacks the panes, "right" puts them side by side."""
        return 'down' if self.side in ('top', 'bottom') else 'right'

    @property
    def new_first(self):
        """The new pane ends up in the first (top/left) slot."""
        return self.side in ('top', 'left')


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


def choose(keys: Iterator[bytes], on_step: Callable[[Optional[str]], None] = lambda side: None) -> Optional[Layout]:
    """Read a side key, then a size key, and return the layout; None when a key cancels or input ends.

    on_step gets the picked side when the size step starts, and None when
    backspace returns to the side step.
    """
    side = None
    for key in keys:
        if key in CANCEL_KEYS:
            return None
        if side is None:
            if key in SIDE_KEYS:
                side = SIDE_KEYS[key]
                on_step(side)
        elif key in BACK_KEYS:
            side = None
            on_step(None)
        elif key in SIZE_KEYS:
            return Layout(side, SIZE_KEYS[key])
    return None


def put_label(cells, row, cols, names, style):
    """Center the first of names that fits in cols of row; it gets a blank cell on each side so it stands out of the shade."""
    text = next((name for name in names if len(name) <= len(cols)), names[-1][: len(cols)])
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
    new_size = round((size - 1) * layout.share)  # the divider takes one cell
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
    for span, names, style in ((new_span, ('new',), accent), (cur_span, ('current', 'cur'), '')):
        rows, cols = (span, all_cols) if horizontal else (all_rows, span)
        put_label(cells, rows[len(rows) // 2], cols, names, style)

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


def choices(side=None):
    """(key, title, layout) of each choice in a step: the four sides at 50%, or the three sizes of side."""
    if side is None:
        return [(key.decode(), name, Layout(name, HALF)) for key, name in SIDE_KEYS.items()]
    return [(key.decode(), f'{side} {round(share * 100)}%', Layout(side, share)) for key, share in SIZES.items()]


def styled_title(key, title, accent, width=0):
    """`key title` with the key highlighted, centered in width cells (no padding by default)."""
    text = f'{key} {title}'
    width = max(width, len(text))
    left = (width - len(text)) // 2
    return ' ' * left + f'{BOLD}{accent}{key}{RESET} {title}' + ' ' * (width - len(text) - left)


def render(cols, accent=FALLBACK_ACCENT, side=None):
    """Popup content for a step: the side step when side is None, else the size step of side.

    The choices are previewed in one row, or listed as plain text when the popup is too narrow.
    """
    pad = ' ' * MARGIN
    hint = f'{pad}{DIM}{SIDE_HINT if side is None else SIZE_HINT}{RESET}'
    options = choices(side)
    if cols < ROW_WIDTH:
        return [''] + [pad + styled_title(key, title, accent) for key, title, _ in options] + ['', hint]

    sep = ' ' * GAP
    boxes = [preview(layout, accent) for _, _, layout in options]
    lines = ['', pad + sep.join(styled_title(key, title, accent, BOX_W) for key, title, _ in options)]
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


def show(lines):
    sys.stdout.write('\033[H\033[2J' + '\n'.join(lines))
    sys.stdout.flush()


def pick(draw):
    """Draw the side step, then read single key presses (no enter) until a layout is picked or cancelled.

    draw(side) redraws the popup for a step (side None is the side step).
    """
    fd = sys.stdin.fileno()
    saved = termios.tcgetattr(fd)
    # TCSANOW keeps keys pressed while the popup was opening; the default
    # TCSAFLUSH would drop them. Clearing the screen wipes their echo.
    tty.setcbreak(fd, termios.TCSANOW)
    try:
        sys.stdout.write('\033[?25l')
        draw(None)
        return choose(iter(lambda: os.read(fd, 1), b''), draw)
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
    cols = shutil.get_terminal_size().columns
    layout = pick(lambda side: show(render(cols, accent, side)))
    if layout is None:
        return 0

    try:
        apply_layout(herdr, layout, target)
    except subprocess.CalledProcessError as e:
        return fail(f'{" ".join(e.cmd[1:3])} failed (exit {e.returncode})')
    return 0


if __name__ == '__main__':
    sys.exit(main())
