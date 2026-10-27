---
created: 2026-10-27
tags:
  - herdr
  - plugin
---

# workspace picker：按 label 判断 workspace 目录，修复 scripts 被 Documents 吞掉

## 概要

`prefix+o`（`navigate_line.pick_workspace`）的目录列表里没有 `~/Code/scripts`，Documents workspace 那一行后面却显示了 `scripts`。原因是 Documents workspace 没有 worktree 信息，root 只能取各 pane cwd 中出现最多的那个。它的 6 个 pane 里 4 个在 `~/Code/scripts`（后两个 tab），只有 1 个在 `~/Documents`，所以 root 被算成了 scripts。结果是 scripts 被当成"已有 workspace"藏了起来，手动输入 `scripts` 也会跳到 Documents，在 picker 里没法为它新建 workspace。

修法：`workspace_root` 在 worktree 之后、"出现最多的 cwd"之前，先只看目录名等于 workspace label 的 pane cwd，有就在其中取出现最多的。Herdr 新建 workspace 时会用 cwd 的目录名作 label，当时 23 个 workspace 都能找到同名的 pane cwd，所以这一规则基本能认出 workspace 自己的目录。改过名的 workspace 没有同名 cwd，退回原来的规则。

## 修改的文件

- `herdr/herdr-navigate-line/workspace-picker.py`：`workspace_root` 增加按 label 同名 cwd 优先的一步，模块 docstring 同步更新。
- `herdr/herdr-navigate-line/tests/test_workspace_picker.py`：新增 6 个用例（TDD，先复现失败再修）。其中 `workspace_root` 4 个：worktree 优先于同名 cwd、同名 cwd 优先于出现最多的 cwd、多个同名 cwd 里取出现最多的、改名后退回原规则；`build_rows` 和 `resolve_target` 各 1 个，复现 Documents/scripts 场景。
- `herdr/herdr-navigate-line/README.md`：`pick_workspace` 一节补充 root 判断规则。

## 验证

- 修复前，3 个复现 Documents 场景的用例失败；修复后 35/35 通过（pyenv 3.12.7 和 `/usr/bin/python3` 3.9.6）。
- 用 picker 自己的函数读真实的 `herdr workspace list` / `pane list`（`tmp/debug_workspace_roots.py`）：Documents 的 root 变为 `~/Documents`，渲染出的行为 `Documents  [done]  ~/Documents`，`scripts` 回到目录列表。没有打开真实 popup 做交互验证，因为改动只涉及列表数据，没有碰交互流程。

## 注意事项

- 这 23 个 workspace 里只有 2 个带 `worktree.checkout_path`（dotfiles 这样的 git 仓库也没有），所以"看 pane cwd"是主要的判断方式，不是边角情况。改 root 规则时要按"多数 workspace 走这条路"来评估。
- "Herdr 默认用 cwd 目录名作 label"是从当时的数据推出来的（23/23 一致），没有查 Herdr 源码确认。

## 遗留问题

- 改过名的 workspace 仍然按"出现最多的 cwd"判断，如果它的大部分 pane 在别的 `~/Code` 目录里，那个目录还是会被藏起来。只有改名后又在里面开很多别的目录的 tab 才会遇到，影响小，暂不处理。
