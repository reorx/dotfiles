-- ## References:
-- * https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization
-- * https://github.com/jdhao/nvim-config/blob/master/lua/config/lsp.lua


-- ## lspconfig

-- Define on_attach function for lspconfig
local custom_attach = function(client, bufnr)
  -- Mappings.
  --local opts = { silent = true, buffer = bufnr }
  local opts = { silent = true, buffer = bufnr, noremap = true }

  vim.keymap.set('n', 'ge', vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  -- hover doc
  -- https://neovim.io/doc/user/lsp.html#vim.lsp.buf.hover%28%29
  -- According to :help vim.lsp.buf.hover(), you should be able to jump into the floating window by calling the function twice in a row (or pressing K twice in your case)
  -- vim.keymap.set("n", 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)

  vim.keymap.set('n', '<space>d', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', '<space>t', vim.lsp.buf.type_definition, opts)
  vim.keymap.set("n", "<space>p", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "<space>n", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<space>q", function() vim.diagnostic.setqflist({open = true}) end, opts)
  vim.keymap.set("n", "<space>a", vim.lsp.buf.code_action, opts)

  -- Set some key bindings conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    vim.keymap.set("n", "<space>f", vim.lsp.buf.formatting_sync, opts)
  end
  if client.resolved_capabilities.document_range_formatting then
    vim.keymap.set("x", "<space>f", vim.lsp.buf.range_formatting, opts)
  end

  vim.api.nvim_create_autocmd("CursorHold", {
    buffer=bufnr,
    callback = function()
      local opts = {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = 'rounded',
        source = 'always',  -- show source in diagnostic popup window
        prefix = ' ',
      }

      if not vim.b.diagnostics_pos then
        vim.b.diagnostics_pos = { nil, nil }
      end

      local cursor_pos = vim.api.nvim_win_get_cursor(0)
      if (cursor_pos[1] ~= vim.b.diagnostics_pos[1] or cursor_pos[2] ~= vim.b.diagnostics_pos[2]) and
        #vim.diagnostic.get() > 0
      then
          vim.diagnostic.open_float(nil, opts)
      end

      vim.b.diagnostics_pos = cursor_pos
    end
  })

  -- The blow command will highlight the current variable and its usages in the buffer.
  if client.resolved_capabilities.document_highlight then
    vim.cmd([[
      hi! link LspReferenceRead Visual
      hi! link LspReferenceText Visual
      hi! link LspReferenceWrite Visual
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]])
  end

  if vim.g.logging_level == 'debug' then
    local msg = string.format("Language server %s started!", client.name)
    vim.notify(msg, 'info', {title = 'Nvim-config'})
  end
end

-- Get capabilities for lspconfig
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Setup lsp installer before lspconfig use the language servers
require("nvim-lsp-installer").setup {}

-- Setup language servers
local lspconfig = require("lspconfig")

lspconfig.pyright.setup{
  on_attach = custom_attach,
  capabilities = capabilities
}

lspconfig['tsserver'].setup{
  on_attach = custom_attach,
  capabilities = capabilities
}

lspconfig['html'].setup{
  on_attach = custom_attach,
  capabilities = capabilities
}

lspconfig['cssls'].setup{
  on_attach = custom_attach,
  capabilities = capabilities,
}


-- ## nvim built-in configs

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

-- this global option affects how long it takes to trigger the CursorHold event
vim.o.updatetime = 200

-- override floating window globally
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.max_width = 160
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- Change border of documentation hover window, See https://github.com/neovim/neovim/pull/13998.
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
})


-- ## Other LSP related plugins:

-- Setup lsp_signature (has been replaced by lspsaga)
require "lsp_signature".setup({
  -- add you config here
})
