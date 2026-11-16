---
created: 2026-11-16
tags:
  - neovim
  - nvim-tree
  - keymap
  - testing
---

# nvim-tree 打开文件后自动隐藏，确认 `<leader>e` 为目录树开关

## 概要

用户提出两点需求：一是在目录树里按回车打开文件后，目录树自动隐藏，不再留在左侧；二是把目录树快捷键从 Ctrl+1 换成 leader 组合（例如 `<leader>f` 或 `<leader>t`），打开时光标定位到当前文件。经检查，Ctrl+1 早在 cd2ffe9（2026-08-20）就已改为 `<leader>e`，`<C-1>..<C-9>` 映射为 `<Nop>`，留给 herdr 使用。`<leader>e` 执行的是 `NvimTreeFindFileToggle`，本来就会展开到当前文件并把焦点移到目录树。导出全部 leader 映射后确认：`<leader>f` 已用于当前 buffer 模糊搜索（n/x 两个模式），`<leader>t` 是 `<leader>tn`/`<leader>tc` 的前缀。用作单键会产生前缀冲突，按下后要等 `timeoutlen` 才触发。`<leader>e` 没有冲突，也和 LazyVim 等发行版的 explorer 约定一致，所以保留不改。第一点需求通过开启 nvim-tree 的 `actions.open_file.quit_on_open` 实现。

## 修改的文件

- `nvim/lua/plugins/common.lua`：nvim-tree 开启 `actions.open_file.quit_on_open = true`，并注释说明选用 `<leader>e` 的原因。
- `nvim/tests/nvim_tree.lua`：新增行为测试。用 `--embed --headless` 启动一个加载真实配置的子 nvim，直接打开临时目录（相当于 `nvim <dir>`），再用 `nvim_input` 发送真实按键，验证以下行为：从目录启动后回车打开文件会隐藏目录树，文件占满整个 tab；`<leader>e` 打开目录树后光标落在当前文件上（包括未展开子目录里的文件）；在目录树里再按 `<leader>e` 会关闭目录树；从侧边栏回车打开文件同样会隐藏目录树；`<leader>e` 和其他普通模式映射没有前缀冲突。
- `AGENTS.md`：记录新测试入口。

## 注意事项

- 测试 TDD 顺序：先在旧配置上运行，在「<CR> must hide the tree」处失败（退出码 1），加配置后通过。另外做了一次变异检查：把映射临时改成 `NvimTreeToggle`，测试会在「put the cursor on the current file」处失败。这说明定位断言确实有效。
- 子进程 + RPC 的写法可以覆盖 `nvim <dir>` 启动时 nvim-tree 接管目录的路径。在当前进程里执行 `:edit <dir>` 走的是另一条代码路径（BufEnter 接管），不能代替。临时目录要先 `fs_realpath`，否则 macOS 的 `/var` → `/private/var` 会导致路径比较失败。
- `quit_on_open` 对 `edit`/`vsplit`/`split`/`tabnew`/`drop` 等打开方式都生效；`<C-e>`（edit_in_place）会直接替换目录树所在的 buffer，不受这个选项影响。
- 回归：`nvim/tests/markdown.lua` 与 `nvim/tests/treesitter.lua` 仍然通过。leader 映射导出脚本和结果放在本地忽略目录 `tmp/2026-11-16-nvim-tree-autoclose/`。

## 遗留问题

- 只做了 headless 验证，没有在真实终端里看画面；按键走的是 nvim 的真实输入队列（which-key 也参与），行为层面已经覆盖。
