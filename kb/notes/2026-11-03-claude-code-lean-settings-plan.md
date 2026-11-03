---
created: 2026-11-03
tags:
  - claude-code
  - token-usage
  - settings
  - zsh
---

# Claude Code 瘦身落地方案：settings.json 改动与单次重开的 alias

背景调研见 [2026-11-02-claude-code-harness-slimming](2026-11-02-claude-code-harness-slimming.md)。本文只写落地方案：要改什么、怎么改，以及每一项是怎么验证的。基于 Claude Code 2.1.311。本方案已于 2026-11-03 执行，执行后的验证见第 7 节。

## 需求

| 项 | 决定 | 附加要求 |
|---|---|---|
| Artifact | 默认关闭 | 能在单次运行中重新打开 |
| claude.ai 同步插件（`syncClaudeAiPlugins`） | 关闭 | 无 |
| claude.ai 同步 skill（`syncClaudeAiSkills`） | 默认关闭 | 能在单次运行中重新打开 |
| 内置 skill 改为 `user-invocable-only` | 采纳 | 列出受影响 skill 的完整清单（见第 4 节） |
| `includeGitInstructions: false` | 采纳 | 无 |

## 1. 为什么这两项不写进 settings.json

Artifact 和同步 skill 的开关都是**只要任意一处配置为关，结果就是关**。如果写进 `~/.claude/settings.json`，就无法再用 `--settings` 或环境变量在单次运行中把它们打开。

- **Artifact**：2.1.311 里的判断函数会收集所有“关”的来源，只有一个都没有时才开启。会被算作“关”的来源有：
  - 任意 settings 层里的 `enableArtifact: false`；
  - 进程环境、全局配置、policy，以及 flag 或 user settings 的 `env` 中的 `CLAUDE_CODE_DISABLE_ARTIFACT`。

  所以 user settings 里一旦写了关，`--settings '{"enableArtifact": true}'` 就不起作用。
- **同步 skill**：判断函数 `Lcr("syncClaudeAiSkills")` 会检查 policy、flag、user、local 等所有层，只要有一层为 `false` 就关闭。schema 说明里也写明 “Only false is honored”，设为 `true` 没有任何作用。另外，写在 user settings 里时，已同步的 skill 会在下次启动时被移到 `~/.claude/skills/.trash`，重新开启后需要重新下载。如果改为通过 `--settings` 传入，就只对这一次运行生效，不会移动文件。

因此这两项放在 shell 层处理：

- **Artifact**：在 zsh 里 `export CLAUDE_CODE_DISABLE_ARTIFACT=1`。需要重新打开时，在子 shell 里 unset 这个变量。
- **同步 skill**：用一个 zsh 函数 `claude()`，在每次调用时注入 `--settings '{"syncClaudeAiSkills": false}'`。需要重新打开时，设置一个标记变量让函数跳过注入。

**多个 `--settings` 不会合并，只有最后一个生效**（实测见第 6 节）。现有的 `clfast` 已经在传 `--settings '{"fastMode": true}'`，所以 wrapper 遇到调用方自带内联 JSON 时，会用 jq 把两者合并，而不是再追加一个 `--settings`。

## 2. 改动一：`~/.claude/settings.json`

先备份。这个文件软链接到 iCloud 的 `zack-fair/share/settings.json`，所有机器共用。

```sh
cp "$(readlink ~/.claude/settings.json)" ~/.claude/settings.json.bak-20261103
```

在顶层加入以下三个键，其他配置保持不变：

```json
{
  "syncClaudeAiPlugins": false,
  "includeGitInstructions": false,
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

**不要**加 `enableArtifact` 和 `syncClaudeAiSkills`，原因见第 1 节。`env` 块里也**不要**加 `CLAUDE_CODE_DISABLE_ARTIFACT`：user settings 的 `env` 同样会被算作“关”的来源，加了之后 `with-artifact` 就无法再打开 Artifact。

各项的影响：

- `syncClaudeAiPlugins: false`：去掉 searchfit-seo 插件的 17 个 skill、3 个 agent 和它的 command。下次启动时，插件文件会被移到 `~/.claude/plugins/.trash`，在 `cleanupPeriodDays`（60 天）后删除。以后重新开启需要重新下载。
- `includeGitInstructions: false` 会去掉三样东西：
  - Bash 工具描述里的 commit/PR 步骤；
  - commit 署名提醒；
  - 首条消息里的 git status 快照（分支、git 用户、改动文件、最近 5 条 commit）。

  **副作用**：Claude 不会再自动在 commit 末尾加 `Co-Authored-By: Claude …`。`~/.claude/commands/cm.md` 和 `cmp.md` 里也没有写这一行。如果还想保留这个 trailer，需要在 `/cm`、`/cmp` 里自己加。
- `skillOverrides`：完整清单见第 4 节。

## 3. 改动二：`zshrc_fn`（dotfiles 仓库）

加在 `zshrc_fn` 的 `# claude code` 段落里、`function cl()` 之前。现有的 `cl`、`clapi`、`clfast`、`clc`、`clr`、`fable`、`ccglm` 都不用改，它们都调用 `claude`，会自动经过下面这个函数。

