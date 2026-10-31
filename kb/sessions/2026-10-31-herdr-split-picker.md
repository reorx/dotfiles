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

第二轮（同日）：预览图下方加一行，提供两个 50% 分割：`v` 是 vertical，左右并排（split right）；`h` 是 horizontal，上下堆叠（split down）。命名沿用 herdr 自己的 `split_vertical`/`split_horizontal`。浮窗配色改成运行时读取当前生效配置里的 `ui.accent`，所以 maiev 上显示琥珀色，其他机器上显示粉色。

## 修改的文件

- `herdr/herdr-kit/split-picker.py`（新）：popup 入口。负责布局定义、预览框生成（阴影 `░` 标出新 pane，ANSI 粉色沿用 `ui.accent`）、按键读取、分割逻辑。popup 宽度不足 85 列时改为显示纯文本列表。
- `herdr/herdr-kit/open-split-picker.sh`（新）：action 脚本。popup 进程拿不到 `HERDR_PANE_ID`，所以这个脚本用 `--env KIT_SPLIT_PANE=$HERDR_PANE_ID` 把目标 pane 传进去。
- `herdr/herdr-kit/tests/test_split_picker.py`（新）：19 个行为测试，覆盖按键映射、取消键、预览中阴影的位置和占比、宽/窄两种渲染，以及四种布局各自对应的 herdr 调用序列（含 zoom 场景）。
- `herdr/herdr-kit/herdr-plugin.toml`：新增 `pick_split` action（`contexts = ["pane"]`）和 `split_picker` popup（`width = 89`、`height = 16`）。
- `herdr/config.toml`：绑定 `prefix+v` → `kit.pick_split`。herdr 默认把 `prefix+v` 绑在 `split_vertical` 上，但本配置已经改成 `prefix+|`，所以不冲突。
- `herdr/herdr-kit/README.md`：新增 `kit.pick_split` 一节（含 ASCII 预览和实现说明），并更新开头的分类列表、Install 绑定示例和 Test 命令。
- `AGENTS.md`：补充 split picker 的测试命令。

- 第二轮：`split-picker.py` 的布局拆成 `PREVIEWED`（四个 25% 预览）和 `HALVES`（v/h），`Layout` 增加了 `share` 和 `note` 字段。`read_accent()` 按 `HERDR_CONFIG_PATH` 或 `~/.config/herdr/config.toml` 读取 `[ui]` 表里的 `accent`，`accent_style()` 支持 `#rrggbb` 和 `rgb(r, g, b)` 两种格式，其他格式退回终端品红色。manifest 里 popup 的高度从 16 改为 17（内容多了一行）。测试增加到 28 个。

## 验证

- `python3 herdr/herdr-kit/tests/test_split_picker.py`：19/19 通过。`test_workspace_picker.py` 未受影响。
- 真实 herdr 端到端测试（`tmp/layout-exp/e2e.py`，没有入库）：在临时 tab 的普通 pane 里运行 picker，用 `pane send-keys` 发送按键，再读取目标 pane 的实际布局。在 126x43 的区域内，1 → 新 pane 在下方，高 11；2 → 在上方，高 11；3 → 在左侧，宽 32；4 → 在右侧，宽 31。四种情况焦点都落在新 pane 上，cwd 都继承了原 pane。Esc 和 q 都不改变布局，退出码为 0。
- 真实 popup（`tmp/layout-exp/popup-check.py`）：先用 `herdr plugin action invoke kit.pick_split` 打开 popup，检查完再用 socket 的 `popup.close` 关闭。popup 的 pty 是 14 行 × 86 列，容得下 13 × 85 的图。pty 处于 `-icanon -echo` 状态，说明 picker 已经拿到 `KIT_SPLIT_PANE` 并在等单键；拿不到的话会走 fail 分支，停在 `input()`。popup 关闭后，调用方 pane 的布局没变。
- 第二轮：28/28 单测通过。e2e 新增 v、h 两个用例，在 126x43 的区域内 v 分成 63/63 宽，h 分成 22/21 高，焦点都在新 pane 上；8 个用例全部通过。popup 的 pty 变成 15×86（manifest 改动不用重新 link 就生效），内容是 14×85。临时让 opener 把 `HERDR_CONFIG_PATH` 打到 stderr，从插件日志确认插件进程能拿到 `config.maiev.toml`，看完就恢复了。插件日志里也能看到用户按 `prefix+v` 和 `prefix+o` 都执行成功。
- 本机（Maiev）的插件状态：链接的仍是旧的 `navigate_line`，路径已不存在。本次按 10-27 记录的步骤执行 unlink → link → reload，现在 `plugin list` 里只剩 `kit`。
- 用户反馈 `prefix+v` 无效，其他插件快捷键也全部失效。原因是 maiev 设置了 `HERDR_CONFIG_PATH=~/.config/herdr/config.maiev.toml`，herdr 读的是 `override_config.py` 在 8 月生成的那份配置，里面的绑定仍是 `navigate_line.*`，也没有 `prefix+v`。前面跑的 `config check` 和 `reload-config` 针对的都是这份旧文件。unlink `navigate_line` 之后，这些旧绑定就全部失效了。修复方法：执行 `uv run herdr/override_config.py maiev` 重新生成配置，再 `config check`（ok）和 `reload-config`（applied）。新文件里没有 `navigate_line`，有 `kit.pick_split`，maiev 自己的琥珀色 accent 也保留了。

