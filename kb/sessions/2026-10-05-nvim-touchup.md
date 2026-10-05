---
created: 2026-10-05
tags:
  - neovim
  - markdown
  - testing
---

# Markdown 渲染插件替换为 touchup.nvim

## 概要

用户反馈 Markdown 渲染干扰字符定位，并决定移除 render-markdown.nvim。替换为 touchup.nvim，保留源码与 Treesitter 高亮，通过颜色、背景和覆盖装饰美化文本。Markdown 窗口在 FileType、BufWinEnter 时设置 conceallevel=0，避免继承其他窗口的隐藏设置。新插件已安装，旧插件已移出本机 lazy 插件目录，锁文件固定 touchup 提交 9464d6ca5775e8603b37b36500e5d9a4ab6d57cb。

## 修改的文件

- `nvim/lua/plugins/languages.lua`：替换插件并设置 Markdown 窗口显示规则。
- `nvim/lazy-lock.json`：删除 render-markdown 锁定项，加入 touchup。
- `nvim/tests/markdown.lua`：可重复运行的 Markdown 显示回归测试。
- `kb/known-issues.md`：删除已解决的 Markdown 显示问题，明确其他历史测试仍未纳入版本管理。
- `AGENTS.md`：添加项目目录与测试入口的简要说明。

## 注意事项

- 先运行回归用例，旧配置在「完整源码可见」断言处失败；替换后通过。运行方式：`nvim --headless -c 'luafile nvim/tests/markdown.lua'`。检查源码可见、移动光标不改变链接后缀列位置、窗口切换恢复 conceallevel=0、源码未改变及 Treesitter 高亮仍生效。
- Ghostty 中使用真实配置验收：touchup 已加载，旧 RenderMarkdown 命令不存在；URL、强调标记和代码围栏仍显示。光标在六处之间移动时，链接后缀显示列始终为 58。
- 截图与 GUI 检查结果归档在本地忽略目录 `tmp/2026-10-05-nvim-markdown/`，最终截图为 `touchup-window.png`，检查结果为 `gui-report.json`。测试窗口在验收后关闭。
- touchup 使用默认选项，包括列表续写；不再隐藏 URL 或语法标记，也不插入表格对齐空格。

## 已解决的已知问题

- **nvim：Markdown 渲染时文字位置变化，干扰定位和编辑**：用 touchup 替换 render-markdown，并确保 conceallevel=0；通过回归测试、真实终端显示列检查和截图验收。

## 遗留问题

无本次替换产生的遗留问题；已有非 Markdown 配置的历史回归脚本仍在本地 tmp 目录。