```zsh
# Artifact 和 claude.ai 同步 skill 默认关闭，可以单次重新打开。
# 这两个开关都是“任意一处为关就关”，写进 settings.json 后无法单次覆盖，所以放在 shell 层：
# Artifact 用环境变量，同步 skill 用 --settings（只作用于这一次运行）。
# 多个 --settings 只有最后一个生效，所以遇到调用方自带内联 JSON 时用 jq 合并。
export CLAUDE_CODE_DISABLE_ARTIFACT=1

function claude() {
    local lean='{"syncClaudeAiSkills": false}'
    [[ -n "$CLAUDE_AI_SKILLS" ]] && lean='{}'
    local -a args=("$@")
    local i
    for (( i = 1; i < $#args; i++ )); do
        if [[ "${args[i]}" == --settings && "${args[i+1]}" == \{* ]]; then
            args[i+1]=$(jq -c --argjson lean "$lean" '$lean + .' <<< "${args[i+1]}") || return
            command claude "${args[@]}"
            return
        fi
    done
    command claude --settings "$lean" "$@"
}

# 前缀用法，可以叠加：with-artifact cl、with-ai-skills clfast、with-artifact with-ai-skills cl
function with-artifact() { (unset CLAUDE_CODE_DISABLE_ARTIFACT; "$@") }
function with-ai-skills() { (export CLAUDE_AI_SKILLS=1; "$@") }
```

- `jq` 用的是系统自带的 `/usr/bin/jq`。合并规则是 `$lean + .`，键名冲突时以调用方传入的为准。
- 用户要求的 “alias” 实际做成了前缀函数，因为这样可以和现有的 `cl`、`clfast`、`clr` 等任意组合，不必为每个函数各写一套。

### 用法

| 命令 | Artifact | 同步 skill |
|---|---|---|
| `cl` / `clfast` / `clr` / `claude …` | 关 | 关 |
| `with-artifact cl` | **开** | 关 |
| `with-ai-skills cl` | 关 | **开** |
| `with-artifact with-ai-skills cl` | **开** | **开** |

两个前缀都在子 shell 里修改环境，不会影响当前 shell。

### 局限

- 只对交互式 zsh 生效，也就是 `.zshrc` 里 source 了 `zshrc_fn` 的情况。从 IDE、桌面 app、launchd 或 `zsh -c` 启动的 claude 不经过这个函数，Artifact 和同步 skill 仍然会加载。需要覆盖这些场景时，可以把 `export CLAUDE_CODE_DISABLE_ARTIFACT=1` 挪到 `~/.zshenv`，但同步 skill 那部分没法这样覆盖。
- `--settings` 如果传的是文件路径而不是内联 JSON，wrapper 不会合并，仍会在前面插入自己的 `--settings`，结果是调用方的文件生效，同步 skill 不会被关掉。目前的函数里都没有这种用法。

## 4. `skillOverrides` 影响的 skill 完整清单

`user-invocable-only` 的含义是：skill 的名字和描述不再发给模型，Claude 不会自己选用它，但手动输入 `/name` 照常可用。下表中的描述长度取自本机一次 headless 抓包，10 个合计约 3,400 字符，约 1k tokens。

### 4.1 改为 `user-invocable-only` 的 10 个内置 skill

