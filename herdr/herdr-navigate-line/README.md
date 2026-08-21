# herdr-navigate-line

A Herdr plugin that forwards readline cursor-movement keys to the focused
pane. It solves the conflict between the Herdr prefix key (for example
`ctrl+a`) and the standard Unix command-line movement keys: bind a prefix
combo to a plugin action, and the action sends the real key to the shell
with `pane.send_keys`.

It also carries two small utility actions: `break_pane`, which moves the
focused pane into its own tab (tmux `break-pane`), and `create_workspace`,
which works around the fact that a workspace CWD is fixed at creation time
and does not follow later `cd` commands.

## Actions

| Action id (qualified)        | Key sent | Effect in readline      |
| ---------------------------- | -------- | ----------------------- |
| `navigate_line.jump_start`   | `ctrl+a` | Jump to start of line   |
| `navigate_line.jump_end`     | `ctrl+e` | Jump to end of line     |
| `navigate_line.word_back`    | `alt+b`  | Move one word back      |
| `navigate_line.word_forward` | `alt+f`  | Move one word forward   |

### `navigate_line.break_pane`

Moves the pane the action was invoked from into a new tab and focuses it
(the running process stays alive). Behavior follows tmux `break-pane`:

- A pane that is already alone in its tab is left untouched, so no
  single-pane tab is churned into another single-pane tab
- A zoomed tab is unzoomed before the move

Implemented in `break-pane.sh` with only the `herdr` CLI: it reads
`herdr pane layout` to count panes and check zoom, then runs
`herdr pane move <id> --new-tab --focus`. The empty source tab case does
not need cleanup; Herdr closes a tab when its last pane leaves.

### `navigate_line.next_unread_agent`

Focuses the next agent that needs attention:

- `done` — the agent finished and the user has not seen the result yet
  (Herdr clears `done` to `idle` when the pane is focused)
- `blocked` — the agent waits for user input (permission prompt or
  question)

Agents that are `working` or `idle` (already seen) are skipped. When the
focused pane is itself a candidate, the action picks the next candidate
in agent-list order and wraps around, so repeated presses cycle through
all agents that need attention. With no candidate, it shows a
notification and does not move focus.

Implemented in `next-unread-agent.py`: it parses `herdr agent list`
JSON, filters on `agent_status`, and calls `herdr agent focus <pane>`.

### `navigate_line.create_workspace`

Opens a popup pane that asks for the project directory, then runs
`herdr workspace create --cwd <dir> --focus`. Because actions run without
a TTY, the prompt lives in a `[[panes]]` popup entrypoint
(`create_workspace_prompt`); the action only opens that popup.

Input handling in `create-workspace.sh`:

- With `fzf` installed: pick a directory under `~/Code`, or type a name
  that is not in the list and press enter to use it as-is
- Without `fzf`: a plain `read` prompt
- A name is relative to `~/Code`; input that starts with `/` or `~` is
  used as a full path
- Empty input or `Esc`/`ctrl+c` cancels; a path that is not a directory
  shows an error and does not create a workspace

To add more keys, add a `[[actions]]` block in `herdr-plugin.toml` with the
key combo as the last argv element. `send-keys.sh` accepts any Herdr
key-combo string (`ctrl+k`, `ctrl+w`, `alt+d`, ...).

## Install

Link the plugin directory (works with or without a running Herdr server):

```sh
herdr plugin link ~/Code/dotfiles/herdr/herdr-navigate-line
herdr plugin action list --plugin navigate_line
```

Then bind keys in Herdr `config.toml`. Because the prefix is `ctrl+a`,
`prefix+a` (press `ctrl+a` twice) sends a real `ctrl+a` to the shell,
the same convention as tmux:

```toml
[[keys.command]]
key = "prefix+a"
type = "plugin_action"
command = "navigate_line.jump_start"
description = "send ctrl+a to pane"

[[keys.command]]
key = "prefix+e"
type = "plugin_action"
command = "navigate_line.jump_end"
description = "send ctrl+e to pane"

[[keys.command]]
key = "prefix+u"
type = "plugin_action"
command = "navigate_line.next_unread_agent"
description = "focus next unread/blocked agent"

[[keys.command]]
key = "prefix+shift+n"
type = "plugin_action"
command = "navigate_line.create_workspace"
description = "create workspace from directory prompt"

[[keys.command]]
key = "prefix+shift+b"
type = "plugin_action"
command = "navigate_line.break_pane"
description = "break pane into new tab"
```

Reload config (`prefix+shift+r`) after the edit.

## Test

Invoke an action directly, or use the keybinding in a pane with text on
the command line:

```sh
herdr plugin action invoke navigate_line.jump_start
herdr plugin log list --plugin navigate_line
```

## Uninstall

```sh
herdr plugin unlink navigate_line
```
