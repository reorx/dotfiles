"""Behavior tests for workspace-picker.py (pick_workspace, get-or-create).

Run: python3 herdr/herdr-navigate-line/tests/test_workspace_picker.py
"""

import importlib.util
import os
import re
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

# The file name has a dash, so load it by path; dataclasses need the module
# registered in sys.modules before it runs.
HERE = Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location('workspace_picker', HERE.parent / 'workspace-picker.py')
wp = importlib.util.module_from_spec(_spec)
sys.modules[_spec.name] = wp
_spec.loader.exec_module(wp)

ANSI = re.compile(r'\x1b\[[0-9;]*m')


def ws(workspace_id, number, label, focused=False, status='unknown', checkout=None):
    w = {
        'workspace_id': workspace_id,
        'number': number,
        'label': label,
        'focused': focused,
        'agent_status': status,
    }
    if checkout:
        w['worktree'] = {'checkout_path': checkout, 'is_linked_worktree': False}
    return w


def pane(workspace_id, cwd):
    return {'workspace_id': workspace_id, 'cwd': cwd}


def plain(text):
    return ANSI.sub('', text)


class BaseDirCase(unittest.TestCase):
    """A fake ~/Code with a few project dirs.

    The tmp path is used as-is for `base`, while pane cwds use its
    realpath: on macOS /var is a symlink to /private/var, the same way a
    symlinked project dir shows up physically in Herdr's pane cwd.
    """

    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.base = self._tmp.name
        self.real = os.path.realpath(self.base)
        for name in ('alpha', 'beta', 'condenser', 'condenser/ios', 'dotfiles/herdr', 'zeta', '.hidden'):
            os.makedirs(os.path.join(self.base, name))
        Path(self.base, 'notes.txt').write_text('not a dir')

    def tearDown(self):
        self._tmp.cleanup()

    def d(self, name):
        return os.path.join(self.base, name)

    def r(self, name):
        return os.path.join(self.real, name)


class TestWorkspaceRoot(unittest.TestCase):
    def test_prefers_worktree_checkout_path(self):
        w = ws('w1', 1, 'app', checkout='/code/app')
        panes = [pane('w1', '/code/app/src'), pane('w1', '/code/app/src')]
        self.assertEqual(wp.workspace_root(w, panes), '/code/app')

    def test_uses_most_common_pane_cwd(self):
        w = ws('w1', 1, 'feishu')
        panes = [
            pane('w1', '/code/devblocks'),
            pane('w1', '/code/feishu'),
            pane('w1', '/code/feishu'),
            pane('w2', '/code/other'),
        ]
        self.assertEqual(wp.workspace_root(w, panes), '/code/feishu')

    def test_pane_cwd_tie_goes_to_first_pane(self):
        w = ws('w1', 1, 'x')
        panes = [pane('w1', '/code/b'), pane('w1', '/code/a')]
        self.assertEqual(wp.workspace_root(w, panes), '/code/b')

    def test_no_panes_and_no_worktree_has_no_root(self):
        self.assertIsNone(wp.workspace_root(ws('w1', 1, 'x'), []))


class TestListDirs(BaseDirCase):
    def test_lists_visible_subdirs_sorted(self):
        self.assertEqual(wp.list_dirs(self.base), ['alpha', 'beta', 'condenser', 'dotfiles', 'zeta'])

    def test_missing_base_lists_nothing(self):
        self.assertEqual(wp.list_dirs(self.d('missing')), [])


class TestBuildRows(BaseDirCase):
    def rows(self, workspaces, panes):
        return wp.build_rows(workspaces, panes, self.base, wp.list_dirs(self.base))

    def test_without_workspaces_lists_every_dir(self):
        rows = self.rows([], [])
        self.assertEqual(
            [r.target for r in rows], [f'dir:{self.d(n)}' for n in ('alpha', 'beta', 'condenser', 'dotfiles', 'zeta')]
        )

    def test_workspaces_come_first_in_number_order_then_dirs(self):
        workspaces = [ws('w1', 1, 'zeta'), ws('w2', 2, 'alpha')]
        panes = [pane('w1', self.r('zeta')), pane('w2', self.r('alpha'))]
        rows = self.rows(workspaces, panes)
        self.assertEqual(
            [r.target for r in rows],
            ['ws:w1', 'ws:w2', f'dir:{self.d("beta")}', f'dir:{self.d("condenser")}', f'dir:{self.d("dotfiles")}'],
        )

    def test_dir_with_workspace_is_not_listed_twice(self):
        rows = self.rows([ws('w1', 1, 'beta')], [pane('w1', self.r('beta'))])
        self.assertNotIn(f'dir:{self.d("beta")}', [r.target for r in rows])

    def test_workspace_in_subdir_covers_its_top_level_dir(self):
        rows = self.rows([ws('w1', 1, 'dotfiles')], [pane('w1', self.r('dotfiles/herdr'))])
        self.assertNotIn(f'dir:{self.d("dotfiles")}', [r.target for r in rows])

    def test_every_workspace_of_a_dir_gets_its_own_row(self):
        workspaces = [ws('w1', 1, 'condenser'), ws('w2', 2, 'condenser')]
        panes = [pane('w1', self.r('condenser/ios')), pane('w2', self.r('condenser'))]
        targets = [r.target for r in self.rows(workspaces, panes)]
        self.assertEqual(targets[:2], ['ws:w1', 'ws:w2'])
        self.assertNotIn(f'dir:{self.d("condenser")}', targets)

    def test_workspace_outside_base_is_still_listed(self):
        rows = self.rows([ws('w1', 1, 'deploy')], [pane('w1', '/somewhere/deploy')])
        self.assertEqual(rows[0].target, 'ws:w1')
        self.assertEqual(len(rows), 6)

    def test_dir_name_prefix_is_not_a_match(self):
        # alpha-2 is not inside alpha
        os.makedirs(self.d('alpha-2'))
        rows = self.rows([ws('w1', 1, 'alpha-2')], [pane('w1', self.r('alpha-2'))])
        self.assertIn(f'dir:{self.d("alpha")}', [r.target for r in rows])


