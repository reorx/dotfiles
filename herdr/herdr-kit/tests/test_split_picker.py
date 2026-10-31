"""Behavior tests for split-picker.py (pick_split, new-pane layout popup).

Run: python3 herdr/herdr-kit/tests/test_split_picker.py
"""

import importlib.util
import os
import re
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

HERE = Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location('split_picker', HERE.parent / 'split-picker.py')
sp = importlib.util.module_from_spec(_spec)
sys.modules[_spec.name] = sp
_spec.loader.exec_module(sp)

ANSI = re.compile(r'\x1b\[[0-9;]*m')

SIDES = ('top', 'right', 'bottom', 'left')
SHARES = (0.25, 0.5, 0.75)
BACKSPACE = b'\x7f'


def plain(text):
    return ANSI.sub('', text)


def inner(box):
    """The cells inside a preview's border, as a list of strings."""
    return [line[1:-1] for line in box[1:-1]]


def popup_inner_size():
    """The split_picker popup's inner area (cols, rows) from the manifest: the frame takes 3 columns and 2 rows."""
    manifest = (HERE.parent / 'herdr-plugin.toml').read_text()
    block = next(b for b in manifest.split('[[panes]]') if 'id = "split_picker"' in b)
    width = int(re.search(r'^width = (\d+)', block, re.M).group(1))
    height = int(re.search(r'^height = (\d+)', block, re.M).group(1))
    return width - 3, height - 2


class TestChoose(unittest.TestCase):
    def choose(self, *keys):
        return sp.choose(iter(keys))

    def test_side_then_size_picks_a_layout_without_enter(self):
        sides = {b'1': 'top', b'2': 'right', b'3': 'bottom', b'4': 'left'}
        sizes = {b'1': 0.25, b'2': 0.5, b'3': 0.75}
        for side_key, side in sides.items():
            for size_key, share in sizes.items():
                self.assertEqual(self.choose(side_key, size_key), sp.Layout(side, share))

    def test_space_picks_half(self):
        for side_key, side in ((b'1', 'top'), (b'4', 'left')):
            self.assertEqual(self.choose(side_key, b' '), sp.Layout(side, 0.5))

    def test_size_keys_do_nothing_before_a_side_is_picked(self):
        # space is not a side; 1 first picks the side, the second 1 the size
        self.assertEqual(self.choose(b' ', b'1', b'1'), sp.Layout('top', 0.25))

    def test_cancel_keys_in_either_step(self):
        for key in (b'q', b'\x1b', b'\x03'):
            self.assertIsNone(self.choose(key, b'1', b'1'))
            self.assertIsNone(self.choose(b'1', key, b'1'))

    def test_backspace_goes_back_to_the_side_step(self):
        self.assertEqual(self.choose(b'1', BACKSPACE, b'3', b'1'), sp.Layout('bottom', 0.25))
        self.assertEqual(self.choose(b'2', b'\x08', b'4', b'3'), sp.Layout('left', 0.75))

    def test_backspace_in_the_side_step_is_ignored(self):
        self.assertEqual(self.choose(BACKSPACE, b'2', b' '), sp.Layout('right', 0.5))

    def test_other_keys_are_ignored(self):
        # 5 is no side; 4 is no size once the side is picked
        self.assertEqual(self.choose(b'x', b'5', b'\r', b'3', b'4', b'x', b'3'), sp.Layout('bottom', 0.75))

    def test_end_of_input_cancels(self):
        self.assertIsNone(self.choose(b'x'))
        self.assertIsNone(self.choose(b'1'))

    def test_every_step_change_is_reported(self):
        steps = []
        sp.choose(iter([b'x', b'3', b'x', BACKSPACE, b'2', b'1']), steps.append)
        self.assertEqual(steps, ['bottom', None, 'right'])


class TestLayout(unittest.TestCase):
    def test_split_direction_follows_the_side(self):
        for side, direction, new_first in (('top', 'down', True), ('bottom', 'down', False),
                                           ('left', 'right', True), ('right', 'right', False)):
            layout = sp.Layout(side, 0.25)
            self.assertEqual((layout.direction, layout.new_first), (direction, new_first))


