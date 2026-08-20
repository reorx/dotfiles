# Herdr 插件编写指南

写给 agent 的速查指南。基于 herdr 0.8.0-preview 实测，官方文档：
- Plugins: https://herdr.dev/docs/plugins/
- Socket API: https://herdr.dev/docs/socket-api/
- CLI reference: https://herdr.dev/docs/cli-reference/

本目录下的 `herdr-navigate-line/` 是一个已验证可用的最小示例，可直接参考。

## 核心概念

- 插件 = 一个目录 + `herdr-plugin.toml` manifest + 可执行命令（Bash/Node/Python/二进制均可，无 SDK）
- **整个 herdr CLI 就是插件 API**。插件通过 `HERDR_BIN_PATH` 调用 CLI，或通过 `HERDR_SOCKET_PATH` 发原始 JSON
- v1 不支持运行时注册：actions、event hooks、panes、link handlers 全部在 manifest 里声明
- 没有官方存储 API，持久化状态自己管文件，放 `HERDR_PLUGIN_STATE_DIR`

## Manifest 模板

```toml
id = "my_plugin"                 # 允许字母数字 . : _ -
name = "My Plugin"
version = "0.1.0"
min_herdr_version = "0.7.0"      # 必填，缺失/过新会拒绝 link
description = "..."              # 可选
platforms = ["linux", "macos"]   # 缺失时 link 成功但有 warning

[[actions]]
id = "do_thing"                  # 局部 id：允许字母数字 : _ -，⚠️ 不允许点号
title = "Do thing"
command = ["sh", "do-thing.sh", "arg1"]   # argv 数组，不经过 shell，无变量展开

# 可选段落：
# [[build]]    command = [...]   # 仅 GitHub install 时执行；link 不执行
# [[startup]]  command = [...]   # server 启动/handoff 后跑一次，一次性初始化，非守护进程
# [[events]]   on = "worktree.created"  command = [...]
# [[panes]]    id/title/placement("overlay"|"popup"|"split"|"tab"|"zoomed")/width/height/command
# [[link_handlers]]  id/title/pattern(Rust regex)/action
```

关键规则：
- **action id 不能含点号**。全局限定名 = `<plugin_id>.<action_id>`，如 `navigate_line.jump_start`。想要 `foo.bar` 这样的调用名，就把 plugin id 定为 `foo`
- `command` 的 cwd 是插件目录，相对路径可用（如 `["sh", "script.sh"]`）
- 每类 id（action/pane/link_handler）在插件内必须唯一
- `contexts` 字段在文档示例中出现（如 `contexts = ["workspace"]`），可省略

## 运行时环境变量

所有 runtime command 注入：

| 变量 | 含义 |
| --- | --- |
| `HERDR_BIN_PATH` | 运行中的 herdr 二进制路径，**优先用它调 CLI**（跨 Unix socket / Windows pipe 可移植） |
| `HERDR_SOCKET_PATH` | 原始 socket 路径（Unix socket / Windows named pipe） |
| `HERDR_PLUGIN_ID` / `HERDR_PLUGIN_ROOT` | 插件 id / 插件目录（GitHub 安装的 root 是托管 checkout，勿存状态） |
| `HERDR_PLUGIN_CONFIG_DIR` | 用户可编辑配置（.env 等）放这里 |
| `HERDR_PLUGIN_STATE_DIR` | 本地运行时状态放这里 |
| `HERDR_PLUGIN_CONTEXT_JSON` | 完整调用上下文（workspace/tab/pane/worktree/agent/selected text/clicked url） |
| `HERDR_WORKSPACE_ID` / `HERDR_TAB_ID` / `HERDR_PANE_ID` | 可用时注入；**action 里用 `HERDR_PANE_ID` 拿"当前 pane"** |

额外：action 收到 `HERDR_PLUGIN_ACTION_ID`；startup/event hook 收到 `HERDR_PLUGIN_EVENT`（event hook 另有 `HERDR_PLUGIN_EVENT_JSON`）；pane 命令收到 `HERDR_PLUGIN_ENTRYPOINT_ID`。

脚本模板：

```sh
#!/bin/sh
set -eu
herdr="${HERDR_BIN_PATH:-herdr}"
exec "$herdr" pane send-keys "$HERDR_PANE_ID" "$@"
```

## 常用 CLI / socket 方法

```sh
herdr pane send-keys <PANE_ID> <KEY>...    # 组合键：ctrl+a, alt+f, shift+tab, enter, esc, f1, minus
herdr pane send-text / pane run / pane read <id> --source recent --lines 50
herdr pane split <id> --direction right --ratio 0.333
herdr notification show "title" --body "..." --sound done
herdr agent wait <id> --until done|blocked
herdr api schema --json                    # 打印完整 socket 协议 JSON Schema
herdr api snapshot                         # session 快照
```

- 组合键语法用于 `pane.send_keys`，**不接受 `prefix+` 写法**
- socket 是 newline-delimited JSON：`{"id":"r1","method":"pane.send_keys","params":{...}}`，方法名见 socket-api 文档 Raw methods 表
- 不确定 CLI 子命令用法时直接 `herdr <cmd> --help` 实测，不要猜

## 开发工作流（实测有效）

```sh
# 1. 本地开发用 link（不跑 build，server 不在运行也能注册；注册是全局的，跨 session）
herdr plugin link /abs/path/to/plugin

# 2. 校验：看输出 JSON 里有无 "warnings" 字段，actions 是否齐全
herdr plugin action list --plugin <plugin_id>

# 3. 手动触发测试（作用于当前 focused pane）
herdr plugin action invoke <plugin_id>.<action_id>

# 4. 查执行日志（排错第一步）
herdr plugin log list --plugin <plugin_id>

# 5. 卸载（只解除注册，不动文件）
herdr plugin unlink <plugin_id>
```

**验证技巧**：写完 manifest 后 link → action list → unlink 一轮，即可确认 manifest 合法且无 warning，不留任何状态。

manifest 改动后需要重新 link 吗？link 记录的是 manifest 路径，server 启动时重读；开发中改了 manifest 后 unlink + link 一次最稳妥。

## 绑定按键

在 herdr `config.toml`：

```toml
[[keys.command]]
key = "prefix+a"
type = "plugin_action"
command = "navigate_line.jump_start"   # 全局限定 action id
description = "send ctrl+a to pane"
```

改完按 `prefix+shift+r` 重载配置。

## 已验证案例：prefix key 冲突转发

问题：prefix 设为 `ctrl+a` 时，shell 里的 readline "跳行首"被 herdr 吃掉。
方案：action 脚本对 `HERDR_PANE_ID` 执行 `pane send-keys ctrl+a`，再把 action 绑到 `prefix+a`（按两次 ctrl+a 透传，同 tmux 惯例）。见 `herdr-navigate-line/`。

## 发布（可选）

- GitHub 仓库 + topic `herdr-plugin`，manifest 放根目录或子目录，自动进入 marketplace（30 分钟刷新）
- 用户安装：`herdr plugin install owner/repo[/subdir]`（仅 GitHub shorthand；install 会跑 `[[build]]`）
- v1 无 update 命令，重新 install 即刷新