| skill | 用途 | 改后的影响 |
|---|---|---|
| `code-review` | 审查当前 diff 或 PR 的正确性问题 | 只能 `/code-review` 触发。描述 1,227 字符，是这组里最长的 |
| `simplify` | 审查改动代码的复用、简化，并直接修改 | 只能 `/simplify` 触发 |
| `security-review` | 对当前分支的改动做安全审查 | 只能 `/security-review` 触发 |
| `init` | 生成 CLAUDE.md | 只能 `/init` 触发 |
| `fewer-permission-prompts` | 扫描 transcript，生成权限 allowlist | 只能手动触发 |
| `loop` | 按间隔重复执行 prompt | 只能 `/loop` 触发。说“每 5 分钟检查一次”这类话时，Claude 不会自动套用它 |
| `schedule` | 创建云端定时 agent（routines） | 只能 `/schedule` 触发。说“明天 3 点跑一次”时不会自动套用 |
| `keybindings-help` | 修改 `~/.claude/keybindings.json` | 只能手动触发。让 Claude 改快捷键时它不会主动加载，但仍可以直接改文件 |
| `run` | 启动并操作当前项目的 app 来查看效果 | 只能 `/run` 触发。说“跑起来看看”时不会自动加载 |
| `plugin-authoring` | 编写 Claude Code 的 mod，比如面板、状态栏、hook | 只能手动触发 |

`code-review` 这个 key 只匹配内置的 `code-review`，不影响插件提供的 `code-review:code-review`。抓包确认后者仍在列表里。

### 4.2 保持不变的 4 个内置 skill

| skill | 不改的原因 |
|---|---|
| `update-config` | “allow X”、“以后每次…”这类请求需要 Claude 自动加载它，才能正确修改 settings 和 hook |
| `workflow-authoring` | 写 Workflow 脚本前必须加载，由模型触发 |
| `claude-api` | 写 Anthropic SDK 相关代码时需要自动触发 |
| `dataviz` | 画图表前需要自动加载。描述有 1,436 字符，想省的话可以以后再加进 override |

### 4.3 被其他开关去掉的 skill（与 skillOverrides 无关）

| 来源 | 去掉的 skill | 由谁控制 |
|---|---|---|
| Artifact 附带 | `artifact-design`、`artifact-diagramming`、`artifact-capabilities` | `CLAUDE_CODE_DISABLE_ARTIFACT`，`with-artifact` 时会恢复 |
| claude.ai 同步 skill（14 个） | `anthropic-skills:` 前缀下的 artifact-emulator、built-in-browser、chrome-browser、computer-use、deep-research、docs、docx、import-memory、morning、pdf、pptx、setup-writing-style、skill-creator、xlsx | wrapper 的 `syncClaudeAiSkills`，`with-ai-skills` 时会恢复 |
| claude.ai 同步插件 searchfit-seo（17 个） | `searchfit-seo:` 前缀下的 create-content、create-topic、generate-schema、keyword-cluster、seo-check、translate-content、ai-visibility、broken-links、content-brief、content-strategy、content-translation、internal-linking、keyword-clustering、on-page-seo、schema-markup、seo-audit、technical-seo；另有 3 个 agent：competitor-analyzer、content-strategist、seo-auditor | `syncClaudeAiPlugins: false`，永久关闭 |

### 4.4 不受影响的

- 自己安装的 skill（`~/.claude/skills/` 下的 agent-browser、kb、herdr、envops 等，共 25 个）和 command（cm、cmp、refine-plan、update-plan-and-cm）。
- 插件 skill：`code-review:code-review`、`commit-commands:*`、`feature-dev:feature-dev`、`eli5:eli5`、`skill-creator:skill-creator`。

### 4.5 合计

headless 抓包中的 skill 从 86 个降到 42 个，算式为 86 − 3 − 14 − 17 − 10 = 42。

预计每次请求节省（按 3.5 字符 ≈ 1 token 估算）：

| 项 | 预计节省 |
|---|---|
| Artifact 工具 | 约 10.9k（JSON 共 38,279 字符，和文章的 11,325 一致） |
| artifact skill | 约 0.3k |
| anthropic-skills | 约 0.9k |
| searchfit-seo skill | 约 1.3k，另有 agent 和 command 未计入 |
| 10 个 override | 约 1k |
| git 指令和快照 | 0.5–1.9k |
| **合计** | **约 15k+** |

## 5. 执行后的验证

