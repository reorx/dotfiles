---
created: 2026-11-02
tags:
  - claude-code
  - token-usage
  - settings
  - lean-claude
---

# Claude Code harness 瘦身：lean-claude 文章、源码分析与配置清单

起因是 ahmad ghoniem 的文章《Stretching the $20 sub by 30%: Claude Code's harness tax》（2026-10-06，[x.com/aghoniem_/status/2107236820929094094](https://x.com/aghoniem_/status/2107236820929094094)）和他配套的 `lean-claude` skill。文章的测量基于 Claude Code 2.1.284；本笔记中标为“已核实”的结论，都是在本机 2.1.311 的二进制（`~/.local/share/claude/versions/2.1.311`）里直接读到判断代码确认的。

## 结论速览

- **关掉 Artifact**：在 `~/.claude/settings.json` 顶层加 `"enableArtifact": false`。
- **PowerShell**：macOS 上默认不加载，不用做任何事。
- **对本机有用的配置**：可以直接改的有 5 项（Artifact、claude.ai 同步插件、claude.ai 同步 skill、内置 skill 改为只能手动调用、session recap），另有 2 项需要权衡（git 内置指令、compact 时机）。清单见第 5 节。
- **已经生效的**：`promptSuggestionEnabled: false` 和 `disableClaudeAiConnectors: true`。
- **lean-claude 这个 skill**：代码干净，适合跑一次当诊断工具，不必长期安装。在本机跑之前要先注意第 2.4 节列的几点。

## 1. 文章：它怎么减少首条请求的 prompt

作者用本地代理抓下每次请求实际发出的内容，再用 Anthropic 的 `count_tokens` API 逐项计数。他把系统提示词、工具定义、skill 列表、connector 说明和 git 快照统称为 harness，这部分每次请求都要付费。

- 干净安装的 Claude Code（Opus 5.5，不装 skill、插件、MCP）每次请求带 **30,875 tokens**。同样测法下 Pi 是 2,509，OpenCode 是 10,488。
- 他没有改系统提示词本身，而是把每次都带、但很少用到的东西逐项关掉，最后降到 **7,093 tokens（−77%）**。按他的估算，每周额度能多用约 15%；再加上请求之外的几项优化，合计约 30%。

### 1.1 工具

Claude Code 对大部分工具每次都完整发送名字、描述和参数；少数工具（deferred）只发名字，第一次用到时才加载完整定义。被 deny 的完整工具整个消失；deny 一个 deferred 工具只能省下它的名字，约 4–9 tokens。

| 项 | tokens（文章数据） | 理由 |
|---|---:|---|
| Artifact | 11,325（37%） | 用来生成 claude.ai 分享页，本地 HTML 可以替代；关掉时附属的 ArtifactComments、ArtifactData 一起去掉 |
| PowerShell | 3,620 | 只在 Windows 上存在 |
| ScheduleWakeup / ReportFindings / ListAgents | 1,695 / 821 / 405 | 各自只服务一个功能：不带间隔的 `/loop`、`/code-review` 的结构化结果、找其他 session 发消息 |
| Grep / Glob | 1,553 | 作者统计 98% 的搜索本来就走 Bash 的 grep/rg；配一个 `~/.ripgreprc`（`--hidden` 等）加一条“用 rg”的规则来替代 |

### 1.2 Connector

`"deniedMcpServers": [{ "serverName": "claude.ai Claude Docs" }]` 省 873 tokens。`permissions.deny` 只能去掉工具，去不掉 MCP 的 instructions；`deniedMcpServers` 两者都去掉。

### 1.3 Skill

由模型自行调用的 skill，名字和描述每次都要发送。`skillOverrides` 设成 `"user-invocable-only"` 后描述不再发送，`/name` 仍然能用。作者对 11 个内置 skill 这样处理，再加上 `enableArtifact: false` 和 `syncClaudeAiSkills: false`，skill 列表从 2,824 tokens 降到 373。

### 1.4 系统提示词和 subagent

- `includeGitInstructions: false`：去掉 Bash 描述里的 commit/PR 步骤（147）、commit 署名提醒（208），以及首条消息里的 git status 快照（200–1,500）。`attribution: false` 只去掉署名提醒。
- `CLAUDE_CODE_DISABLE_EXPLORE_PLAN_AGENTS=1`：去掉 Explore 和 Plan 两个内置 subagent（333）。
- 精简系统提示词现在已是所有模型的默认，`CLAUDE_CODE_SIMPLE_SYSTEM_PROMPT` 不再需要。