class TestPreview(unittest.TestCase):
    def box(self, side, share):
        return [plain(line) for line in sp.preview(sp.Layout(side, share))]

    def shaded(self, side, share):
        """Rows (top/bottom) or columns (left/right) shaded as the new pane."""
        rows = inner(self.box(side, share))
        if side in ('top', 'bottom'):
            return [i for i, row in enumerate(rows) if sp.SHADE in row]
        return sorted({i for row in rows for i, ch in enumerate(row) if ch == sp.SHADE})

    def extent(self, side):
        rows = inner(self.box(side, 0.5))
        return len(rows) if side in ('top', 'bottom') else len(rows[0])

    def test_every_preview_has_the_same_size(self):
        boxes = [self.box(side, share) for side in SIDES for share in SHARES]
        self.assertEqual(len({(len(b), len(b[0])) for b in boxes}), 1)
        for box in boxes:
            self.assertEqual({len(line) for line in box}, {len(box[0])})

    def test_the_new_pane_is_shaded_on_its_side(self):
        for share in SHARES:
            for side in SIDES:
                cells = self.shaded(side, share)
                size = self.extent(side)
                if side in ('top', 'left'):
                    self.assertEqual(cells, list(range(len(cells))), (side, share))
                else:
                    self.assertEqual(cells, list(range(size - len(cells), size)), (side, share))

    def test_the_shaded_share_follows_the_size(self):
        for side in SIDES:
            counts = [len(self.shaded(side, share)) for share in SHARES]
            self.assertEqual(counts, sorted(set(counts)), side)
            # with the divider taken out, 25% and 75% mirror each other and 50% is an even split
            panes = self.extent(side) - 1
            self.assertEqual(counts[0] + counts[2], panes, side)
            self.assertEqual(2 * counts[1], panes, side)

    def test_divider_joins_the_border(self):
        for share in SHARES:
            for side in ('top', 'bottom'):
                box = self.box(side, share)
                self.assertIn('├', ''.join(l[0] for l in box))
                self.assertIn('┤', ''.join(l[-1] for l in box))
            for side in ('left', 'right'):
                box = self.box(side, share)
                self.assertIn('┬', box[0])
                self.assertIn('┴', box[-1])

    def test_each_label_stays_inside_its_own_pane(self):
        for side in SIDES:
            for share in SHARES:
                rows = inner(self.box(side, share))
                new_cells = set(self.shaded(side, share))
                found = {}
                for r, row in enumerate(rows):
                    for label in ('new', 'cur'):
                        c = row.find(label)
                        if c >= 0:
                            span = range(c, c + len(label)) if side in ('left', 'right') else [r]
                            found[label] = all(i in new_cells for i in span), all(i not in new_cells for i in span)
                self.assertEqual(found.get('new'), (True, False), (side, share))
                self.assertEqual(found.get('cur'), (False, True), (side, share))


class TestRender(unittest.TestCase):
    def lines(self, cols, side=None):
        return [plain(l) for l in sp.render(cols, side=side)]

    def test_side_step_previews_the_four_sides_in_key_order(self):
        lines = self.lines(200)
        labels = next(l for l in lines if '1 top' in l)
        positions = [labels.index(t) for t in ('1 top', '2 right', '3 bottom', '4 left')]
        self.assertEqual(positions, sorted(positions))
        self.assertEqual(max(l.count('┌') for l in lines), 4)
        self.assertIn('1-4', lines[-1])

    def test_size_step_previews_three_sizes_of_the_picked_side(self):
        lines = self.lines(200, 'bottom')
        labels = next(l for l in lines if '1 bottom 25%' in l)
        positions = [labels.index(t) for t in ('1 bottom 25%', '2 bottom 50%', '3 bottom 75%')]
        self.assertEqual(positions, sorted(positions))
        self.assertEqual(max(l.count('┌') for l in lines), 3)
        for word in ('space', 'backspace'):
            self.assertIn(word, lines[-1])

    def test_lines_fit_the_popup(self):
        cols, rows = popup_inner_size()
        self.assertGreaterEqual(cols, sp.ROW_WIDTH)
        for side in (None,) + SIDES:
            lines = sp.render(cols, side=side)
            self.assertTrue(any('┌' in l for l in lines), side)
            self.assertLessEqual(len(lines), rows, side)
            for line in lines:
                self.assertLessEqual(len(plain(line)), sp.ROW_WIDTH, side)

    def test_narrow_popup_falls_back_to_a_text_list(self):
        narrow = sp.ROW_WIDTH - 1
        for side, labels in ((None, ('1 top', '2 right', '3 bottom', '4 left')),
                             ('left', ('1 left 25%', '2 left 50%', '3 left 75%'))):
            lines = self.lines(narrow, side)
            for label in labels:
                self.assertTrue(any(label in l for l in lines), label)
            self.assertFalse(any('┌' in l for l in lines))
            for line in lines:
                self.assertLess(len(line), sp.ROW_WIDTH)


