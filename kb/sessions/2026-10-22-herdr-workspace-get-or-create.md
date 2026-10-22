---
created: 2026-10-22
tags:
  - herdr
  - plugin
---

# prefix+o workspace picker 改为 get-or-create

## 概要

`navigate_line.pick_workspace`（`prefix+o`）原来只列出已有 workspace。现在它也会列出 `~/Code` 下的子目录，选取逻辑和 `create_workspace`（`prefix+shift+n`）一致，回车时按 get-or-create 处理：

- 选中 workspace 行，直接 focus；
- 选中目录行，或输入一个没有匹配的路径：如果已有 workspace 在这个目录（或目录里面），就 focus 那个 workspace，否则执行 `herdr workspace create --cwd <dir> --focus`。

列表顺序：先按编号列出全部 workspace（粗体青色名称，加上 `*`/编号/状态，目录和 `~/Code/<label>` 不同时显示路径），然后按名称列出还没有 workspace 的目录（普通文字）。`~/Code` 以外的 workspace 也会保留，原来 `prefix+o` 能切换到的 workspace 一个不少。

## 设计决定

- **workspace 所在目录**：Herdr CLI 不提供 workspace 创建时的 CWD。`session.json` 里虽然有 `identity_cwd`，但那是内部持久化文件，新建的 workspace 不会马上写进去，所以没有用。现在的取法：有 `worktree.checkout_path` 时用它，否则取各 pane `cwd` 中出现次数最多的那个，次数相同时取第一个 pane。比较前都做 `realpath`。
- **目录“已有 workspace”的判定**：workspace 的目录等于这个目录，或者在它里面，都算。所以 `dotfiles/herdr` 里的 workspace 算作 `~/Code/dotfiles` 的 workspace。反过来，在 workspace 目录的子目录上 get-or-create，会新建一个 workspace。同一个目录有多个 workspace 时，优先目录完全相等的那个，其次按编号取第一个。
- **picker 自己的 popup pane 也在 `pane list` 里**，cwd 是插件目录，用 `HERDR_PANE_ID` 把它排除。
- **排序**：查询为空时按输入顺序显示，workspace 在最前。输入后由 fzf 按匹配分数排序，分数相同时用 `--tiebreak index` 保持输入顺序，所以 workspace 排在同样匹配的目录前面。代价是同名的两个 workspace（`condenser` 与 `condenser/ios`）按编号排列，不会把目录完全相等的那个排到前面。
- `workspace-picker.sh` 和 `format-workspace-lines.py` 合并成单个 `workspace-picker.py`。原因是列出、解析和执行之间要来回传 `ws:`/`dir:` 目标，放在一个文件里最简单。代码兼容 macOS 系统自带的 Python 3.9。

## 修改的文件

- `herdr/herdr-navigate-line/workspace-picker.py`：新增，包含列表构建、格式化、get-or-create 解析，以及 fzf 和无 fzf 两种交互。
- `herdr/herdr-navigate-line/tests/test_workspace_picker.py`：新增 29 个行为测试（BDD，先写测试再实现）。
- `herdr/herdr-navigate-line/workspace-picker.sh`、`format-workspace-lines.py`：删除。
- `herdr/herdr-navigate-line/herdr-plugin.toml`：pane 入口改为 `python3 workspace-picker.py`，更新 action 标题和描述。
- `herdr/herdr-navigate-line/README.md`、`herdr/config.toml`、`AGENTS.md`：更新说明、按键描述和测试入口。

## 验证

- 测试在 pyenv 的 3.12.7 和 `/usr/bin/python3` 3.9.6 下都通过（29/29）。
- `herdr config check` 返回 ok，`herdr server reload-config` 返回 applied，没有 diagnostics；`herdr plugin action list` 已显示新的标题。
- 实机（Herdr 0.9.5）：在一个不聚焦的临时 workspace 里打开真实的 `workspace_picker` popup，用 `pane read --ansi` 确认列表内容和颜色。按 Esc 后 popup 关闭，焦点不变。
- Herdr 会强制设置插件 pane 的 `HERDR_BIN_PATH`，`--env` 无法换成 stub。所以选择流程改在临时 workspace 的 shell pane 里，用 `tmp/drive-workspace-picker.py` 驱动，并用记录日志的 stub 代替 focus/create。结果：
  - `dotfiles` 和 `dotfiles/herdr` 都执行 `workspace focus w41`；
  - `aibo` 执行 `create --cwd ~/Code/aibo`；
  - `~/Downloads` 没有匹配，执行 `create --cwd ~/Downloads`；
  - `zzqqxx` 报 `not a directory`，不执行任何命令；
  - `vib` 时 workspace 排在目录前。
- 验证用 pane 文本截取，没有截图。测试结束后关闭了临时 workspace，并把焦点还给用户原来的 workspace；没有启动模拟器或浏览器。

## 遗留问题

无。`prefix+shift+n`（`create_workspace`）保持原样，功能已被 `prefix+o` 覆盖，要不要保留由用户决定。
