"""Behavior tests for split-picker.py (pick_split, new-pane layout popup).

Run: python3 herdr/herdr-kit/tests/test_split_picker.py
"""

import importlib.util
import re
import sys
import unittest
from pathlib import Path
from unittest import mock

HERE = Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location('split_picker', HERE.parent / 'split-picker.py')
sp = importlib.util.module_from_spec(_spec)
sys.modules[_spec.name] = sp
_spec.loader.exec_module(sp)

ANSI = re.compile(r'\x1b\[[0-9;]*m')


def plain(text):
    return ANSI.sub('', text)


def inner(box):
    """The cells inside a preview's border, as a list of strings."""
    return [line[1:-1] for line in box[1:-1]]


class TestChoose(unittest.TestCase):
    def test_digit_keys_pick_a_layout_without_enter(self):
        for key, name in ((b'1', 'bottom'), (b'2', 'top'), (b'3', 'left'), (b'4', 'right')):
            self.assertEqual(sp.choose(iter([key])).name, name)

    def test_cancel_keys(self):
        for key in (b'q', b'\x1b', b'\x03'):
            self.assertIsNone(sp.choose(iter([key, b'1'])))

    def test_other_keys_are_ignored(self):
        self.assertEqual(sp.choose(iter([b'x', b'5', b'\r', b'3'])).name, 'left')

    def test_end_of_input_cancels(self):
        self.assertIsNone(sp.choose(iter([b'x'])))


class TestPreview(unittest.TestCase):
    def box(self, name):
        return [plain(line) for line in sp.preview(sp.LAYOUTS[name])]

    def shaded_rows(self, name):
        return [i for i, row in enumerate(inner(self.box(name))) if sp.SHADE in row]

    def shaded_cols(self, name):
        rows = inner(self.box(name))
        return sorted({i for row in rows for i, ch in enumerate(row) if ch == sp.SHADE})

    def test_every_preview_has_the_same_size(self):
        sizes = {(len(b), len(b[0])) for b in (self.box(n) for n in sp.LAYOUTS)}
        self.assertEqual(len(sizes), 1)
        for name in sp.LAYOUTS:
            self.assertEqual({len(line) for line in self.box(name)}, {len(self.box(name)[0])})

    def test_bottom_shades_the_last_rows(self):
        rows = self.shaded_rows('bottom')
        height = len(inner(self.box('bottom')))
        self.assertEqual(rows, list(range(height - len(rows), height)))
        self.assertLessEqual(len(rows), height // 3)

    def test_top_shades_the_first_rows(self):
        rows = self.shaded_rows('top')
        self.assertEqual(rows, list(range(len(rows))))
        self.assertLessEqual(len(rows), len(inner(self.box('top'))) // 3)

    def test_left_shades_the_first_cols(self):
        cols = self.shaded_cols('left')
        self.assertEqual(cols, list(range(len(cols))))
        self.assertLessEqual(len(cols), len(inner(self.box('left'))[0]) // 3)

    def test_right_shades_the_last_cols(self):
        cols = self.shaded_cols('right')
        width = len(inner(self.box('right'))[0])
        self.assertEqual(cols, list(range(width - len(cols), width)))
        self.assertLessEqual(len(cols), width // 3)

    def test_divider_joins_the_border(self):
        for name in ('bottom', 'top'):
            box = self.box(name)
            self.assertIn('├', ''.join(l[0] for l in box))
            self.assertIn('┤', ''.join(l[-1] for l in box))
        self.assertIn('┬', self.box('left')[0])
        self.assertIn('┴', self.box('right')[-1])

    def test_panes_are_labelled(self):
        for name in sp.LAYOUTS:
            text = '\n'.join(self.box(name))
            self.assertIn('new', text)
            self.assertIn('current', text)


class TestRender(unittest.TestCase):
    def test_wide_popup_shows_previews_in_key_order(self):
        lines = [plain(l) for l in sp.render(200)]
        labels = next(l for l in lines if '1 bottom' in l)
        positions = [labels.index(t) for t in ('1 bottom 25%', '2 top 25%', '3 left 25%', '4 right 25%')]
        self.assertEqual(positions, sorted(positions))
        self.assertTrue(any(l.count('┌') == 4 for l in lines))

    def test_lines_fit_the_popup(self):
        width = sp.ROW_WIDTH
        for line in sp.render(width):
            self.assertLessEqual(len(plain(line)), width)

    def test_narrow_popup_falls_back_to_a_text_list(self):
        lines = [plain(l) for l in sp.render(sp.ROW_WIDTH - 1)]
        for label in ('1 bottom 25%', '2 top 25%', '3 left 25%', '4 right 25%'):
            self.assertTrue(any(label in l for l in lines))
        self.assertFalse(any('┌' in l for l in lines))
        for line in lines:
            self.assertLess(len(line), sp.ROW_WIDTH)


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
    def apply(self, name, zoomed=False):
        fake = FakeHerdr(zoomed)
        with mock.patch.object(sp, 'herdr_result', fake):
            new = sp.apply_layout('herdr', sp.LAYOUTS[name], 'w1:p1')
        self.assertEqual(new, 'w1:p9')
        return fake.mutations()

    def split(self, direction, ratio, focus):
        return ['pane', 'split', 'w1:p1', '--direction', direction, '--ratio', ratio, '--cwd', '/work/proj', focus]

    def test_bottom_splits_down_and_focuses_the_new_pane(self):
        self.assertEqual(self.apply('bottom'), [self.split('down', '0.75', '--focus')])

    def test_right_splits_right_and_focuses_the_new_pane(self):
        self.assertEqual(self.apply('right'), [self.split('right', '0.75', '--focus')])

    def test_top_puts_the_new_pane_above_and_focuses_it(self):
        self.assertEqual(
            self.apply('top'),
            [
                self.split('down', '0.25', '--no-focus'),
                ['pane', 'swap', '--source-pane', 'w1:p9', '--target-pane', 'w1:p1'],
                ['pane', 'focus', '--pane', 'w1:p1', '--direction', 'up'],
            ],
        )

    def test_left_puts_the_new_pane_on_the_left_and_focuses_it(self):
        self.assertEqual(
            self.apply('left'),
            [
                self.split('right', '0.25', '--no-focus'),
                ['pane', 'swap', '--source-pane', 'w1:p9', '--target-pane', 'w1:p1'],
                ['pane', 'focus', '--pane', 'w1:p1', '--direction', 'left'],
            ],
        )

    def test_zoomed_pane_is_unzoomed_first(self):
        calls = self.apply('bottom', zoomed=True)
        self.assertEqual(calls[0], ['pane', 'zoom', 'w1:p1', '--off'])
        self.assertEqual(calls[1][:2], ['pane', 'split'])


if __name__ == '__main__':
    unittest.main()
