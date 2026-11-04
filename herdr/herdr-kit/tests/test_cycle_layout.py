"""Behavior tests for cycle-layout.py (next_layout / previous_layout, tmux-style layout rotation).

Run: python3 herdr/herdr-kit/tests/test_cycle_layout.py
"""

import importlib.util
import sys
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location('cycle_layout', HERE.parent / 'cycle-layout.py')
cl = importlib.util.module_from_spec(_spec)
sys.modules[_spec.name] = cl
_spec.loader.exec_module(cl)

P = cl.pane
S = cl.split
TAB = 'w1:t1'
AREA = (120, 40)


def ids(n):
    return ['w1:p%d' % i for i in range(1, n + 1)]


def leaves(node):
    if node['type'] == 'pane':
        return [node['pane_id']]
    return leaves(node['first']) + leaves(node['second'])


def side_by_side(*panes):
    return S('right', 1 / len(panes), P(panes[0]), side_by_side(*panes[1:])) if len(panes) > 1 else P(panes[0])


def stacked(*panes):
    return S('down', 1 / len(panes), P(panes[0]), stacked(*panes[1:])) if len(panes) > 1 else P(panes[0])


def name_of(root, step=1):
    picked = cl.next_layout(root, step)
    return picked and picked[0]


class TestPresets(unittest.TestCase):
    """The layouts follow tmux: even-horizontal, even-vertical, main-horizontal, main-vertical, tiled."""

    def layouts(self, n):
        return dict(cl.presets(ids(n)))

    def test_even_layouts_give_every_pane_the_same_share(self):
        a, b, c = ids(3)
        layouts = self.layouts(3)
        self.assertEqual(layouts['even-horizontal'], S('right', 1 / 3, P(a), S('right', 1 / 2, P(b), P(c))))
        self.assertEqual(layouts['even-vertical'], S('down', 1 / 3, P(a), S('down', 1 / 2, P(b), P(c))))

    def test_main_layouts_give_the_first_pane_half_and_share_the_rest(self):
        a, b, c = ids(3)
        layouts = self.layouts(3)
        self.assertEqual(layouts['main-horizontal'], S('down', 0.5, P(a), S('right', 0.5, P(b), P(c))))
        self.assertEqual(layouts['main-vertical'], S('right', 0.5, P(a), S('down', 0.5, P(b), P(c))))

    def test_tiled_fills_rows_like_tmux(self):
        a, b, c, d, e = ids(5)
        self.assertEqual(self.layouts(3)['tiled'], S('down', 0.5, S('right', 0.5, P(a), P(b)), P(c)))
        self.assertEqual(
            self.layouts(4)['tiled'],
            S('down', 0.5, S('right', 0.5, P(a), P(b)), S('right', 0.5, P(c), P(d))),
        )
        # 5 panes: tmux picks 3 rows of 2 columns, the last row has one pane
        self.assertEqual(
            self.layouts(5)['tiled'],
            S('down', 1 / 3, S('right', 0.5, P(a), P(b)), S('down', 0.5, S('right', 0.5, P(c), P(d)), P(e))),
        )

    def test_layouts_that_look_the_same_are_listed_once(self):
        # 2 panes: main-* and tiled draw the same picture as the even layouts
        self.assertEqual([name for name, _ in cl.presets(ids(2))], ['even-horizontal', 'even-vertical'])
        self.assertEqual(
            [name for name, _ in cl.presets(ids(3))],
            ['even-horizontal', 'even-vertical', 'main-horizontal', 'main-vertical', 'tiled'],
        )

    def test_pane_order_is_kept(self):
        panes = ['w1:p7', 'w1:p2', 'w1:p5', 'w1:p1']
        for name, tree in cl.presets(panes):
            self.assertEqual(leaves(tree), panes, name)


