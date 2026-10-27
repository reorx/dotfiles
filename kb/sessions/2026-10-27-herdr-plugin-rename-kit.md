---
created: 2026-10-27
tags:
  - herdr
  - plugin
---

# herdr 插件改名：herdr-navigate-line → herdr-kit（plugin id `kit`）

## 概要

插件最早只用来把 readline 移动键（`ctrl+a` 等）透传给 shell，名字 `navigate_line` 由此而来。后来陆续加入 pane/tab（`break_pane`、`new_tab_quick`、`new_tab_adjacent`）、agent（`next_unread_agent`、`pick_agent`）和 workspace（`pick_workspace`、`create_workspace`）几类 action，11 个 action 里只剩 4 个和名字有关。讨论后决定改用一个表达角色而不是具体内容的名字，免得以后继续加功能时再次对不上。最终选定目录 `herdr/herdr-kit/`、plugin id `kit`，调用名变为 `kit.pick_workspace` 这种形式。也讨论过按功能拆成多个插件，因为 herdr 插件之间不能共享代码，而这些 action 共用 popup pane 和 fzf 回退的写法，所以没有拆。

## 修改的文件

- `herdr/herdr-navigate-line/` → `herdr/herdr-kit/`（`git mv`）。
- `herdr/herdr-kit/herdr-plugin.toml`：`id = "kit"`、`name = "Kit"`，`description` 改为描述整个工具箱。
- `herdr/herdr-kit/README.md`：开头改写为按类别列出全部 action，其余位置的 `navigate_line.` 都换成 `kit.`。
- `herdr/herdr-kit/*.sh`、`*.py`、`tests/test_workspace_picker.py`：报错前缀 `navigate_line:` 改为 `kit:`；`new-tab-adjacent.py` 的 socket 请求 id 也同步改了；测试 docstring 里的路径一并更新。
- `herdr/config.toml`：8 条 `[[keys.command]]` 改为 `kit.*`。
- `herdr/herdr-plugin-guide.md`：引用路径更新。原来说这个插件是“最小示例”，现在它已经不算小，改成分别指向 `send-keys.sh`（最小 action）和 `workspace-picker.py`（popup pane 交互）。
- `AGENTS.md`：插件路径和说明更新。

## 验证

- `python3 herdr/herdr-kit/tests/test_workspace_picker.py`：35/35 通过。
- 本机切换：先 `herdr plugin unlink navigate_line`，再 `herdr plugin link herdr/herdr-kit`，然后 `herdr config check`（ok）和 `herdr server reload-config`（applied，无 diagnostics）。`herdr plugin list` 只剩 `kit (Kit)`，`plugin action list --plugin kit` 列出全部 11 个 action。
- `herdr plugin action invoke kit.word_forward` 的执行状态为 succeeded、exit 0，说明新 id 能正常解析和执行。

## 注意事项

- plugin id 是 `<plugin_id>.<action_id>` 中的前缀，会出现在每一条按键绑定里，所以要短，而且不要描述具体功能。描述功能的名字，插件一扩展就会过时。
- 改 plugin id 时，unlink、link、reload 要连着做。先改 config 再 relink 会让旧绑定短暂失效；只 relink 不 reload，`config.toml` 里的新 id 又会指向不存在的 action。
- popup 的 opener 脚本用的是 `$HERDR_PLUGIN_ID`，没有写死 id，所以这次不用改。报错前缀仍然写死为 `kit:`，因为新名字不会再随内容变化，没有必要再做一层动态取值。
- 用 CLI `plugin action invoke` 调用 `send-keys.sh` 类的 action 时，按键会发到当前焦点 pane（这次是另一个 workspace 里空闲的 Claude 输入框，发了一次 `alt+f`），验证时要注意这一点。
- 历史 session（`kb/sessions/` 下的旧文件）中的 `navigate_line` 保留原样，没有改写。
