-- Merged with nvim-lspconfig's lsp/gopls.lua, see :help lsp-config-merge

-- What vim-go used to do on save: organize imports (goimports), then gofmt
local function organize_imports_and_format(client, bufnr)
  local params = {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
    range = {
      start = { line = 0, character = 0 },
      ['end'] = { line = vim.api.nvim_buf_line_count(bufnr), character = 0 },
    },
    context = { only = { 'source.organizeImports' }, diagnostics = {} },
  }
  local res = client:request_sync('textDocument/codeAction', params, 3000, bufnr)
  for _, action in ipairs(res and res.result or {}) do
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
    end
  end
  vim.lsp.buf.format({ bufnr = bufnr, id = client.id, timeout_ms = 3000 })
end

---@type vim.lsp.Config
return {
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = vim.api.nvim_create_augroup('gopls_on_save_' .. bufnr, { clear = true }),
      buf = bufnr,
      callback = function()
        organize_imports_and_format(client, bufnr)
      end,
    })
  end,
}