class TestNextLayout(unittest.TestCase):
    def test_two_panes_toggle_between_side_by_side_and_stacked(self):
        a, b = ids(2)
        self.assertEqual(cl.next_layout(side_by_side(a, b), 1), ('even-vertical', stacked(a, b)))
        self.assertEqual(cl.next_layout(stacked(a, b), 1), ('even-horizontal', side_by_side(a, b)))

    def test_resized_split_still_counts_as_its_layout(self):
        a, b = ids(2)
        self.assertEqual(name_of(S('right', 0.7, P(a), P(b))), 'even-vertical')

    def test_three_panes_cycle_through_all_layouts_and_wrap(self):
        root = side_by_side(*ids(3))
        seen = []
        for _ in range(5):
            name, root = cl.next_layout(root, 1)
            seen.append(name)
        self.assertEqual(seen, ['even-vertical', 'main-horizontal', 'main-vertical', 'tiled', 'even-horizontal'])

    def test_previous_goes_backwards(self):
        self.assertEqual(name_of(side_by_side(*ids(3)), -1), 'tiled')
        self.assertEqual(name_of(side_by_side(*ids(2)), -1), 'even-vertical')

    def test_columns_split_in_any_order_count_as_even_horizontal(self):
        # [a | b] split again on the left keeps three columns, nested the other way
        a, b, c = ids(3)
        root = S('right', 2 / 3, S('right', 0.5, P(a), P(b)), P(c))
        self.assertEqual(name_of(root), 'even-vertical')

    def test_unknown_layout_starts_from_the_first_or_last(self):
        a, b, c, d = ids(4)
        root = S('right', 0.5, P(a), S('down', 0.5, P(b), S('right', 0.5, P(c), P(d))))
        self.assertEqual(name_of(root, 1), 'even-horizontal')
        self.assertEqual(name_of(root, -1), 'tiled')

    def test_single_pane_has_nothing_to_rotate(self):
        self.assertIsNone(cl.next_layout(P('w1:p1'), 1))


def rects(node, x, y, width, height):
    """Pane rects of a split tree; the first slot gets `ratio` of the space."""
    if node['type'] == 'pane':
        return [{'pane_id': node['pane_id'], 'rect': {'x': x, 'y': y, 'width': width, 'height': height}}]
    if node['direction'] == 'right':
        w = int(width * node['ratio'])
        return rects(node['first'], x, y, w, height) + rects(node['second'], x + w, y, width - w, height)
    h = int(height * node['ratio'])
    return rects(node['first'], x, y, width, h) + rects(node['second'], x, y + h, width, height - h)


def without(node, pane_id):
    """The tree with one pane taken out; its sibling fills the space. None when nothing is left."""
    if node['type'] == 'pane':
        return None if node['pane_id'] == pane_id else node
    first, second = without(node['first'], pane_id), without(node['second'], pane_id)
    if first is None or second is None:
        return first or second
    return dict(node, first=first, second=second)


def with_split(node, target, new_node):
    if node['type'] == 'pane':
        return new_node if node['pane_id'] == target else node
    return dict(
        node, first=with_split(node['first'], target, new_node), second=with_split(node['second'], target, new_node)
    )


class FakeHerdr:
    """A socket stand-in that keeps each tab's split tree and moves panes the way Herdr does:
    a move inside the same tab or into a zoomed tab changes nothing, a tab closes when its
    last pane leaves, and focus falls back to another pane when the focused one leaves."""

    def __init__(self, root, focused=None, zoomed=False):
        self.tabs = {TAB: root}
        self.focused = focused or leaves(root)[0]
        self.zoomed = zoomed
        self.calls = []
        self.labels = {}
        self.parked = []  # (pane count, smallest pane area) of the holding tab after each move into it
        self.created = 0

    def __call__(self, method, params):
        self.calls.append((method, params))
        return getattr(self, method.replace('.', '_'))(params)

    def tab_of(self, pane_id):
        return next(t for t, root in self.tabs.items() if pane_id in leaves(root))

    def layout_export(self, params):
        tab = self.tab_of(params['pane_id'])
        root = self.tabs[tab]
        focused = self.focused if self.focused in leaves(root) else leaves(root)[0]
        return {
            'layout': {
                'workspace_id': 'w1',
                'tab_id': tab,
                'zoomed': self.zoomed and tab == TAB,
                'focused_pane_id': focused,
                'root': root,
            }
        }

    def pane_zoom(self, params):
        assert params['mode'] == 'off', params
        self.zoomed = False
        return {}

    def pane_focus(self, params):
        self.focused = params['pane_id']
        return {}

    def take_out(self, pane_id):
        source = self.tab_of(pane_id)
        rest = without(self.tabs[source], pane_id)
        if rest is None:
            del self.tabs[source]
        else:
            self.tabs[source] = rest
        if self.focused == pane_id and rest is not None:
            self.focused = leaves(rest)[0]

    def unchanged(self, pane_id, reason):
        return {'move_result': {'changed': False, 'reason': reason, 'pane': {'pane_id': pane_id}}}

    def pane_move(self, params):
        pane_id, dest = params['pane_id'], params['destination']
        assert params['focus'] is False, params
        created = None
        if dest['type'] == 'new_tab':
            self.created += 1
            tab = 'w1:t%d' % (100 + self.created)
            self.take_out(pane_id)
            self.tabs[tab] = P(pane_id)
            self.labels[tab] = dest.get('label')
            created = {'tab_id': tab, 'label': dest.get('label')}
        else:
            tab = dest['tab_id']
            if tab == self.tab_of(pane_id):
                return self.unchanged(pane_id, 'same_tab')
            if tab == TAB and self.zoomed:
                return self.unchanged(pane_id, 'zoomed_tab')
            self.take_out(pane_id)
            target = dest['target_pane_id']
            self.tabs[tab] = with_split(self.tabs[tab], target, S(dest['split'], dest['ratio'], P(target), P(pane_id)))
        panes = rects(self.tabs[tab], 0, 0, *AREA)
        if tab != TAB:
            self.parked.append((len(panes), min(p['rect']['width'] * p['rect']['height'] for p in panes)))
        return {
            'move_result': {
                'changed': True,
                'pane': {'pane_id': pane_id, 'tab_id': tab},
                'created_tab': created,
                'target_layout': {'tab_id': tab, 'panes': panes},
            }
        }


