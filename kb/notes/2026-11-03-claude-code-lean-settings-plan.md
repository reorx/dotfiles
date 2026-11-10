---
created: 2026-11-03
tags:
  - claude-code
  - token-usage
  - settings
  - zsh
---

# Claude Code 瘦身落地方案：settings.json 改动与单次重开的 alias

背景调研见 [2026-11-02-claude-code-harness-slimming](2026-11-02-claude-code-harness-slimming.md)。本文只写落地方案：要改什么、怎么改，以及每一项是怎么验证的。第 1–7 节基于 Claude Code 2.1.311，于 2026-11-03 执行，执行后的验证见第 7 节。第 8 节是 2026-11-10 基于 2.1.321 追加的工具定义（`/context` 里的 System tools）精简。

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

因此这两项放在 shell 层，由 zsh 函数 `cl` 统一处理。`clc`、`clr`、`clfast` 等都通过 `cl` 调用，直接运行 `claude` 则保持原样：

- **Artifact**：`cl` 启动 claude 时带上 `CLAUDE_CODE_DISABLE_ARTIFACT=1`。用 `with-artifact` 前缀时，改为去掉这个变量后再启动。
- **同步 skill**：`cl` 每次都传 `--settings '{"syncClaudeAiSkills": false}'`。用 `with-ai-skills` 前缀时，这一项不再加入。

**多个 `--settings` 不会合并，只有最后一个生效**（实测见第 6 节）。现有的 `clfast` 已经在传 `--settings '{"fastMode": true}'`，所以 `cl` 会把调用方传入的所有内联 JSON 取出来，用 jq 合并成一个，最后只传一个 `--settings`。

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

`cl` 本身就是 wrapper。它固定加上 `--dangerously-skip-permissions`，`ccglm`、`clapi`、`clfast`、`clc`、`clr`、`fable` 都改为调用 `cl`。以 `zshrc_fn` 中的代码为准，核心部分如下：

```zsh
function cl() {
    local settings='{"enableWorkflows": false, "syncClaudeAiSkills": false}'
    [[ -n "$CLAUDE_AI_SKILLS" ]] && settings='{"enableWorkflows": false}'
    local -a disallowed=(ReportFindings ListAgents)
    [[ -z "$CLAUDE_LOOP" ]] && disallowed+=(ScheduleWakeup)
    # --disallowedTools 会吞掉后面不带 - 的参数，所以后面紧跟一个 flag
    local -a args=(--disallowedTools "${(j:,:)disallowed}" --dangerously-skip-permissions)
    while (( $# )); do
        if [[ "$1" == --settings && "$2" == \{* ]]; then
            settings=$(jq -c --argjson base "$settings" '$base + .' <<< "$2") || return
            shift 2
        else
            args+=("$1")
            shift
        fi
    done
    if [[ -n "$DEBUG_CL" ]]; then
        print -r -- "[cl] artifact: $([[ -n "$CLAUDE_ARTIFACT" ]] && echo on || echo off)" >&2
        print -r -- "[cl] settings: $settings" >&2
        print -r -- "[cl] args: ${(q-)args[@]}" >&2
    fi
    if [[ -n "$CLAUDE_ARTIFACT" ]]; then
        env -u CLAUDE_CODE_DISABLE_ARTIFACT claude --settings "$settings" "${args[@]}"
    else
        CLAUDE_CODE_DISABLE_ARTIFACT=1 command claude --settings "$settings" "${args[@]}"
    fi
}

function with-artifact() { (export CLAUDE_ARTIFACT=1; "$@") }
function with-ai-skills() { (export CLAUDE_AI_SKILLS=1; "$@") }
function with-loop() { (export CLAUDE_LOOP=1; "$@") }

function clfast() { cl --settings '{"fastMode": true}' $@ }
function clc() { cl --continue $@ }
function clr() { cl --resume $@ }
# ccglm、clapi、fable 同理：先设置各自的环境变量，再调用 cl
```

