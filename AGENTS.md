# Dotfiles

本仓库管理本机的终端、编辑器及其他工具配置。

- `herdr/`：Herdr 配置及本地插件；`config.toml` 链接到本机配置，修改后用 `herdr config check` 校验、`herdr server reload-config` 热重载。有 `override.<machine>.toml` 的机器（如 maiev）通过 `HERDR_CONFIG_PATH` 读取生成的 `~/.config/herdr/config.<machine>.toml`，不读 `config.toml`。改完 `config.toml` 要先执行 `uv run herdr/override_config.py <machine>` 再 reload，否则新绑定不会生效，旧绑定也可能指向已改名的插件。自用插件 herdr-kit（plugin id `kit`，按键透传、pane/tab、agent、workspace 工具）及已有内置导航操作见 `herdr/herdr-kit/README.md`。修改 workspace picker 后运行 `python3 herdr/herdr-kit/tests/test_workspace_picker.py`，修改 split picker（`prefix+v` 新 pane 布局浮窗）后运行 `python3 herdr/herdr-kit/tests/test_split_picker.py`。
- `nvim/`：Neovim 配置，入口是 `init.lua`；本机 `~/.config/nvim` 链接到此目录。插件由 lazy.nvim 管理并通过 `lazy-lock.json` 锁定。
- Markdown 显示的回归检查：在仓库根目录执行 `nvim --headless -c 'luafile nvim/tests/markdown.lua'`。
- Tree-sitter 回归检查：parser 安装完成后执行 `nvim --headless -c 'luafile nvim/tests/treesitter.lua'`；macOS 编译 parser 需要单独安装 `brew install tree-sitter-cli`。
- `zshrc_fn` 的 claude 段落：`claude()` wrapper 默认关闭 Artifact（环境变量 `CLAUDE_CODE_DISABLE_ARTIFACT`）和 claude.ai 同步 skill（注入 `--settings`，遇到调用方自带的内联 JSON 时用 jq 合并），`with-artifact`、`with-ai-skills` 前缀可单次重开。不要把 `enableArtifact`、`syncClaudeAiSkills` 或这个环境变量写进 `~/.claude/settings.json`：这两个开关是“任意一处为关就关”，写进去后无法单次重开。详见 `kb/notes/2026-11-03-claude-code-lean-settings-plan.md`。
- `kb/known-issues.md`：修改相关配置前查看已有问题；`kb/sessions/` 保存变更和验证记录。
