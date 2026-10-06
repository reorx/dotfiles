# Neovim Tree-sitter 连续报错修复

## 复现与原因

- 本机 `vim` alias 为 `nvim -p`，使用 `/opt/homebrew/bin/nvim`（0.12.5）；`~/.config/nvim` 正确链接到本仓库。
- 用真实配置运行 `nvim --headless -p nvim/init.lua readme.md '+sleep 30' '+messages' '+qa!'`，复现 11 个 parser 的编译失败：`Error during "tree-sitter build": ... ENOENT ... 'tree-sitter'`。
- Homebrew 已安装 Tree-sitter 运行库，但没有 CLI，`command -v tree-sitter` 无结果；`~/.local/share/nvim/site/parser` 为空。
- `nvim/lua/plugins/common.lua` 启动时异步安装缺失的 parser。编译失败后它们一直缺失，所以下次启动继续尝试并连续报错。相同 Neovim 和配置不代表机器上的 CLI 和 parser 安装状态相同；未检查另一台机器。

## 修复

- 执行 `HOMEBREW_NO_AUTO_UPDATE=1 brew install tree-sitter-cli`，安装 CLI 0.27.0。
- 保持 headless Neovim 运行，等待配置中的全部 11 个 parser 安装完成。
- 未修改 Lua 配置，也未升级插件。保留开始任务前已有的 `nvim/lazy-lock.json` 修改，不纳入本次提交。
- 更新安装说明，明确 CLI 与运行库的区别，并替换旧的 vim-plug/LSP 安装说明。
- 新增 `nvim/tests/treesitter.lua`，在 AGENTS.md 记录入口。

## 验证

- 修复前先运行新测试，退出码 1，提示缺少 Tree-sitter CLI。
- 修复后新测试退出码 0：11 个 parser 安装、加载和解析成功，各语言 highlights/injections/folds/indents/locals 查询可以加载，实际 FileType 事件开启 Lua 高亮及折叠。
- `nvim --headless -c 'luafile nvim/tests/markdown.lua'` 通过。
- 重新打开 Lua 和 Markdown 文件，等待后读取 `:messages`，没有输出或安装重试，退出码 0。
- 测试仅使用 headless Neovim，进程已退出，未启动浏览器或模拟器。安装辅助脚本与日志位于本地忽略目录 `tmp/2026-10-06-nvim-treesitter/`。