- 调用方传入的每个内联 JSON 都会按顺序合并进去（`$base + .`，键名冲突时后传入的为准），最终只传一个 `--settings`。JSON 写错时 jq 会报错，`cl` 直接返回，不会启动 claude。
- `with-artifact` 分支用 `env -u` 去掉 `CLAUDE_CODE_DISABLE_ARTIFACT`。这样即使当前 shell 还留着旧版本 export 的这个变量，Artifact 也能正常打开。
- `jq` 用的是系统自带的 `/usr/bin/jq`。
- 用户要求的 “alias” 实际做成了前缀函数，因为这样可以和 `cl`、`clfast`、`clr` 等任意组合，不必为每个函数各写一套。

### 用法

| 命令 | Artifact | 同步 skill |
|---|---|---|
| `cl` / `clc` / `clr` / `clfast` / `clapi` / `fable` / `ccglm` | 关 | 关 |
| `with-artifact cl`（前缀可加在上面任意命令前） | **开** | 关 |
| `with-ai-skills cl` | 关 | **开** |
| `with-artifact with-ai-skills cl` | **开** | **开** |
| `claude …`（直接运行） | 开 | 开 |

`cl` 还会去掉 5 个用不到的工具（第 8 节），其中只有 ScheduleWakeup 能用 `with-loop cl` 单次重开。

- 前缀都在子 shell 里修改环境，不会影响当前 shell。
- 在任意命令前加 `DEBUG_CL=1`（例如 `DEBUG_CL=1 with-artifact clfast`）会先打印 Artifact 状态、最终的 settings 和其余参数，然后照常启动 claude。示例：

```
[cl] artifact: on
[cl] settings: {"enableWorkflows":false,"syncClaudeAiSkills":false,"fastMode":true}
[cl] args: --disallowedTools ReportFindings,ListAgents,ScheduleWakeup --dangerously-skip-permissions
```

### 局限

- 只有通过 `cl` 及其派生命令启动时才精简。直接运行 `claude`，以及从 IDE、桌面 app、launchd 或 `zsh -c` 启动的 claude，都会加载 Artifact 和同步 skill。
- `--settings` 如果传的是文件路径而不是内联 JSON，`cl` 不会合并，而是原样保留在参数里。这时会出现两个 `--settings`，调用方的文件排在后面，最终生效，同步 skill 就不会被关掉。目前的函数里都没有这种用法。

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

这套方法后来做成了 `~/Code/scripts/cc-probe.py`（命令 `cc-probe`）。复查可以用 `cc-probe --via cl --expect-absent Artifact --expect-absent 'anthropic-skills:*'`，对比两种启动方式可以用 `--save` 加 `cc-probe diff`。

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

### 7.1 调整：wrapper 从 `claude()` 改为 `cl`，并增加 DEBUG_CL

用户希望不覆盖 `claude` 命令，所以把精简逻辑全部收进 `cl`，其他命令都改为调用 `cl`，同时增加了 `DEBUG_CL=1` 打印功能。改完后的验证：

- **假的 claude 可执行文件**：测了 `cl`、`clc`、`clr`、`clfast`、`clapi`、`fable`、`ccglm`，两个前缀单独和叠加使用，直接运行 `claude`，以及当前 shell 残留旧 export 时用 `with-artifact` 的情况。参数和环境变量都符合预期，`clapi`、`fable`、`ccglm` 写在调用前面的环境变量都能传给 claude。另外测了 `DEBUG_CL` 的输出、多个 `--settings` 的合并，以及 JSON 写错时 `cl` 会直接退出（exit 5）。
- **真实 claude 抓包**：

| 调用方式 | Artifact | anthropic-skills | searchfit | skill 总数 | fast |
|---|---|---|---|---:|---|
| `cl` | 无 | 0 | 0 | 42 | 否 |
| `with-artifact with-ai-skills clfast` | 有 | 14 | 0 | 59 | 是 |
| `claude`（直接运行） | 有 | 14 | 0 | 59 | 否 |