class TestFormatLines(BaseDirCase):
    def lines(self, workspaces, panes):
        rows = wp.build_rows(workspaces, panes, self.base, wp.list_dirs(self.base))
        return [line.split('\t', 1) for line in wp.format_lines(rows, self.base)]

    def test_first_field_is_the_target(self):
        target, _ = self.lines([ws('w1', 1, 'alpha')], [pane('w1', self.r('alpha'))])[0]
        self.assertEqual(target, 'ws:w1')

    def test_workspace_rows_are_highlighted_and_dir_rows_are_plain(self):
        lines = self.lines([ws('w1', 1, 'alpha')], [pane('w1', self.r('alpha'))])
        ws_display = lines[0][1]
        dir_display = lines[1][1]
        self.assertIn(f'{wp.WORKSPACE_STYLE}alpha', ws_display)
        self.assertEqual(plain(dir_display), dir_display)
        self.assertEqual(plain(dir_display).strip(), 'beta')

    def test_workspace_row_shows_number_focus_mark_and_status(self):
        lines = self.lines([ws('w1', 7, 'alpha', focused=True, status='blocked')], [pane('w1', self.r('alpha'))])
        self.assertEqual(plain(lines[0][1]).split(), ['*', '7', 'alpha', '[blocked]'])

    def test_unknown_status_is_hidden(self):
        lines = self.lines([ws('w1', 1, 'alpha')], [pane('w1', self.r('alpha'))])
        self.assertEqual(plain(lines[0][1]).split(), ['1', 'alpha'])

    def test_path_is_shown_when_it_differs_from_the_label(self):
        lines = self.lines(
            [ws('w1', 1, 'dotfiles'), ws('w2', 2, 'deploy')],
            [pane('w1', self.r('dotfiles/herdr')), pane('w2', os.path.expanduser('~/deploy'))],
        )
        self.assertEqual(plain(lines[0][1]).split(), ['1', 'dotfiles', 'dotfiles/herdr'])
        self.assertEqual(plain(lines[1][1]).split(), ['2', 'deploy', '~/deploy'])

    def test_dir_names_line_up_with_workspace_labels(self):
        lines = self.lines([ws('w1', 12, 'alpha')], [pane('w1', self.r('alpha'))])
        ws_display, dir_display = plain(lines[0][1]), plain(lines[1][1])
        self.assertEqual(ws_display.index('alpha'), dir_display.index('beta'))


class TestResolveTarget(BaseDirCase):
    def test_workspace_target_focuses_it(self):
        self.assertEqual(wp.resolve_target('ws:w9', [], [], self.base), ('focus', 'w9'))

    def test_dir_without_workspace_creates_one(self):
        self.assertEqual(wp.resolve_target(f'dir:{self.d("beta")}', [], [], self.base), ('create', self.d('beta')))

    def test_dir_with_workspace_focuses_it(self):
        workspaces = [ws('w1', 1, 'beta')]
        panes = [pane('w1', self.r('beta'))]
        self.assertEqual(wp.resolve_target(f'dir:{self.d("beta")}', workspaces, panes, self.base), ('focus', 'w1'))

    def test_typed_name_is_relative_to_base(self):
        self.assertEqual(wp.resolve_target('condenser/ios', [], [], self.base), ('create', self.d('condenser/ios')))

    def test_typed_tilde_and_absolute_paths(self):
        with mock.patch.dict(os.environ, {'HOME': self.base}):
            self.assertEqual(wp.resolve_target('~/zeta', [], [], '/unused'), ('create', self.d('zeta')))
        self.assertEqual(wp.resolve_target(self.d('alpha'), [], [], '/unused'), ('create', self.d('alpha')))

    def test_typed_path_reuses_existing_workspace(self):
        workspaces = [ws('w1', 1, 'zeta')]
        panes = [pane('w1', self.r('zeta'))]
        self.assertEqual(wp.resolve_target('zeta', workspaces, panes, self.base), ('focus', 'w1'))

    def test_exact_root_beats_workspace_in_subdir(self):
        workspaces = [ws('w1', 1, 'condenser'), ws('w2', 2, 'condenser')]
        panes = [pane('w1', self.r('condenser/ios')), pane('w2', self.r('condenser'))]
        self.assertEqual(wp.resolve_target('condenser', workspaces, panes, self.base), ('focus', 'w2'))

    def test_workspace_in_subdir_counts_as_the_dir_workspace(self):
        workspaces = [ws('w1', 1, 'dotfiles')]
        panes = [pane('w1', self.r('dotfiles/herdr'))]
        self.assertEqual(wp.resolve_target('dotfiles', workspaces, panes, self.base), ('focus', 'w1'))

    def test_subdir_of_a_workspace_root_gets_its_own_workspace(self):
        workspaces = [ws('w1', 1, 'condenser')]
        panes = [pane('w1', self.r('condenser'))]
        self.assertEqual(
            wp.resolve_target('condenser/ios', workspaces, panes, self.base), ('create', self.d('condenser/ios'))
        )

    def test_not_a_directory_is_an_error(self):
        with self.assertRaises(NotADirectoryError):
            wp.resolve_target('missing', [], [], self.base)
        with self.assertRaises(NotADirectoryError):
            wp.resolve_target('notes.txt', [], [], self.base)


if __name__ == '__main__':
    unittest.main()
