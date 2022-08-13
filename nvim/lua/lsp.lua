-- References:
-- * https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization


-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '<space>p', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', '<space>n', vim.diagnostic.goto_next, opts)

-- hover doc
-- https://neovim.io/doc/user/lsp.html#vim.lsp.buf.hover%28%29
-- According to :help vim.lsp.buf.hover(), you should be able to jump into the floating window by calling the function twice in a row (or pressing K twice in your case)
vim.keymap.set("n", 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', '<space>D', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', '<space>d', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>g', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>F', vim.lsp.buf.formatting, bufopts)
end


-- Setup lsp installer
require("nvim-lsp-installer").setup {}


-- Setup lspconfig.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local lspconfig = require('lspconfig')
lspconfig['pyright'].setup{
  on_attach = on_attach,
}
lspconfig['tsserver'].setup{
  on_attach = on_attach,
}
lspconfig['html'].setup{
  on_attach = on_attach,
  capabilities = capabilities,
}
lspconfig['cssls'].setup{
  on_attach = on_attach,
  capabilities = capabilities,
}


-- Setup lsp_signature (has been replaced by lspsaga)
require "lsp_signature".setup({
  -- add you config here
})



-- global config for diagnostic
vim.diagnostic.config({
  virtual_text = {
      source = "if_many",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