## 8. System tools 的构成与精简（2026-11-10，2.1.321）

起因：交互 session 里 `/context` 的 System tools 一项看起来占得很多。

### 8.1 `/context` 的 System tools 是怎么算的

2.1.321 源码的算法：把所有非 deferred 的内置工具，加上本 session 里已经通过 ToolSearch 加载过的 deferred 工具，用 `count_tokens` 计一次数，再减掉 Skills 那一行（源码为 `System tools = 工具总数 − skill 列表`）。这样算有三个偏差：

- **System tools 偏低**：skill 列表现在放在一条 system 消息里，不在 Skill 工具的描述里，减法多减了一次。数字对得上：交互模式实测工具定义共 13,939，减去 Skills 5.1k，约 8.7k，正是 `/context` 显示的数。推测是早期版本把 skill 列表写在 Skill 工具描述里时留下的逻辑，没有直接证据。
- **内置 agent 列表没算**：约 1.5k，Custom agents 只算自定义的 3 个（241）。所以 `/context` 合计显示 20.6k，实际首个请求约 28k（估算）。
- **System tools (deferred) 并不发送**：显示的 20.3k 是“全部加载时的大小”，请求里只带名字（约 170 tokens）。某个 deferred 工具被加载后，完整定义会算进 System tools，并一直留到 session 结束。较大的几个：DesignSync 3,794、Monitor 2,989、SendMessage 1,991、EnterPlanMode 1,612、RemoteTrigger 1,571、CronCreate 1,564、EnterWorktree 1,396。

### 8.2 构成（交互模式 `cl`，精简前）

逐项去掉后用 `count_tokens` 计数：

| 工具 | tokens | 用途 |
|---|---:|---|
| Workflow | 1,979 | 多 agent 编排，只在用户明确要求时使用 |
| SendFeedback | 1,956 | 起草给 Anthropic 的产品反馈 |
| AskUserQuestion | 1,766 | 向用户提问 |
| ScheduleWakeup | 1,695 | 只给不带间隔的 `/loop` 用 |
| Agent | 1,590 | 子 agent |
| Bash / Read / Skill / ToolSearch / Edit / Write | 3,348 | 核心工具 |
| ReportFindings | 821 | 把 code review 结果交给宿主 UI 渲染 |
| ListAgents | 405 | 列出可以 SendMessage 的其他 session |
| 占位工具 + 工具使用的固定前言 | ~380 | |

AskUserQuestion 和 SendFeedback 只在交互模式出现，`cc-probe`（`-p` 模式）抓不到。

### 8.3 去掉的 5 个工具

| 工具 | 省 | 关法 | 依据和代价 |
|---|---:|---|---|
| SendFeedback | 1,956 | `settings.json` 的 `"feedbackDrafts": "off"`，即 `/config` 里的 “Claude-drafted feedback”（可选 notify / quiet / off） | 不需要单次重开，所以写进 settings.json，直接运行 `claude` 也会生效 |
| Workflow | 1,979 | `cl` 的 `--settings` 默认带 `"enableWorkflows": false` | 同时隐藏 workflow-authoring skill。`cl` 下 `/code-review`（本地）和 ultracode 都不能用；需要时直接运行 `claude`，或 `cl --settings '{"enableWorkflows": true}'` |
| ScheduleWakeup | 1,695 | `cl` 默认 `--disallowedTools` | 只影响不带间隔的 `/loop`，`/loop 5m` 用的是 CronCreate。`with-loop cl` 单次重开 |
| ReportFindings | 821 | 同上 | 源码里只有桌面版、网页版（或设置了 `CLAUDE_CODE_REPORT_FINDINGS`）才让 code review 用它，终端里永远不会被调用 |
| ListAgents | 405 | 同上 | 只用于给其他 session 发消息 |

不保留重开前缀是用户的决定（只要 `with-loop`）。AskUserQuestion、Agent 和核心工具不动。

