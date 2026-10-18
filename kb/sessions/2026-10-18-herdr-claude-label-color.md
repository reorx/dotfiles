---
created: 2026-10-18
tags:
  - herdr
  - configuration
---

# Claude Code 侧栏名称改为橙色，并确认内置 last_pane

## 概要

将 agents 区域中 Claude Code 的 workspace 和 tab 名称设为橙色 `#fab387`，使用 `ui.sidebar.agents.rows_by_agent.claude` 覆盖显示行。状态圆点仍显示状态颜色，其余 agent 使用默认布局。用户最初提出追加橙色 `❋`，确认配置不支持固定文字且字段间自动带分隔点后，改为仅给名称着色。

本机 Herdr 0.9.5 CLI 的默认配置和官方文档均确认已有 `keys.last_pane`：跨 workspace/tab 返回上次聚焦的 pane，可来回切换，默认不绑定按键。因此没有新增插件 action，也没有自行绑定快捷键；README 给出 `prefix+tab` 示例。

## 修改的文件

- `herdr/config.toml`：Claude Code 名称使用橙色。
- `herdr/herdr-navigate-line/README.md`：记录内置 last_pane 和可选绑定方式。
- `AGENTS.md`：添加 Herdr 配置、校验和导航文档入口。

## 验证

- `herdr config check` 返回 `config: ok`。
- `herdr server reload-config` 返回 `status: applied`，无 diagnostics；运行中的 server 为 0.9.4。
- 实机截图确认 zack-fair、campus_watch、Documents 中的 Claude pane、gapless-paste 中的 Claude pane 名称为橙色，Codex 名称及状态圆点保持原有颜色。
- 截图归档：`tmp/2026-10-18-herdr-claude-marker/herdr-sidebar.png`。验收前已运行 `agent-inspect-session.sh`（context 10%）和 `wake-screen`；未启动模拟器或浏览器测试会话。
- last_pane 通过安装版本的 `herdr --default-config` 与[官方配置参考](https://herdr.dev/docs/config-reference/)核实，未修改绑定或切换用户焦点进行测试。

## 注意事项

侧栏 token 的 `fg` 接受十六进制颜色，不能引用主题 token 名称；这里使用当前主题 peach 对应的 `#fab387`。按 agent 类型覆盖整个显示行，可保留 `state_icon` 原来的语义颜色。

## 遗留问题

无。
