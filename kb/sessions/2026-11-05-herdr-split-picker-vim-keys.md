---
created: 2026-11-05
tags:
  - herdr
  - keybindings
---

# 布局浮窗改用 HJKL 选择方向

## 概要

`prefix+v` 打开的新 pane 布局浮窗，第一步由数字 1–4 改为 Vim 方向键：`h` 左、`j` 下、`k` 上、`l` 右。预览也按 `h/j/k/l` 排列，即左、下、上、右；窄浮窗的文字列表使用相同顺序。第二步继续使用 `1` 25%、`2` 50%、`3` 75%，空格选 50%；退格返回和取消行为保持原样。

## 修改的文件

- `herdr/herdr-kit/split-picker.py`：更新方向键映射、浮窗提示和模块说明。
- `herdr/herdr-kit/tests/test_split_picker.py`：更新按键、返回、取消、步骤回调及预览标签用例，确认数字在第一步无效。
- `herdr/herdr-kit/README.md`：同步方向键说明、预览文字和连按示例。

## 验证

先修改行为测试，确认旧实现失败，再更新实现。后续调整预览顺序时，同样先确认宽、窄浮窗的顺序断言失败，再修改排列。`uv run herdr/herdr-kit/tests/test_split_picker.py` 的 28 项测试全部通过，覆盖四个方向与三档比例、宽窄浮窗的 HJKL 顺序；`git diff --check` 通过。

## 注意事项

方向键使用小写单键，无需 Shift 或回车。例如 `prefix+v j 1` 在下方新建占当前 pane 25% 的 pane。插件每次打开浮窗都会启动脚本，本次无需修改或重载 Herdr 配置。

## 遗留问题

无。

## 相关文档

- [布局浮窗两步选择](2026-10-31-herdr-split-picker-two-step.md)：参考原有方向与比例选择行为。
