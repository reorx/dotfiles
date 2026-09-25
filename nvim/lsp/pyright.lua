-- Merged with nvim-lspconfig's lsp/pyright.lua, see :help lsp-config-merge
---@type vim.lsp.Config
return {
  settings = {
    python = {
      analysis = {
        -- disable auto import so that it won't complete from the whole library
        autoImportCompletions = false,
      },
    },
  },
}
