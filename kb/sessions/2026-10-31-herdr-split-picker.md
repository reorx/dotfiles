---
created: 2026-10-31
tags:
  - herdr
  - plugin
  - popup
---

# herdr-kit 新增 `kit.pick_split`：prefix+v 弹出新 pane 布局浮窗，按 1-4 直接分割

## 概要

需求：按 `prefix+v` 弹出浮窗，用 ASCII 图预览四种新 pane 布局，按一次数字键就生效，不用按回车。1 在底部新建 25% 高的 pane，2 在顶部，3 在左侧（25% 宽），4 在右侧。实现方式和 `pick_agent`、`pick_workspace` 相同：action（`open-split-picker.sh`）只负责打开 `[[panes]]` popup，popup 里的 `split-picker.py` 负责画预览、读单个按键、执行分割。

难点在于 herdr CLI 的 `pane split` 只支持 `right`/`down` 两个方向。实测得到两条规则：`--ratio` 指第一格（上/左）的占比，这一格留给原 pane；`pane swap` 只交换两个 pane，每一格的尺寸不变，焦点也留在原来那一格。据此，底部和右侧直接用 ratio 0.75 分割；顶部和左侧先用 ratio 0.25 分割（`--no-focus`），再 swap，最后用 `pane focus --direction up|left` 把焦点移到新 pane。新 pane 的 cwd 取自原 pane 的 `cwd`，原 pane 处于 zoom 状态时先取消 zoom。

## 修改的文件

- `herdr/herdr-kit/split-picker.py`（新）：popup 入口。负责布局定义、预览框生成（阴影 `░` 标出新 pane，ANSI 粉色沿用 `ui.accent`）、按键读取、分割逻辑。popup 宽度不足 85 列时改为显示纯文本列表。
- `herdr/herdr-kit/open-split-picker.sh`（新）：action 脚本。popup 进程拿不到 `HERDR_PANE_ID`，所以这个脚本用 `--env KIT_SPLIT_PANE=$HERDR_PANE_ID` 把目标 pane 传进去。
- `herdr/herdr-kit/tests/test_split_picker.py`（新）：19 个行为测试，覆盖按键映射、取消键、预览中阴影的位置和占比、宽/窄两种渲染，以及四种布局各自对应的 herdr 调用序列（含 zoom 场景）。
- `herdr/herdr-kit/herdr-plugin.toml`：新增 `pick_split` action（`contexts = ["pane"]`）和 `split_picker` popup（`width = 89`、`height = 16`）。
- `herdr/config.toml`：绑定 `prefix+v` → `kit.pick_split`。herdr 默认把 `prefix+v` 绑在 `split_vertical` 上，但本配置已经改成 `prefix+|`，所以不冲突。
- `herdr/herdr-kit/README.md`：新增 `kit.pick_split` 一节（含 ASCII 预览和实现说明），并更新开头的分类列表、Install 绑定示例和 Test 命令。
- `AGENTS.md`：补充 split picker 的测试命令。

## 验证

- `python3 herdr/herdr-kit/tests/test_split_picker.py`：19/19 通过。`test_workspace_picker.py` 未受影响。
- 真实 herdr 端到端测试（`tmp/layout-exp/e2e.py`，没有入库）：在临时 tab 的普通 pane 里运行 picker，用 `pane send-keys` 发送按键，再读取目标 pane 的实际布局。在 126x43 的区域内，1 → 新 pane 在下方，高 11；2 → 在上方，高 11；3 → 在左侧，宽 32；4 → 在右侧，宽 31。四种情况焦点都落在新 pane 上，cwd 都继承了原 pane。Esc 和 q 都不改变布局，退出码为 0。
- 真实 popup（`tmp/layout-exp/popup-check.py`）：先用 `herdr plugin action invoke kit.pick_split` 打开 popup，检查完再用 socket 的 `popup.close` 关闭。popup 的 pty 是 14 行 × 86 列，容得下 13 × 85 的图。pty 处于 `-icanon -echo` 状态，说明 picker 已经拿到 `KIT_SPLIT_PANE` 并在等单键；拿不到的话会走 fail 分支，停在 `input()`。popup 关闭后，调用方 pane 的布局没变。
- 本机（Maiev）的插件状态：链接的仍是旧的 `navigate_line`，路径已不存在。10-27 改名之后这台机器没有重新 link，所以 config 里的 `kit.*` 绑定全部失效。本次按当时记录的步骤执行 unlink → link → `config check` → `reload-config`，现在 `plugin list` 里只剩 `kit`，共 12 个 action。

## 注意事项

- herdr 分割的两条规则：`--ratio` 是第一格（上/左）的占比；`pane swap` 交换 pane，但不改变格子的尺寸，焦点也留在原来的格子。要在上方或左侧新建 pane，只能"小比例分割 + swap"。这样原 pane 会先缩到 25%，再变成 75%，TUI 程序会重排两次。
- popup 不是 pane：没有 pane id，`pane send-keys`/`pane read` 都作用不到它，进程也拿不到 `HERDR_PANE_ID`（docs 说底层 pane 可以从 `HERDR_PLUGIN_CONTEXT_JSON` 读到，本次改用 `--env` 显式传入）。自动化验证只能把 picker 放进普通 pane 里跑。popup 本身只能通过 `popup.close` 关闭，再结合 pty 状态间接判断。
- 读单键时要用 `tty.setcbreak(fd, termios.TCSANOW)`，并且在绘制之前切换。默认的 `TCSAFLUSH` 会丢掉 popup 打开过程中已经按下的数字（prefix+v 之后马上按 1 就会被吞掉）。切换后清一次屏，把预先回显的那个字符擦掉。
- macOS 的 `ps -E` 读不到任何进程的环境变量（自己的子进程也读不到），不能用它验证 env 传递。
- **测试时不要在 shell 启动过程中关闭临时 tab。** 用户的登录 shell 启动时会跑 `pyenv rehash`，被 HUP 打断后会留下 `~/.pyenv/shims/.pyenv-shim` 锁文件。之后每个新 shell 都要卡到锁超时（最长 60 秒），新开的 pane 就一直没有提示符。本次就踩到了：确认没有 rehash 进程在跑之后删掉锁文件，e2e 脚本改为关 tab 前等 `pgrep -f pyenv-rehash` 返回空。
- 新建 tab 后，如果立刻 `pane run`，命令会被回显但不执行，因为 zsh 还没准备好。应该先跑一条 echo 并等它的输出。
- `screencapture` 截到的是本机桌面，用户的 herdr 客户端在另一台机器上，所以截图拿来验收 popup 没有用。

## 遗留问题

- 还没有在真实 popup 里按过数字键：分割逻辑、按键读取、popup 打开和传参都已分别验证，但"popup 里按 1-4 → 分割 → popup 关闭后焦点落在新 pane"这一整条链路需要用户手动按一次 `prefix+v` 验收。
- 另一台机器如果在 10-27 改名后也没有重新 link，就会和 Maiev 一样，所有 `kit.*` 绑定都失效。在那台机器上执行 `herdr plugin list` 确认，出现 `navigate_line` 的话，就按 README 的 Install 步骤重新 link。

## 相关文档

- [herdr 插件改名为 herdr-kit](./2026-10-27-herdr-plugin-rename-kit.md)：参考，按其中的 unlink/link/reload 步骤修复了本机的插件链接
- [workspace get-or-create picker](./2026-10-22-herdr-workspace-get-or-create.md)：参考，popup 入口、行为测试按模块路径加载的写法与它一致