### 1.5 请求之外的开销

这些不出现在 `/context` 里，但同样计入额度：

| 项 | 占作者用量 | 处理 |
|---|---:|---|
| compact 时机 | 约 10% | 在 165k 而不是 270k 时 compact，每次调用重读的上下文更短 |
| prompt suggestion | 最多 4.6% | 关掉 |
| cache 过期后回来 | 4.1% | 离开超过一小时，回来时整段对话要重新写入 cache，费用约为读取的 40 倍。离开前先 `/compact` 可省一半 |
| session recap | 1.2% | `awaySummaryEnabled: false` |
| 一次性编辑脚本 | 约 1% | 加规则，并提供一个可复用的 patch 工具 |

## 2. lean-claude skill 的实现

仓库是 [github.com/ahmadghoniem/skills](https://github.com/ahmadghoniem/skills)，本次读的版本是 commit `7b47b73`，路径 `skills/lean-claude/`。

### 2.1 结构

- `SKILL.md`（412 行）是写给 Claude 的流程：测量 → 概览 → 用 AskUserQuestion 让用户多选 → 应用 → 复测。推荐规则写死在里面：
  - transcript 里没用过的就推荐砍；
  - 永远不砍 Bash、Read、Edit、Write、Skill、ToolSearch、Agent、SendMessage；
  - 只有当 Bash 里的搜索次数达到工具调用次数的 10 倍以上时，才建议砍 Grep/Glob。

  frontmatter 设了 `disable-model-invocation: true`，所以装上也不会占用每次请求的 token。
- `scripts/lean.mjs`（990 行，不依赖任何 npm 包）负责全部测量。**它不修改任何配置**，改 `settings.json` 是 Claude 按 SKILL.md 的指示用 Edit 工具完成的。

| 子命令 | 作用 |
|---|---|
| `report [--days N] [--json f] [--estimate]` | 算出每次请求里每一块的 token 数，并结合 transcript 统计每块的使用次数 |
| `stretch --saved N [--days N]` | 回放 transcript：每次请求少 N tokens 时额度能多用多少；同时分析 compact 时机、prompt suggestion、recap、cache 过期和编辑脚本的开销 |
| `compare before.json after.json` | 对比改前改后的两份 report，把总节省分摊到每一项改动上 |
| `capture [--out f] [--settings json]` | 只抓一次请求体 |

### 2.2 测量原理

1. **抓请求，不调用模型**：在 127.0.0.1 起一个临时 HTTP server，把 `ANTHROPIC_BASE_URL` 指向它，运行 `claude -p --no-session-persistence 'say ok'`。server 记下第一个 `/v1/messages` 请求的 body 和 header，然后返回 400 让进程退出，所以不消耗额度。
2. **按结构拆分**：系统提示词按 `# 标题` 分节；`tools` 逐个拆；`<system-reminder>` 里的 skill 列表、agent 列表、MCP instructions、CLAUDE.md 和 deferred 工具名单逐行或逐节拆。
3. **消融计数**：对每一块构造一份去掉它的请求，调用 `count_tokens`（免费，不跑模型）。用总数减去结果，就是这一块的 token 数。认证用的是第 1 步抓到的登录 header；调用失败时按 3.5 字符 ≈ 1 token 估算。
4. **开关项**：Artifact、git 指令、Explore/Plan 等 9 个开关，每个都通过 `--settings` 注入后重新抓一次请求，取前后差值。
5. **headless → 交互模式的修正**：`-p` 模式会把 deferred 工具完整发出，而交互模式只发名字。脚本从最近一份 transcript 的 `deferred_tools_delta` 记录里还原出哪些工具是 deferred，再做换算。
6. **使用统计**：遍历 `~/.claude/projects/**/*.jsonl`，统计每个工具、`Skill` 调用、手敲的 `/命令`、subagent 类型、MCP server 的使用次数，以及 Bash 里执行 grep/rg、find 的次数。另外读取 `~/.claude.json` 里的 `skillUsage`，这个累计计数不会随 transcript 删除而丢失。
7. **stretch**：按 API 价格权重重放每一次调用（cache read 0.05 或 0.1，write 1.25 或 2，output 5）。由于不知道订阅额度对 cache 怎么计权，同时给出三种口径作为区间：按 API 价格、cache read 免费、cache read 全价。

### 2.3 安全审查

- 唯一的网络调用是 `fetch(${API_BASE}/v1/messages/count_tokens)`，`API_BASE` 默认为 `api.anthropic.com`。发出去的系统提示词和 CLAUDE.md，本来每次请求就会发给 Anthropic，没有第三方会收到。
- 只写两处文件：临时目录里的 settings 片段（用完删除），以及 `--json` 指定的输出文件。没有 `eval`，也不下载代码。
- 安装命令 `npx skills add` 会先拉一个第三方 npm CLI。更稳妥的做法是直接复制文件夹，或者 clone 后直接用 `node` 运行脚本。

### 2.4 在本机运行要注意

- **transcript 在 iCloud 里，共 4.9GB、2,619 个文件**：`~/.claude/projects` 是指向 `zack-fair/share/projects` 的软链接。脚本会把这些文件完整读三遍，其中 editScripts 那一遍对每一行都做 JSON.parse；iCloud 如果开了“优化存储”，读取时还会触发下载。**一定要加 `--days 30`。**
- **会拉起 12–15 次 `claude -p`**。每次都会启动全部 MCP server（cua-computer-use、context7、shadcn 等），也会触发 SessionStart hook `herdr-agent-state.sh`，用新的 session id 向当前 herdr pane 上报状态，可能让这个 pane 的 agent 状态短暂错乱。最好在不属于 herdr 的终端里运行。
- **大约 300 次 `count_tokens` 调用**，6 路并发。OAuth 登录方式下的限流情况不清楚；被限流的项会退回估算，报告里会标出 `estimate`。
- `~/.claude/settings.json` 同样是 iCloud 共享文件的软链接，所有机器会同时生效。改之前先备份。

### 2.5 评价

- **改设置本身用不着这个 skill**：真正有用的配置就五六项，手动改几分钟就够了。
- **它的价值在于**：一是给出本机配置的精确 token 账单。本机的大头不在内置项，而在 claude.ai 同步来的插件和 skill、cua MCP 这些后加的东西，凭感觉估不准。二是 `stretch` 对 compact 时机、cache 过期、recap 的分析，这些在 `/context` 里都看不到。
- **不足**：推荐规则很机械（没用过就砍）；交互模式的数字是从 headless 测量推算出来的；SKILL.md 里有些说法已经过时（见 3.2）。
- **建议**：不安装，clone 下来跑一次：`node lean.mjs report --days 30 --json before.json` 和 `node lean.mjs stretch --saved 0 --days 30`。拿到报告后自己逐项判断。

## 3. 在 2.1.311 上核实的结果

### 3.1 设置项都还在

二进制里能找到 `enableArtifact`、`skillOverrides`（取值 `on` / `name-only` / `user-invocable-only` / `off`）、`syncClaudeAiSkills`、`syncClaudeAiPlugins`、`includeGitInstructions`、`attribution`、`awaySummaryEnabled`、`autoCompactWindow`、`deniedMcpServers`、`CLAUDE_CODE_DISABLE_EXPLORE_PLAN_AGENTS`。

### 3.2 prompt suggestion：文章的说法不对

SKILL.md 说只有环境变量 `CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION=0` 才能彻底关掉，`promptSuggestionEnabled: false` 不够。2.1.311 里的实际判断顺序如下：

```js
function eLn(){ let e = env.CLAUDE_CODE_ENABLE_PROMPT_SUGGESTION;
  if (e === false) return false;                        // 环境变量优先
  if (e === true)  return true;
  if (!growthbook("tengu_chomp_inflection")) return false; // 服务端 flag 只能关，不能强制开
  if (nonInteractive()) return false;
  ...
  return settings.promptSuggestionEnabled !== false;     // 最后看 settings
}
```

所以本机现有的 `promptSuggestionEnabled: false` 是生效的。只有当环境变量被设为 1 时才会被覆盖。

### 3.3 Artifact 的开关

```js
var U = { enableKey: "enableArtifact", legacyDisableKey: "disableArtifact",
          defaultOn: true, envDisableVar: "CLAUDE_CODE_DISABLE_ARTIFACT" };
```

- `enableArtifact` 的 schema 说明：只要 managed、`--settings`、user settings 中任意一处设为关，就是关；project 和 local settings 只能关、不能开；不设置时默认开启。
- 等价的做法：`CLAUDE_CODE_DISABLE_ARTIFACT=1`，或者 `CLAUDE_CODE_ARTIFACT=0`（内部返回 `artifact_env_off`）。旧键 `disableArtifact: true` 也仍然有效。
- `permissions.deny: ["Artifact"]` 只去掉工具，三个 artifact skill 还会留在列表里。
- Artifact 关闭后，二进制里会出现这样一条提示：“Artifacts are turned off …, so this server, which connects to Artifacts, is not connected”。也就是说，依赖 Artifact 的 MCP server 会被忽略。我猜指的是 `claude-design`，没有验证。

### 3.4 PowerShell 的开关

```js
function yv(){ let e = env.CLAUDE_CODE_USE_POWERSHELL_TOOL;
  if (OS !== "windows") return e === true;   // 非 Windows：只有显式设为 1 才开
  if (e !== undefined) return e;
  if (gitBashPath() === null) return true;   // Windows 上没有 Git Bash 时自动开启
  return growthbook("tengu_cobalt_ridge", false);
}
```

在 Windows 上设 `CLAUDE_CODE_USE_POWERSHELL_TOOL=0` 时必须装有 Git Bash，否则 Claude Code 会报 “requires a shell tool” 并拒绝启动。

### 3.5 claude.ai 同步的 skill 和插件

- `syncClaudeAiSkills: false`：写在 user settings 里时，不再下载新的 skill，已同步的（`~/.claude/skills/synced`）会被隐藏，并在下次启动时移到 `~/.claude/skills/.trash`，在 `cleanupPeriodDays` 天后删除。之后重新开启时会重新下载，而不是从 trash 恢复。这个键在 project settings 里不生效。
- `syncClaudeAiPlugins: false`：对插件（`~/.claude/plugins/synced`）的处理方式相同。

### 3.6 autoCompactWindow

可以设在顶层，也可以按模型设在 `modelSettings.<model>.autoCompactWindow`（本机已经有 `modelSettings` 块）。lean.mjs 的注释说 compact 会在比这个值低 13k 时触发（在 2.1.283 上测得，2.1.311 上未核实），所以想在 165k 时 compact，应设为 `178000`。

## 4. 操作：关闭 Artifact、关闭 PowerShell

### Artifact

在 `~/.claude/settings.json` 顶层加：

```json
"enableArtifact": false
```

- 会去掉 Artifact、ArtifactComments、ArtifactData 三个工具，以及 `artifact-design`、`artifact-capabilities`、`artifact-diagramming` 三个 skill。按文章的数据约省 1.1 万 tokens。
- 从下一个新开的 session 开始生效；当前已经打开的 session 不受影响。
- 验证方法：在新 session 里运行 `/context`，工具列表里应该没有 Artifact，skill 列表里也没有 `artifact-*`。
- Claude Code 没有把内置工具改成按需加载的设置，所以“不自动加载”只能做到彻底关闭。之后需要分享页面时，改为生成本地 HTML 文件。

### PowerShell

macOS 上什么都不用做（见 3.4）。如果同一份 settings 也在 Windows 上使用，就在 `env` 里加 `"CLAUDE_CODE_USE_POWERSHELL_TOOL": "0"`，前提是那台机器装了 Git Bash。这个配置在 Mac 上没有效果，也没有副作用。

## 5. 对本机有用的配置项

本机现状（2026-11-02）：

- `searchfit-seo` 是从 claude.ai 同步来的插件（`~/.claude/plugins/synced/…/searchfit-seo`），带 20 多个 skill、3 个 agent 和若干 command，每条都有很长的描述。
- `anthropic-skills:*` 是从 claude.ai 同步来的 skill（`~/.claude/skills/synced/…`），共 15 个：docx、pdf、pptx、xlsx、deep-research、chrome-browser、computer-use、built-in-browser、skill-creator、morning 等。
- 自己安装的插件有 code-review、code-simplifier、commit-commands、eli5、feature-dev、skill-creator、swift-lsp。

下表中本机的节省量都没有实测，需要的话用 lean.mjs 测。

### 5.1 可以直接改

| # | 配置 | 去掉什么 | 预计节省 | 代价 |
|---|---|---|---|---|
| 1 | `"enableArtifact": false` | Artifact 的三个工具和三个 skill | 约 11k（文章数据） | 不能再发布 claude.ai 页面 |
| 2 | `"syncClaudeAiPlugins": false` | searchfit-seo 的全部 skill、agent 和 command | 估计数千 tokens | 失去 SEO 工具集；本地文件会进 `.trash` |
| 3 | `"syncClaudeAiSkills": false` | `anthropic-skills:*` 的 15 条描述；其中 skill-creator 与本地插件重复 | 估计 1–2k | 失去 claude.ai 版的 docx、pdf、pptx、xlsx 等。docx 有 dockit 可以替代 |
| 4 | `skillOverrides` 设为 `user-invocable-only`（列表见下） | 只会手动输入的内置 skill 的描述 | 约 1.5–2k（文章里 11 个共 1,869） | Claude 不会再自动选用它们，手动 `/name` 照常可用 |
| 5 | `"awaySummaryEnabled": false` | 离开终端约 3 分钟后自动生成的 recap | 文章中占用量的 1.2% | 想看时手动运行 `/recap` |

第 4 项建议改为 `user-invocable-only` 的内置 skill：`code-review`、`simplify`、`security-review`、`init`、`fewer-permission-prompts`、`loop`、`schedule`、`keybindings-help`、`run`、`plugin-authoring`。

- 看情况决定：`claude-api`（描述很长，但开发 Anthropic 相关代码时需要它被自动触发）、`dataviz`（画图前会被自动加载）。
- 保持现状：`update-config`（“allow X”、“以后每次…”这类请求依赖它自动触发）、`workflow-authoring`（写 Workflow 脚本前必须先加载）。

### 5.2 需要权衡

| # | 配置 | 作用 | 权衡 |
|---|---|---|---|
| 6 | `"includeGitInstructions": false` | 去掉 commit/PR 步骤、署名提醒和首条消息里的 git 快照，约 355 加 200–1,500 tokens | 本仓库的 commit 都带 `Co-Authored-By: Claude …`，关掉后这个 trailer 不会再自动加上。要保留的话，需要在 CLAUDE.md 或 `/cm` 里自己写规则 |
| 7 | `"autoCompactWindow": 178000` | 在约 165k 时 compact，作者的数据是省约 10% 用量 | compact 次数会增加，逐字保留的上下文变短。建议先跑 `lean.mjs stretch --saved 0 --days 30`，看自己的 compact 时机数据再决定 |

### 5.3 已经生效或不适用

- `promptSuggestionEnabled: false`：已生效（见 3.2）。
- `disableClaudeAiConnectors: true`：Claude Docs 等 claude.ai connector 已关闭。
- PowerShell：macOS 不加载。
- Grep/Glob：当前 session 的工具列表里本来就没有。

### 5.4 可选的小项

- `permissions.deny` 里加 `ScheduleWakeup`（不用不带间隔的 `/loop` 时）、`ReportFindings`（`/code-review` 结果以纯文本输出也可以接受时）、`ListAgents`（跨 session 通信已经由 herdr 承担）。三项合计约 2.9k。
- `CLAUDE_CODE_DISABLE_EXPLORE_PLAN_AGENTS=1`：约 333 tokens。
- `claude-design` MCP 一直报 403 连不上。不用的话可以执行 `claude mcp remove claude-design -s user`。
- 自己的 skill 里，描述本身就写着“只在用户明确调用时使用”的（例如 `brainstorming`），也可以加进 `skillOverrides`。`grill-me`、`grilling`、`grill-with-docs` 三个功能相近，可以考虑只留一个。

### 5.5 合并后的配置片段

第 6、7 项需要权衡，没有放进去：

```json
{
  "enableArtifact": false,
  "syncClaudeAiPlugins": false,
  "syncClaudeAiSkills": false,
  "awaySummaryEnabled": false,
  "skillOverrides": {
    "code-review": "user-invocable-only",
    "simplify": "user-invocable-only",
    "security-review": "user-invocable-only",
    "init": "user-invocable-only",
    "fewer-permission-prompts": "user-invocable-only",
    "loop": "user-invocable-only",
    "schedule": "user-invocable-only",
    "keybindings-help": "user-invocable-only",
    "run": "user-invocable-only",
    "plugin-authoring": "user-invocable-only"
  }
}
```

改之前先备份 `settings.json`。它是 iCloud 共享文件，所有机器会同时生效。改完后开一个新 session，用 `/context` 对比前后的变化。

## 相关

- 文章：<https://x.com/aghoniem_/status/2107236820929094094>
- 源码：<https://github.com/ahmadghoniem/skills/tree/main/skills/lean-claude>（commit `7b47b73`）
- 文章作者提到的内置检查：`/doctor` 可以精简 CLAUDE.md，`/skill-doctor` 会列出每个 skill 的开销和使用次数