为什么不用 `settings.json` 的 `permissions.deny`：deny 规则在各层配置之间是叠加的，写进去以后无法单次重开，和 Artifact 是同一个问题；放在 `cl` 里还能让直接运行的 `claude` 保持完整。

`--disallowedTools` 的两个行为（实测）：

- 传多次会累加，所以 `cl` 加上自己的列表后，调用方还能照常再传，不需要像 `--settings` 那样合并。
- 它是可变参数，会把后面不带 `-` 的参数都当成工具名吞掉，所以 `cl` 把它放在 `--dangerously-skip-permissions` 前面。

### 8.4 验证

| 场景 | 精简前 | 精简后 |
|---|---:|---:|
| 交互模式 `cl` 的工具定义 | 13,939 | 7,083 |
| `cc-probe --via cl` 的整个请求（`-p` 模式，没有 SendFeedback） | 24,834 | 19,856 |

按预期写的检查（全部通过）：

```sh
cc-probe --via cl --expect-absent ScheduleWakeup --expect-absent ReportFindings \
  --expect-absent ListAgents --expect-absent Workflow --expect-present Bash
cc-probe --via 'with-loop cl' --expect-present ScheduleWakeup --expect-absent Workflow
cc-probe --via 'cl --disallowedTools NotebookEdit' --expect-absent NotebookEdit --expect-absent ReportFindings
cc-probe --via cl --settings '{"enableWorkflows": true}' --expect-present Workflow
cc-probe --via 'with-artifact cl' --expect-present Artifact --expect-absent ScheduleWakeup
```

交互模式的抓包方法：在 pty 里启动 `cl`，`ANTHROPIC_BASE_URL` 指向本地假 API，输入一句话后取第一个带 `system` 的请求，再逐项计数。要注意，假 API 回 400 的话，Claude Code 重试 3 次后会关掉 tool search，把全部 29 个工具完整重发一遍（约 34k）。所以只能取第一个请求，不能取最大的那个。脚本在被 gitignore 的 `tmp/2026-11-10-system-tools/interactive_capture.py` 里。

## 9. 我的最终配置（截至 2026-11-10，Claude Code 2.1.321）

本节按实际文件整理：`~/.claude/settings.json` 和 `zshrc_fn`。“来源”一列里，“之前就有”指 11-03 改动前就已存在；“你自己改的”指 11-03 之后由你手动修改，对比备份 `~/.claude/settings.json.bak-20261103` 得出。

### 9.1 效果

| 启动方式 | `-p` 抓包，整个首个请求 | 交互模式，工具定义 |
|---|---:|---:|
| `claude`（直接运行） | 41,893 | 未测，约 13.9k + Artifact 13.5k |
| `cl` | 19,856 | 7,083 |

### 9.2 `~/.claude/settings.json`：所有机器共用，`claude` 和 `cl` 都生效

| 配置 | 作用 | 来源 |
|---|---|---|
| `promptSuggestionEnabled: false` | 关闭输入框里的 prompt 建议，属于请求之外的开销 | 之前就有 |
| `disableClaudeAiConnectors: true` | 关闭 Claude Docs 等 claude.ai connector | 之前就有 |
| `syncClaudeAiPlugins: false` | 去掉 claude.ai 同步的 searchfit-seo 插件（17 个 skill、3 个 agent），文件已移到 `~/.claude/plugins/.trash` | 11-03 |
| `includeGitInstructions: false` | 去掉 Bash 工具里的 commit/PR 步骤、署名提醒和 git status 快照。副作用：commit 不再自动加 `Co-Authored-By` | 11-03 |
| `skillOverrides` 共 13 项，都是 `user-invocable-only` | 内置的 code-review、simplify、security-review、init、fewer-permission-prompts、loop、schedule、keybindings-help、run、plugin-authoring（11-03）；eli5:eli5、humanizer、swiftui-expert-skill（你自己加的）。这些 skill 不再发描述，手动输入 `/name` 照常可用 | 11-03 / 你自己改的 |
| `feedbackDrafts: "off"` | 去掉 SendFeedback 工具（交互模式 1,956） | 11-10 |
| `enabledPlugins` 去掉 code-review、code-simplifier、commit-commands | 这三个插件的 skill、command、agent 不再加载 | 你自己改的 |
| `modelSettings.claude-opus-5-5.autoCompactWindow: 400000` | Opus 的自动压缩窗口设为 400k。只改什么时候压缩，不减少每次请求的大小 | 你自己改的 |

