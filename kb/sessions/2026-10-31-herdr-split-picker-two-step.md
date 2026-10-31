---
created: 2026-10-31
tags:
  - herdr
  - plugin
  - popup
---

# herdr-kit `kit.pick_split` 改为两步选择：先选方位，再选大小

## 概要

原来的 `prefix+v` 浮窗只有 6 种布局：四个方向各一个 25%，再加 `v`/`h` 两个 50%。上方和左侧没有 50% 的选项，四个方向也都没有 75%，覆盖不了真正会用到的布局。现在改成连按两个键：第一步用 `1`-`4` 选新 pane 的方位，顺序是从上方开始顺时针（上、右、下、左）；第二步选新 pane 占当前 pane 的比例，`1` 25%、`2` 50%、`3` 75%，空格也是 50%。四个方位乘三种大小，共 12 种布局。`v`、`h` 两个键去掉了。两步都有预览：第一步并排四个方位的 50% 预览，第二步显示所选方位的 25/50/75% 三个预览。第二步按 backspace 回到第一步；`q`、Esc、ctrl+c 在两步里都能取消。分割逻辑沿用原来的做法：下方和右侧用 `1 - size` 分割一次，上方和左侧先用 `size` 分割，再 swap、移焦点，只是比例从固定的 25% 改为参数。

## 修改的文件

- `herdr/herdr-kit/split-picker.py`：`Layout` 改为 `(side, share)` 两个字段，`direction` 和 `new_first` 由 side 推导。`choose()` 改成两步状态机，切换步骤时调用 `on_step(side)` 重绘，backspace 时调用 `on_step(None)`。`render(cols, accent, side)` 按步骤输出四个或三个预览，窄浮窗时退回纯文本列表。预览框内宽从 16 改为 15：去掉分隔线后剩 14×6 格，可以均分，25% 和 75% 的格数正好互补。pane 标签放不下 `current` 时改用 `cur`，旧代码在这种情况下会算出负的起始列，越出 pane 范围。
- `herdr/herdr-kit/tests/test_split_picker.py`：按新交互重写（先写测试，后改实现），共 28 个。覆盖两步按键、空格、backspace 返回、两步中的取消、步骤回调、12 种预览中阴影的位置和比例、标签不越出所在 pane、两个步骤的渲染，以及 12 种布局对应的 herdr 调用。另外从 manifest 读出浮窗尺寸，检查它容得下画面。
- `herdr/herdr-kit/herdr-plugin.toml`：更新 `pick_split` 的描述；`split_picker` 浮窗的尺寸从 89×17 改为 85×16，内区 82×14，画面 81×13。
- `herdr/herdr-kit/README.md`：重写 `kit.pick_split` 一节，配两个步骤的 ASCII 示意图，并更新分割比例和尺寸说明。

## 验证

- `python3 herdr/herdr-kit/tests/test_split_picker.py`：28/28 通过。
- 在真实 herdr 上跑端到端测试（`tmp/layout-exp/e2e.py`，已按两步交互改写，未入库）。区域为 126×43，11 个用例全部通过：
  - `1 1`：新 pane 在上方，高 11
  - `2 space`：在右侧，宽 63/63
  - `3 3`：在下方，高 32
  - `4 2`：在左侧，宽 63
  - `4 3`：在左侧，宽 95
  - `2 1`：在右侧，宽 31
  - `1 backspace 3 1`：在下方，高 11
  - `2 esc` 和 `q`：布局不变
  - `3 1`、`4 space` 两个键一次连发：结果也正确
  - 所有用例的焦点都落在新 pane，cwd 都继承自原 pane。每个用例退出前，屏幕最后一行都是第二步的提示，说明两次按键之间重绘过。
- 真实浮窗（`tmp/layout-exp/popup-check.py`）：pty 为 14 行 × 82 列，处于 `-icanon -echo`，说明 picker 在等单键输入。关闭浮窗后，调用方 pane 的布局没有变化。

## 注意事项

- 两步交互用回调重绘，不另开读键循环：`pick(draw)` 先画第一步，再把 `draw` 作为 `on_step` 传给 `choose()`。按键仍然从同一个 cbreak 流里逐字节读取，所以「prefix+v 后马上连按两个键」也不会丢键，连发用例验证过这一点。
- 预览格数的计算：`round((size - 1) * share)`，分隔线单独占一格。剩余格数为偶数时，银行家舍入让 25% 和 75% 正好互补。测试会检查这一点，以后改 `INNER_W`/`INNER_H` 时要保持「减一后为偶数」。
- 浮窗的内区等于 manifest 的宽减 3、高减 2。测试 `test_lines_fit_the_popup` 直接读 manifest 来检查，改画面尺寸时测试会提醒同步修改 manifest。
- 窄的 pane 只有 4 列时放不下 `current`，标签有备选（`current` → `cur`），会选第一个放得下的。

## 遗留问题

- 新画面在 maiev 客户端上的实际观感（琥珀色 accent、两步切换时有无闪烁）需要用户看一眼。用户的 herdr 客户端在另一台机器上，这边没法截图验收。
- 本次的 e2e 和浮窗检查脚本仍在 gitignore 的 `tmp/layout-exp/` 里，与 known-issues 里 nvim 测试脚本未入库是同一类问题，暂不单独登记。

## 相关文档

- [herdr-kit 新增 kit.pick_split](./2026-10-31-herdr-split-picker.md)：参考。本次在它的分割规则（ratio 指第一格的占比、swap 不改变格子尺寸）和测试脚本的基础上改造
