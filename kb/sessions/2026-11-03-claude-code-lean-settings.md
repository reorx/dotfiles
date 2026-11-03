---
created: 2026-11-03
tags:
  - claude-code
  - token-usage
  - settings
  - zsh
---

# Claude Code 瘦身：精简每次请求的 harness，Artifact 和同步 skill 可以单次重开

## 概要

起因是一篇讲 Claude Code harness 开销的文章，以及作者配套的 lean-claude skill。读完文章和源码后，我们确定了要去掉的项：

- Artifact
- claude.ai 同步插件（searchfit-seo）
- claude.ai 同步 skill（anthropic-skills）
- 10 个只会手动调用的内置 skill 的描述
- 内置 git 指令

用户还要求 Artifact 和同步 skill 能在单次运行中重新打开。读 2.1.311 的源码发现，这两个开关都是“任意一处配置为关就关”：一旦写进 `settings.json`，就无法单次覆盖。所以它们改放在 shell 层：

- Artifact 用环境变量 `CLAUDE_CODE_DISABLE_ARTIFACT`；
- 同步 skill 由 `zshrc_fn` 里的 `claude()` 函数注入 `--settings`；
- 用 `with-artifact`、`with-ai-skills` 两个前缀单次重新打开。

实测还发现多个 `--settings` 不会合并，只有最后一个生效，所以 wrapper 遇到调用方自带的内联 JSON 时用 jq 合并，`clfast` 因此不用改。

最终效果：headless 抓包中 skill 从 86 个降到 42 个，Artifact 工具（约 10.9k tokens）和 git 快照都不再出现。预计每次请求节省 15k tokens 以上。

## 修改的文件

- `zshrc_fn`：新增 `export CLAUDE_CODE_DISABLE_ARTIFACT=1`、`claude()` wrapper，以及 `with-artifact`、`with-ai-skills` 两个前缀函数。
- `~/.claude/settings.json`：不在本仓库，是软链接，实际文件在 iCloud 的 `zack-fair/share` 下。新增 `syncClaudeAiPlugins: false`、`includeGitInstructions: false`，以及 10 个 `skillOverrides`。备份文件为 `~/.claude/settings.json.bak-20261103`。
- `kb/notes/2026-11-02-claude-code-harness-slimming.md`：上一轮的调研笔记。本次更正了 searchfit-seo（17 个）和 anthropic-skills（14 个）的数量，并标注其中的配置片段已被新方案取代。
- `kb/notes/2026-11-03-claude-code-lean-settings-plan.md`：新建落地方案，包含受影响 skill 的完整清单和验证记录。
- `AGENTS.md`：新增一行，说明 `zshrc_fn` 里的 claude wrapper 及其约束。

## 注意事项

- `enableArtifact`、`syncClaudeAiSkills` 和 `CLAUDE_CODE_DISABLE_ARTIFACT` 都**不能**写进 `~/.claude/settings.json`，`env` 块也不行，否则 `with-artifact`、`with-ai-skills` 会失效。判断代码见笔记第 1 节和第 3.3 节。
- 多个 `--settings` 只有最后一个生效。新写的 claude 函数如果要传 `--settings`，要用内联 JSON，让 wrapper 来合并。如果传的是文件路径，wrapper 无法合并，同步 skill 就不会被关掉。
- 把 `syncClaudeAiPlugins` 或 `syncClaudeAiSkills` 写进 user settings 时，同步来的文件会被移到 `.trash`，之后重新开启需要重新下载。通过 `--settings` 关闭则只是隐藏文件。
- 验证 harness 内容时，可以把 `ANTHROPIC_BASE_URL` 指向本地 server，只抓取第一个请求，不调用模型。需要配合：
  - `--strict-mcp-config`：跳过 MCP；
  - 去掉 `HERDR_*` 环境变量：避免触发 herdr hook；
  - headless 模式下设置 `CLAUDE_CODE_ARTIFACT=1`：否则请求里不会带 Artifact。

## 遗留问题

- 关闭 git 指令后，commit 末尾不会再自动加 `Co-Authored-By: Claude …`。如果需要保留，要在 `/cm`、`/cmp` 里加上。
- 尚未在交互式 session 里用 `/context` 检查实际效果，目前只有 headless 抓包验证。
- 从 IDE、桌面 app 或非交互 shell 启动的 claude 不经过这个 wrapper，仍会加载 Artifact 和同步 skill。这是有意的取舍。

## 相关文档

- [Claude Code harness 瘦身调研](../notes/2026-11-02-claude-code-harness-slimming.md)：参考并更新
- [瘦身落地方案](../notes/2026-11-03-claude-code-lean-settings-plan.md)：新建，本次按它执行