`settings.json` 里**没有**、也**不能**有 `enableArtifact`、`syncClaudeAiSkills`、`CLAUDE_CODE_DISABLE_ARTIFACT` 和 `permissions.deny` 工具规则：这些开关是“任意一处为关就关”，或者是跨层叠加的，写进去以后就无法单次重开（第 1 节、第 8.3 节）。

### 9.3 `cl`：只对 `cl` 及其派生命令生效

派生命令有 `clc`、`clr`、`clfast`、`clapi`、`fable`、`ccglm`、`sonnet`。

| 默认去掉 | 省（tokens） | 方式 | 单次重开 |
|---|---:|---|---|
| Artifact 工具和 3 个 artifact skill | 约 13.5k | 环境变量 `CLAUDE_CODE_DISABLE_ARTIFACT=1` | `with-artifact` |
| claude.ai 同步 skill（14 个 `anthropic-skills:*`） | 约 0.9k | `--settings` 中的 `syncClaudeAiSkills: false` | `with-ai-skills` |
| Workflow 工具和 workflow-authoring skill | 1,979 + skill 描述 | `--settings` 中的 `enableWorkflows: false` | 不设前缀。需要时直接运行 `claude`，或用 `cl --settings '{"enableWorkflows": true}'` |
| ScheduleWakeup | 1,695 | `--disallowedTools` | `with-loop` |
| ReportFindings、ListAgents | 821 + 405 | `--disallowedTools` | 不设前缀 |

另外，`cl` 固定加 `--dangerously-skip-permissions`。`DEBUG_CL=1` 会打印最终参数。前缀可以叠加使用，比如 `with-artifact with-loop clr`。

### 9.4 有意保留或没有采用的

- **工具**：AskUserQuestion、Agent，以及 Bash、Read、Edit、Write、Skill、ToolSearch 这些核心工具都保留。
- **内置 skill**：dataviz、claude-api、update-config、workflow-authoring 保留自动触发（第 4.2 节）。在 `cl` 下，workflow-authoring 会随 Workflow 一起隐藏。
- **没有采用的设置**：
  - `CLAUDE_CODE_DISABLE_EXPLORE_PLAN_AGENTS=1`：Explore 和 Plan 两个内置 subagent 仍在；
  - `awaySummaryEnabled: false`：离开终端后仍会自动生成 recap；
  - `deniedMcpServers`：Claude Docs connector 已经被 `disableClaudeAiConnectors` 关掉，不需要再设。
- **无需处理**：当前版本的请求里已经没有 Grep 和 Glob；PowerShell 在 macOS 上默认就没有。

### 9.5 使用和复查时要注意

- 直接运行 `claude`，以及从 IDE、桌面 app 启动的 claude，都不经过 `cl`，只有 9.2 节的配置生效。
- `cl` session 里启动的子进程会继承 `CLAUDE_CODE_DISABLE_ARTIFACT=1`。在这样的 session 里用 `cc-probe` 测“直接运行 `claude`”时，要加 `--unset CLAUDE_CODE_DISABLE_ARTIFACT`，否则 Artifact 不会出现。本次实测：不加时是 28,504，加了是 41,893。
- Claude Code 升级后复查：

  ```sh
  cc-probe --via cl --expect-absent Artifact --expect-absent 'anthropic-skills:*' \
    --expect-absent Workflow --expect-absent ScheduleWakeup \
    --expect-absent ReportFindings --expect-absent ListAgents
  ```