class TestAccent(unittest.TestCase):
    def config(self, text):
        f = tempfile.NamedTemporaryFile('w', suffix='.toml', delete=False)
        f.write(text)
        f.close()
        self.addCleanup(os.unlink, f.name)
        return f.name

    def test_hex_and_rgb_colors_become_truecolor(self):
        self.assertEqual(sp.accent_style('#ec4899'), '\033[38;2;236;72;153m')
        self.assertEqual(sp.accent_style('rgb(234, 183, 72)'), '\033[38;2;234;183;72m')

    def test_unknown_or_missing_color_falls_back(self):
        self.assertEqual(sp.accent_style('mauve'), sp.FALLBACK_ACCENT)
        self.assertEqual(sp.accent_style(None), sp.FALLBACK_ACCENT)

    def test_reads_ui_accent_from_the_active_config(self):
        path = self.config(
            '[theme]\naccent = "#000000"\n\n[ui]\nshow_agent_labels_on_pane_borders = true\n'
            'accent = "rgb(234, 183, 72)"\n\n[[keys.command]]\naccent = "#ffffff"\n'
        )
        with mock.patch.dict(os.environ, {'HERDR_CONFIG_PATH': path}):
            self.assertEqual(sp.read_accent(), 'rgb(234, 183, 72)')

    def test_no_config_or_no_accent(self):
        with mock.patch.dict(os.environ, {'HERDR_CONFIG_PATH': '/nonexistent/config.toml'}):
            self.assertIsNone(sp.read_accent())
        with mock.patch.dict(os.environ, {'HERDR_CONFIG_PATH': self.config('[ui]\nfoo = 1\n')}):
            self.assertIsNone(sp.read_accent())

    def test_render_paints_with_the_accent(self):
        accent = sp.accent_style('#010203')
        for width in (200, 40):
            for side in (None, 'top'):
                self.assertIn(accent, '\n'.join(sp.render(width, accent, side)))


class FakeHerdr:
    """Records herdr calls and answers the ones whose result is read."""

    def __init__(self, zoomed=False):
        self.calls = []
        self.zoomed = zoomed

    def __call__(self, herdr, *args):
        self.calls.append(list(args))
        if args[:2] == ('pane', 'get'):
            return {'pane': {'pane_id': args[2], 'cwd': '/work/proj'}}
        if args[:2] == ('pane', 'layout'):
            return {'layout': {'zoomed': self.zoomed}}
        if args[:2] == ('pane', 'split'):
            return {'pane': {'pane_id': 'w1:p9'}}
        return {}

    def mutations(self):
        return [c for c in self.calls if c[:2] not in (['pane', 'get'], ['pane', 'layout'])]


class TestApplyLayout(unittest.TestCase):
    def apply(self, side, share, zoomed=False):
        fake = FakeHerdr(zoomed)
        with mock.patch.object(sp, 'herdr_result', fake):
            new = sp.apply_layout('herdr', sp.Layout(side, share), 'w1:p1')
        self.assertEqual(new, 'w1:p9')
        return fake.mutations()

    def split(self, direction, ratio, focus):
        return ['pane', 'split', 'w1:p1', '--direction', direction, '--ratio', ratio, '--cwd', '/work/proj', focus]

    def swap_and_focus(self, towards):
        return [
            ['pane', 'swap', '--source-pane', 'w1:p9', '--target-pane', 'w1:p1'],
            ['pane', 'focus', '--pane', 'w1:p1', '--direction', towards],
        ]

    def test_bottom_and_right_split_once_and_focus_the_new_pane(self):
        # the original pane keeps the first slot, so its ratio is what the new pane leaves
        for side, direction in (('bottom', 'down'), ('right', 'right')):
            for share, ratio in ((0.25, '0.75'), (0.5, '0.5'), (0.75, '0.25')):
                self.assertEqual(self.apply(side, share), [self.split(direction, ratio, '--focus')], (side, share))

    def test_top_puts_the_new_pane_above_and_focuses_it(self):
        for share, ratio in ((0.25, '0.25'), (0.5, '0.5'), (0.75, '0.75')):
            self.assertEqual(
                self.apply('top', share),
                [self.split('down', ratio, '--no-focus')] + self.swap_and_focus('up'),
                share,
            )

    def test_left_puts_the_new_pane_on_the_left_and_focuses_it(self):
        for share, ratio in ((0.25, '0.25'), (0.75, '0.75')):
            self.assertEqual(
                self.apply('left', share),
                [self.split('right', ratio, '--no-focus')] + self.swap_and_focus('left'),
                share,
            )

    def test_zoomed_pane_is_unzoomed_first(self):
        calls = self.apply('bottom', 0.25, zoomed=True)
        self.assertEqual(calls[0], ['pane', 'zoom', 'w1:p1', '--off'])
        self.assertEqual(calls[1][:2], ['pane', 'split'])


if __name__ == '__main__':
    unittest.main()
