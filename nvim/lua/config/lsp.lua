-- Configure a server via `vim.lsp.config()` or `{after/}lsp/lua_ls.lua`

require("mason").setup()
require("mason-lspconfig").setup() -- Note: `nvim-lspconfig` needs to be in 'runtimepath' by the time you setup