## 注意事项

- herdr 分割的两条规则：`--ratio` 是第一格（上/左）的占比；`pane swap` 交换 pane，但不改变格子的尺寸，焦点也留在原来的格子。要在上方或左侧新建 pane，只能"小比例分割 + swap"。这样原 pane 会先缩到 25%，再变成 75%，TUI 程序会重排两次。
- popup 不是 pane：没有 pane id，`pane send-keys`/`pane read` 都作用不到它，进程也拿不到 `HERDR_PANE_ID`（docs 说底层 pane 可以从 `HERDR_PLUGIN_CONTEXT_JSON` 读到，本次改用 `--env` 显式传入）。自动化验证只能把 picker 放进普通 pane 里跑。popup 本身只能通过 `popup.close` 关闭，再结合 pty 状态间接判断。
- 读单键时要用 `tty.setcbreak(fd, termios.TCSANOW)`，并且在绘制之前切换。默认的 `TCSAFLUSH` 会丢掉 popup 打开过程中已经按下的数字（prefix+v 之后马上按 1 就会被吞掉）。切换后清一次屏，把预先回显的那个字符擦掉。
- macOS 的 `ps -E` 读不到任何进程的环境变量（自己的子进程也读不到），不能用它验证 env 传递。
- **测试时不要在 shell 启动过程中关闭临时 tab。** 用户的登录 shell 启动时会跑 `pyenv rehash`，被 HUP 打断后会留下 `~/.pyenv/shims/.pyenv-shim` 锁文件。之后每个新 shell 都要卡到锁超时（最长 60 秒），新开的 pane 就一直没有提示符。本次就踩到了：确认没有 rehash 进程在跑之后删掉锁文件，e2e 脚本改为关 tab 前等 `pgrep -f pyenv-rehash` 返回空。
- 新建 tab 后，如果立刻 `pane run`，命令会被回显但不执行，因为 zsh 还没准备好。应该先跑一条 echo 并等它的输出。
- 改 herdr 绑定前先 `echo $HERDR_CONFIG_PATH`：它指向生成的 `config.<machine>.toml` 时，`config check`/`reload-config` 都只认那份文件，改 `config.toml` 之后要先跑 `override_config.py`。
- 插件进程会继承 herdr server 的环境变量（包括 `HERDR_CONFIG_PATH`）。要确认某个变量有没有传进去，可以让 action 脚本把它 echo 到 stderr，再用 `herdr plugin log list --plugin kit` 查看。
- `screencapture` 截到的是本机桌面，用户的 herdr 客户端在另一台机器上，所以截图拿来验收 popup 没有用。

## 遗留问题

- 新 pane 和按键的颜色要靠用户在 maiev 上看一眼才能确认是琥珀色：我只能验证解析出的 ANSI 序列，看不到 popup 的实际画面。
- 另一台机器如果在 10-27 改名后也没有重新 link，就会和 Maiev 一样，所有 `kit.*` 绑定都失效。在那台机器上执行 `herdr plugin list` 确认，出现 `navigate_line` 的话，就按 README 的 Install 步骤重新 link。

## 相关文档

- [herdr 插件改名为 herdr-kit](./2026-10-27-herdr-plugin-rename-kit.md)：参考，按其中的 unlink/link/reload 步骤修复了本机的插件链接
- [workspace get-or-create picker](./2026-10-22-herdr-workspace-get-or-create.md)：参考，popup 入口、行为测试按模块路径加载的写法与它一致
