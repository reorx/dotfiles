---
created: 2026-11-04
tags:
  - herdr
  - plugin
  - layout
---

# herdr-kit 新增 `kit.next_layout`：`prefix+space` 按 tmux 预设轮换 pane 布局

## 概要

用户想要 tmux 的 `prefix+space`（`next-layout`）。先确认了 Herdr 0.9.5 本身没有这个功能：`[keys]` 里只有 split、zoom、resize，没有布局轮换。所以在 herdr-kit 里新增 `kit.next_layout` 和 `kit.previous_layout` 两个 action，`config.toml` 把 `prefix+space` 绑到 `kit.next_layout`。预设和顺序跟 tmux 一致：even-horizontal、even-vertical、main-horizontal、main-vertical、tiled。对当前 pane 数画出来一样的预设只保留一个，所以 2 个 pane 时就是左右和上下来回切。识别当前布局只看形状、不看比例：调过比例的左右布局，按一下照样切到上下。同方向嵌套的 split 会合并后再比，所以三列不管当初怎么切出来的，都算 even-horizontal。实现时最大的障碍是 Herdr 没有原地重排的接口，最后的做法是：除第一个 pane 外，其余 pane 先挪进临时 tab `kit-layout`，再按目标分割树逐个挪回原 tab。整个过程进程不中断，tab id、pane id、terminal id 都不变。

## 修改的文件

- `herdr/herdr-kit/cycle-layout.py`（新增）：通过 socket 完成全部操作。先用 `layout.export` 导出分割树，生成预设并按形状去重，选出下一个布局。如果 tab 处于 zoom 状态就先取消 zoom，然后 park（挪进临时 tab）、place（按树挪回），最后把焦点还给原来的焦点 pane。如果某次 `pane.move` 返回 `changed: false`，直接报错，不在半路静默产出错误的布局。
- `herdr/herdr-kit/tests/test_cycle_layout.py`（新增，先写测试，后写实现）：共 21 个测试。覆盖预设的结构和比例、去重、pane 顺序、轮换顺序和往回走、比例和嵌套方式不影响识别、无法识别的布局、单 pane。还有一个按 Herdr 真实语义写的假 socket：同 tab move 和移入 zoom 中的 tab 都是空操作，tab 清空后自动关闭，焦点 pane 离开后焦点转给别的 pane。在它上面验证 3–6 个 pane 时每种布局都能精确建出来，以及临时 tab 的处理、park 时 pane 不被挤小、焦点恢复、zoom、出错即停。
- `herdr/herdr-kit/herdr-plugin.toml`：新增 `next_layout`、`previous_layout` 两个 action（`contexts = ["pane"]`）。
- `herdr/config.toml`：`prefix+space` 绑到 `kit.next_layout`。
- `herdr/herdr-kit/README.md`：新增 `kit.next_layout` 和 `kit.previous_layout` 一节（预设表、识别规则、绕道临时 tab 的原因），在 Install 示例里补上绑定，在 Test 里补上测试命令。
- `AGENTS.md`：herdr 条目补一句：改布局轮换后要跑 `test_cycle_layout.py`。

## 验证

- `python3 herdr/herdr-kit/tests/test_cycle_layout.py`：21/21 通过，pyenv 的 3.12 和 macOS 自带的 3.9.6 都通过。
- 实机测试（`tmp/herdr-layout-live.py`，未入库）：在测试 tab 里开 3 个 pane，各跑 `echo marker; sleep 9999`，然后连续 5 次 next、1 次 previous。结果依次是 even-vertical → main-horizontal → main-vertical → tiled → even-horizontal → tiled。每一步之后都检查过：pane 顺序不变，terminal id 不变，`kit-layout` tab 已经关闭；最后 3 个 pane 的 marker 都还在屏幕上。
- 焦点和 zoom（`tmp/herdr-layout-live-focus.py`）：把焦点给第二个 pane 并 zoom，然后从它发起 next。结束后 zoom 已取消，tab 内焦点和客户端焦点都回到这个 pane；even-horizontal 的比例是 0.333 和 0.5。
- 通过插件 runner 调用（`tmp/herdr-layout-invoke.sh`）：`herdr plugin action invoke kit.next_layout`，根分割由 `right` 变成 `down`；插件日志显示 succeeded、exit 0、无 stderr，耗时 100ms。
- `herdr config check` 通过，`herdr server reload-config` 显示 applied，`herdr plugin action list --plugin kit` 能看到两个新 action。

## 注意事项

- **`layout.apply` 不能用来重排**：给它已有的 `tab_id` 和 pane id，它会关掉原 tab、杀掉里面的进程，再新建一个全是新 shell 的 tab（tab id 也会变），节点里的 `pane_id` 被忽略。实验时用的是测试 tab，没有误伤。
- **同 tab 内的 `pane.move` 是空操作**：返回 `changed: false, reason: same_tab`；移入 zoom 中的 tab 返回 `reason: zoomed_tab`。所以重排只能绕道别的 tab，并且要先取消 zoom。跨 tab 移动（同一 workspace 内）时 pane id 和 terminal id 不变；`--ratio` 是目标 pane 所在的第一个格子的占比；`new_tab` 目标里的 `label` 设的是 tab 名，不会改 pane 名。
- **Herdr 没有最小 pane 尺寸**：反复对半切可以把 pane 切到 0 列宽。所以 park 时每次都切临时 tab 里面积最大的 pane，并按约 2:1 的字符宽高比选择切的方向，避免 TUI 在挪动过程中被压成 0 宽、导致重排。挪回原 tab 时，每个中间格子都不小于最终尺寸，没有这个问题。
- **建树算法**：每个 split 节点做一次 move，把第二棵子树的第一个 pane 从第一棵子树的第一个 pane 上切出来。除第一个 pane 外，每个 pane 正好挪一次，所以一共 park n-1 次、place n-1 次。
- **教训**：在 zsh 里用 `set -- $var` 拆分 id 不会分词，导致 `$a` 为空。结果 `herdr pane split` 没带 pane 参数，在当前所在的 tab 里切出了两个 pane（已关掉，没有影响到别的东西）。之后操作 herdr 的实机实验一律写成脚本，pane id 显式传入，不在 zsh 里靠变量拆分。

## 遗留问题

- 在可见的焦点 tab 里按 `prefix+space` 的实际观感（临时 tab 在 tab 栏里会不会闪一下，TUI 会不会闪烁）需要用户看一眼。这次的实机测试都在测试 tab 上做，用户的客户端不在这台机器上。
- maiev 上读的是生成出来的 `config.maiev.toml`。拉取 dotfiles 后要先运行 `uv run herdr/override_config.py maiev`，再 reload，`prefix+space` 才会生效。
- 如果 move 中途失败，剩下的 pane 会留在 `kit-layout` tab 里，需要手动用 `herdr pane move <pane> --tab <tab> --split right` 挪回来（README 写了）。实测没有遇到过，不登记为 known issue。
- 实机测试脚本在 gitignore 的 `tmp/` 下，没有入库，和 known-issues 里「nvim 历史测试脚本未入库」是同一类问题。

## 相关文档

- [herdr-kit 新增 kit.pick_split](./2026-10-31-herdr-split-picker.md)：参考。split 的 ratio 语义、`pane swap` 和 zoom 处理沿用了它的结论
- [kit.pick_split 改为两步选择](./2026-10-31-herdr-split-picker-two-step.md)：参考。测试和 manifest 的组织方式与它一致
