---
created: 2026-11-10
tags:
  - claude-code
  - token-usage
  - settings
  - zsh
---

# Claude Code 瘦身第二轮：查清 System tools 的构成，去掉 5 个用不到的工具

## 概要

用户发现交互 session 里 `/context` 的 System tools 一项占得很多，想知道它是怎么构成的、能不能优化。

**调研**：读 2.1.321 源码后确认，`/context` 的 System tools 等于“非 deferred 内置工具 + 已加载的 deferred 工具”的 `count_tokens` 结果，再减掉 Skills 那一行。由于 skill 列表其实不在工具定义里，这一步减法多减了一次，显示的 8.7k 比实际的 13,939 少了约 5.1k。`cc-probe` 只能抓 `-p` 模式，而 AskUserQuestion、SendFeedback 只在交互模式出现，所以另写了一个 pty 抓包脚本，逐个工具精确计数。

**执行**：用户决定去掉其中 5 个：

- SendFeedback：写进 `settings.json`；
- Workflow、ReportFindings、ListAgents、ScheduleWakeup：放进 `cl`。

只有 ScheduleWakeup 保留 `with-loop` 前缀可单次重开，核心工具不动。

**效果**：交互模式下每次请求的工具定义从 13,939 降到 7,083，`-p` 模式下整个请求从 24,834 降到 19,856。

## 修改的文件

- `zshrc_fn`：
  - `cl` 默认的 `--settings` 加入 `"enableWorkflows": false`；
  - `cl` 默认传 `--disallowedTools ReportFindings,ListAgents,ScheduleWakeup`，设置了 `CLAUDE_LOOP` 时不带 ScheduleWakeup；
  - 新增 `with-loop` 前缀；
  - 更新段落开头的注释。
- `~/.claude/settings.json`：加入 `"feedbackDrafts": "off"`，备份为 `~/.claude/settings.json.bak-20261110`。这个文件是软链接，实际文件在 iCloud 的 `zack-fair/share` 下，不在本仓库。
- `kb/notes/2026-11-03-claude-code-lean-settings-plan.md`：
  - 新增第 8 节，写清 System tools 的算法、构成、去掉的 5 个工具和验证；
  - 第 3 节的代码、用法和 `DEBUG_CL` 示例改成现状。
- `AGENTS.md`：在 `cl` 那一条补一句工具精简和 `with-loop` 的说明。

## 注意事项

- `--disallowedTools` 传多次会累加，这一点和 `--settings` 只认最后一个不同。它是可变参数，会把后面不带 `-` 的参数都当成工具名吞掉，所以后面必须紧跟一个 flag。
- 工具不能写进 `settings.json` 的 `permissions.deny`：deny 在各层配置之间是叠加的，写进去以后无法单次重开。只有确定永远不要的才写进 `settings.json`，比如 `feedbackDrafts`。
- 抓交互模式的请求时只能取第一个请求。假 API 回 400 的话，Claude Code 重试 3 次后会关掉 tool search，把全部 29 个工具完整重发（约 34k），取最大的那个会得到错误的结论。
- 单独对 deferred 占位工具调用 `count_tokens` 会返回 400，计数脚本要容忍这种失败。
- `/context` 的数字只能作为参考：System tools 少算了 skill 列表，内置 agent 列表也没有算进去。要看实际数字，需要抓包后用 `count_tokens` 计数。

## 遗留问题

- `cc-probe` 还不能抓交互模式。目前的 pty 抓包脚本在被 gitignore 的 `tmp/2026-11-10-system-tools/` 下，以后要复查交互模式的工具，可以考虑给 `cc-probe` 加一个 `--interactive`。
- 在 `cl` 下 `/code-review`（本地）和 ultracode 不可用，需要时直接运行 `claude`，或用 `cl --settings '{"enableWorkflows": true}'`。这是用户确认过的取舍。

## 相关文档

- [瘦身落地方案](../notes/2026-11-03-claude-code-lean-settings-plan.md)：更新，新增第 8 节
- [Claude Code harness 瘦身调研](../notes/2026-11-02-claude-code-harness-slimming.md)：参考
- [第一轮瘦身 session](2026-11-03-claude-code-lean-settings.md)：参考，本次沿用它的 `cl` 方案
