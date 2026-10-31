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

    def test_v_and_h_pick_the_half_splits(self):
        self.assertEqual(sp.choose(iter([b'v'])).name, 'vertical')
        self.assertEqual(sp.choose(iter([b'h'])).name, 'horizontal')

    def test_other_keys_are_ignored(self):
        self.assertEqual(sp.choose(iter([b'x', b'5', b'\r', b'3'])).name, 'left')

    def test_end_of_input_cancels(self):
        self.assertIsNone(sp.choose(iter([b'x'])))


class TestPreview(unittest.TestCase):
    QUARTERS = ('bottom', 'top', 'left', 'right')

    def box(self, name):
        return [plain(line) for line in sp.preview(sp.LAYOUTS[name])]

    def shaded_rows(self, name):
        return [i for i, row in enumerate(inner(self.box(name))) if sp.SHADE in row]

    def shaded_cols(self, name):
        rows = inner(self.box(name))
        return sorted({i for row in rows for i, ch in enumerate(row) if ch == sp.SHADE})

    def test_every_preview_has_the_same_size(self):
        sizes = {(len(b), len(b[0])) for b in (self.box(n) for n in self.QUARTERS)}
        self.assertEqual(len(sizes), 1)
        for name in self.QUARTERS:
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
        for name in self.QUARTERS:
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

    def test_half_splits_are_explained_in_one_line_below_the_previews(self):
        lines = [plain(l) for l in sp.render(200)]
        last_box = max(i for i, l in enumerate(lines) if '└' in l)
        below = [i for i, l in enumerate(lines) if 'v vertical 50%' in l and 'h horizontal 50%' in l]
        self.assertEqual(len(below), 1)
        self.assertGreater(below[0], last_box)
        self.assertIn('side by side', lines[below[0]])
        self.assertIn('stacked', lines[below[0]])
        # still only the four 25% previews are drawn
        self.assertEqual(max(l.count('┌') for l in lines), 4)

    def test_lines_fit_the_popup(self):
        width = sp.ROW_WIDTH
        for line in sp.render(width):
            self.assertLessEqual(len(plain(line)), width)

    def test_narrow_popup_falls_back_to_a_text_list(self):
        lines = [plain(l) for l in sp.render(sp.ROW_WIDTH - 1)]
        for label in ('1 bottom 25%', '2 top 25%', '3 left 25%', '4 right 25%', 'v vertical 50%', 'h horizontal 50%'):
            self.assertTrue(any(label in l for l in lines))
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
            self.assertIn(accent, '\n'.join(sp.render(width, accent)))


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

    def test_vertical_splits_side_by_side_in_half(self):
        self.assertEqual(self.apply('vertical'), [self.split('right', '0.5', '--focus')])

    def test_horizontal_stacks_in_half(self):
        self.assertEqual(self.apply('horizontal'), [self.split('down', '0.5', '--focus')])

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
