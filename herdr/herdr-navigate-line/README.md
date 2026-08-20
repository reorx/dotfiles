# herdr-navigate-line

A Herdr plugin that forwards readline cursor-movement keys to the focused
pane. It solves the conflict between the Herdr prefix key (for example
`ctrl+a`) and the standard Unix command-line movement keys: bind a prefix
combo to a plugin action, and the action sends the real key to the shell
with `pane.send_keys`.

## Actions

| Action id (qualified)        | Key sent | Effect in readline      |
| ---------------------------- | -------- | ----------------------- |
| `navigate_line.jump_start`   | `ctrl+a` | Jump to start of line   |
| `navigate_line.jump_end`     | `ctrl+e` | Jump to end of line     |
| `navigate_line.word_back`    | `alt+b`  | Move one word back      |
| `navigate_line.word_forward` | `alt+f`  | Move one word forward   |

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