class TestRun(unittest.TestCase):
    def run_on(self, root, step=1, **kwargs):
        fake = FakeHerdr(root, **kwargs)
        name = cl.run(fake, leaves(root)[0], step)
        return fake, name

    def test_two_panes_side_by_side_become_stacked_in_the_same_tab(self):
        a, b = ids(2)
        fake, name = self.run_on(side_by_side(a, b))
        self.assertEqual(name, 'even-vertical')
        self.assertEqual(fake.tabs, {TAB: stacked(a, b)})

    def test_every_layout_is_built_exactly_with_the_same_panes(self):
        for n in (3, 4, 5, 6):
            root = side_by_side(*ids(n))
            for _ in range(len(cl.presets(ids(n)))):
                expected = cl.next_layout(root, 1)[1]
                fake, _ = self.run_on(root)
                self.assertEqual(fake.tabs, {TAB: expected}, n)
                root = expected

    def test_the_holding_tab_is_labeled_and_closes_by_itself(self):
        fake, _ = self.run_on(side_by_side(*ids(4)))
        self.assertEqual(list(fake.labels.values()), [cl.HOLD_LABEL])
        self.assertEqual(list(fake.tabs), [TAB])

    def test_parked_panes_are_never_squeezed(self):
        # each park splits the largest pane, so none gets below half an even share
        fake, _ = self.run_on(side_by_side(*ids(8)))
        total = AREA[0] * AREA[1]
        self.assertEqual([count for count, _ in fake.parked], list(range(1, 8)))
        for count, smallest in fake.parked:
            self.assertGreaterEqual(smallest, total / (2 * count), fake.parked)

    def test_the_focused_pane_keeps_the_focus(self):
        a, b, c = ids(3)
        fake, _ = self.run_on(side_by_side(a, b, c), focused=b)
        self.assertEqual(fake.focused, b)

    def test_zoomed_tab_is_unzoomed_before_any_move(self):
        a, b = ids(2)
        fake, _ = self.run_on(side_by_side(a, b), zoomed=True)
        self.assertEqual(fake.calls[1], ('pane.zoom', {'pane_id': a, 'mode': 'off'}))
        self.assertEqual(fake.tabs, {TAB: stacked(a, b)})

    def test_previous_layout(self):
        a, b, c = ids(3)
        fake, name = self.run_on(side_by_side(a, b, c), step=-1)
        self.assertEqual(name, 'tiled')
        self.assertEqual(fake.tabs, {TAB: dict(cl.presets(ids(3)))['tiled']})

    def test_single_pane_is_left_alone(self):
        fake, name = self.run_on(P('w1:p1'))
        self.assertIsNone(name)
        self.assertEqual([m for m, _ in fake.calls], ['layout.export'])

    def test_a_move_that_changes_nothing_stops_the_run(self):
        a, b = ids(2)
        fake = FakeHerdr(side_by_side(a, b))
        fake.pane_move = lambda params: fake.unchanged(params['pane_id'], 'zoomed_tab')
        with self.assertRaises(RuntimeError):
            cl.run(fake, a, 1)


if __name__ == '__main__':
    unittest.main()
