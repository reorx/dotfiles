# Known Issues

> 当前 dotfiles 里已知、待后续处理的问题：缺陷、简化实现、未验收项、待建流程。只反映最新状态，解决了就删掉条目，经过记到 `kb/sessions/`。

## nvim：`<leader>W`（vim-suda）还没在真实 sudo 下写过 root 文件

- 记录：2026-09-28（`:w !sudo tee %` 改用 vim-suda 时发现）
- 现有验证用的是 PATH 上的假 `sudo`：它模拟「没有缓存凭据、只接受固定密码」，并通过 `--listen` 给 headless nvim 发真实按键。验证覆盖了 suda 的完整流程：`sudo -n` 失败 → `inputsecret()` 询问密码 → `sudo -S -- dd`。结果是密码正确时写入成功，错误时文件不变。真实 sudo 需要输入用户密码，所以没做端到端测试。
- 验收方法：`sudo sh -c 'echo old > /tmp/suda-check'`，用 nvim 打开这个文件并修改，按 `<leader>W`，输入密码后执行 `cat /tmp/suda-check`，应显示新内容。

## nvim：`nvim/lsp/*.lua` 与 nvim-lspconfig 同名的键冲突时，以 lspconfig 为准

- 记录：2026-09-28（把 pyright 配置移到 `nvim/lsp/pyright.lua` 时实测）
- rtp 上的合并顺序是：先 `nvim/lsp/<name>.lua`，后 nvim-lspconfig 自带的 `lsp/<name>.lua`，同名键后者覆盖前者。目前我们设置的键 lspconfig 都没有用到：pyright 的 `settings.python.analysis.autoImportCompletions`，以及 gopls 的 `on_attach`（保存时整理 import 并格式化）。所以现在都生效。
- 风险：以后 lspconfig 如果也设置了这些键，我们的值会被悄悄覆盖，不会有任何报错。表现是 pyright 又开始从整个库补全 import，或者 Go 文件保存时不再格式化。
- 处理方向：出现上述症状时，把对应文件挪到 `nvim/after/lsp/<name>.lua`。放在 `nvim/lsp/` 是用户指定的位置，这是有意的选择。

## nvim：配置的回归测试没有纳入版本管理

- 记录：2026-09-28
- 这一轮验证 nvim 配置用的 headless 测试脚本都放在 gitignore 的 `tmp/` 下，换机器或清理 `tmp/` 后就没了，下次改配置时也不会自动运行：
  - `tmp/nvim-ts/run.sh`（treesitter 解析与高亮）；
  - `tmp/nvim-task3/run.sh`（诊断显示、诊断跳转、折叠、pyright 配置、LSP 映射）；
  - `tmp/nvim-round2/`（foldlevel、vim-suda、gopls 保存钩子）；
  - `tmp/2026-09-28-winborder/capture.sh`（在 herdr pane 里抓取真实 TUI 的浮窗画面）。
- 处理方向：挑出稳定的用例，放进 `nvim/tests/`，配一个统一的入口脚本。要注意测试会加载真实配置和共享的插件目录：删除插件后如果用旧配置去跑，lazy 会把插件重新装回来。