1. 打开新终端，确认 `zshrc_fn` 已重新加载，然后运行 `cl` 开一个新 session。
2. 在 session 里运行 `/context`：工具列表中应该没有 Artifact；skill 列表中应该没有 `artifact-*`、`anthropic-skills:*`、`searchfit-seo:*`，也没有第 4.1 节的 10 个；首条消息里不应再有 gitStatus。
3. 在另一个终端运行 `with-artifact with-ai-skills cl`，再看 `/context`，Artifact 和 `anthropic-skills:*` 应该重新出现。
4. 运行 `clfast`，确认 fast 模式仍然开启。

## 6. 验证记录（2026-11-03，2.1.311）

测试方法：在 scratchpad 里写了一个 probe 脚本。它把 `ANTHROPIC_BASE_URL` 指向本地 server，用 `claude -p --no-session-persistence --strict-mcp-config` 发起请求，只记录第一个请求、不调用模型。运行时去掉了 `HERDR_*` 环境变量，避免触发 herdr hook。headless 模式默认不带 Artifact，所以统一设置 `CLAUDE_CODE_ARTIFACT=1`。

| 用例 | Artifact 工具 | artifact skill | anthropic-skills | searchfit | git 快照 | 结论 |
|---|---|---|---|---|---|---|
| 基线 | 有 | 3 | 14 | 17 | 有 | 共 86 个 skill |
| `CLAUDE_CODE_DISABLE_ARTIFACT=1` | 无 | 0 | 14 | 17 | 有 | 环境变量同时去掉工具和 skill |
| `CLAUDE_CODE_DISABLE_ARTIFACT=`（空串）或 `=0` | 有 | 3 | 14 | 17 | 有 | 空串或 0 不会关闭 |
| `--settings '{"syncClaudeAiSkills":false}'` | 有 | 3 | **0** | 17 | 有 | 单次关闭同步 skill 有效 |
| `--settings A --settings B`（A 关 git，B 关同步） | 有 | 3 | 0 | 17 | **有** | **只有最后一个 `--settings` 生效** |
| 同上，顺序反过来 | 有 | 3 | 14 | 17 | 无 | 同上 |
| 第 2 节的三个键（通过 `--settings` 注入） | 有 | 3 | 14 | **0** | **无** | 共 59 个 skill，正好少了 17 + 10，override 的名字全部正确 |
| 合并后的 `{"syncClaudeAiSkills":false,"fastMode":true}` 加上关 Artifact 的环境变量 | 无 | 0 | 0 | 17 | 有 | 合并后的 JSON 有效，请求里 `speed: "fast"` 仍在 |

另外用一个假的 `claude` 可执行文件测了 wrapper 的参数拼接。`cl`、`clfast`、两个前缀单独及叠加使用、`claude mcp list` 都符合预期，父 shell 的环境变量也不受影响。真实二进制执行 `claude --settings '{…}' mcp --help` 和 `plugin --help` 的退出码都是 0，说明子命令前面带 `--settings` 不会报错。

## 7. 执行后的验证（2026-11-03）

执行内容：备份 `~/.claude/settings.json`（备份文件为 `~/.claude/settings.json.bak-20261103`），加入第 2 节的三个键；把第 3 节的代码块加进 `zshrc_fn`。

验证方法：用 `zsh -f -c 'source zshrc_fn; <前缀> claude …'` 调用 wrapper，加载的是真实的 settings，并用 probe 抓取请求。

| 调用方式 | Artifact | anthropic-skills | searchfit | git 快照 | skill 总数 | fast |
|---|---|---|---|---|---:|---|
| `claude` | 无 | 0 | 0 | 无 | 42 | 否 |
| `with-artifact claude` | 有（含 3 个 skill） | 0 | 0 | 无 | 45 | 否 |
| `with-ai-skills claude` | 无 | 14 | 0 | 无 | 56 | 否 |
| `with-artifact with-ai-skills claude` | 有 | 14 | 0 | 无 | 59 | 否 |
| `claude --settings '{"fastMode": true}'`（即 clfast 的写法） | 无 | 0 | 0 | 无 | 42 | 是 |

- 首次启动后，searchfit-seo 已被移到 `~/.claude/plugins/.trash`。
- `~/.claude/skills/synced` 里的同步 skill 文件仍在，因为它们只是通过 `--settings` 被隐藏，所以 `with-ai-skills` 可以立即打开，不需要重新下载。
- 尚未在交互式 session 里用 `/context` 检查。
