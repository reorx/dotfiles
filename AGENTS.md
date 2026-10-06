# Dotfiles

本仓库管理本机的终端、编辑器及其他工具配置。

- `nvim/`：Neovim 配置，入口是 `init.lua`；本机 `~/.config/nvim` 链接到此目录。插件由 lazy.nvim 管理并通过 `lazy-lock.json` 锁定。
- Markdown 显示的回归检查：在仓库根目录执行 `nvim --headless -c 'luafile nvim/tests/markdown.lua'`。
- Tree-sitter 回归检查：parser 安装完成后执行 `nvim --headless -c 'luafile nvim/tests/treesitter.lua'`；macOS 编译 parser 需要单独安装 `brew install tree-sitter-cli`。
- `kb/known-issues.md`：修改相关配置前查看已有问题；`kb/sessions/` 保存变更和验证记录。
