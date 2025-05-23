-- ## References:
-- * https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization
-- * https://github.com/jdhao/nvim-config/blob/master/lua/config/lsp.lua


-- ## documenting keymaps in which-key

local wk = require("which-key")

wk.register({
  -- LSP go to
  d = "go to definition",
  D = "go to declaration",
  t = "go to type definition",
  R = "go to references",

  -- LSP diagnostic
  ["<Left>"] = "previous diagnostic",
  ["<Right>"] = "next diagnostic",
  l = "open diagnostic quickfix list",

  -- LSP others
  a = "code actions",
  R = "format code",
  r = {
    name = "Refactor combos",
    r = "Rename",
  },
}, { prefix = "<leader>" })

wk.register({
  e = "open diagnostic floating window",
  d = "get definition (floating)",
  t = "get type definition (floating)",
  i = "get implementation (floating)",
  c = "close all (floating)",
}, { prefix = "g" })

-- ## lspconfig

goto_preview = require('goto-preview')
local gpopts = {noremap = true}

-- determine diagnostic style: use lsp_lines or show floating window on hover
local use_lsp_lines = false
local use_floating_window_border = false

-- Define on_attach function for lspconfig
local custom_attach = function(client, bufnr)
  -- Mappings.
  --local opts = { silent = true, buffer = bufnr }
  local opts = { silent = true, buffer = bufnr, noremap = true }

  vim.keymap.set('n', 'ge', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', 'gd', goto_preview.goto_preview_definition, gpopts)
  vim.keymap.set('n', 'gt', goto_preview.goto_preview_type_definition, gpopts)
  vim.keymap.set('n', 'gi', goto_preview.goto_preview_implementation, gpopts)
  vim.keymap.set('n', 'gc', goto_preview.close_all_win, gpopts)
  -- hover doc
  -- https://neovim.io/doc/user/lsp.html#vim.lsp.buf.hover%28%29
  -- According to :help vim.lsp.buf.hover(), you should be able to jump into the floating window by calling the function twice in a row (or pressing K twice in your case)
  -- vim.keymap.set("n", 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)

  vim.keymap.set('n', '<space>d', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', '<space>t', vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', '<space>R', vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<space><Left>", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "<space><Right>", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "<space>l", function() vim.diagnostic.setqflist({open = true}) end, opts)
  vim.keymap.set("n", "<space>a", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<space>rr", vim.lsp.buf.rename, opts)

  -- Set some key bindings conditional on server capabilities
  if client.server_capabilities.document_formatting then
    vim.keymap.set("n", "<space>F", vim.lsp.buf.formatting_sync, opts)
  end
  if client.server_capabilities.document_range_formatting then
    vim.keymap.set("x", "<space>F", vim.lsp.buf.range_formatting, opts)
  end

  -- Show diagnostic window on hover if not using lsp_lines
  if not use_lsp_lines then
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
  end

  -- The blow command will highlight the current variable and its usages in the buffer.
  if client.server_capabilities.document_highlight then
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
local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Setup lsp installer before lspconfig use the language servers
--require("nvim-lsp-installer").setup {}
require("mason").setup()
require("mason-lspconfig").setup()

-- Setup language servers
local lspconfig = require("lspconfig")

-- pyright (Pylance in VSCode)
-- https://github.com/microsoft/pyright/blob/main/docs/configuration.md
-- https://github.com/microsoft/pyright/blob/main/docs/comments.md
-- https://github.com/microsoft/pyright/blob/main/docs/settings.md
lspconfig.pyright.setup{
  on_attach = custom_attach,
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        -- disable auto import so that it won't complete from the whole library
        autoImportCompletions = false,
      }
    }
  }
}

-- pylsp
-- https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md

---lspconfig['tsserver'].setup{
---  on_attach = custom_attach,
---  capabilities = capabilities
---}

lspconfig['html'].setup{
  on_attach = custom_attach,
  capabilities = capabilities
}

lspconfig['cssls'].setup{
  on_attach = custom_attach,
  capabilities = capabilities,
}

-- marksman (markdown)
lspconfig.marksman.setup{
  on_attach = custom_attach,
  capabilities = capabilities,
}


-- ## nvim built-in configs

-- global config for diagnostic
local diagnostic_virtual_text = {
  source = "if_many",
}
local diagnostic_virtual_lines = false
if use_lsp_lines then
  diagnostic_virtual_text = false
  diagnostic_virtual_lines = true
  --diagnostic_virtual_lines = { only_current_line = true }
end
vim.diagnostic.config({
  virtual_text = diagnostic_virtual_text,
  virtual_lines = diagnostic_virtual_lines,
  -- signs are: E for Error, W for Warn, I for Info, H for Hint
  -- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#change-diagnostic-symbols-in-the-sign-column-gutter
  -- because we have virtual lines or lsp_lines, the signs are not need.
  -- besides, using the signs causes the inconsistency of width/height when switching editing mode
  signs = false,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- this global option affects how long it takes to trigger the CursorHold event
vim.o.updatetime = 200

-- floating window border style
if use_floating_window_border then
  -- vim.cmd [[autocmd! ColorScheme * highlight NormalFloat guibg=#1f2335]]
  vim.cmd [[autocmd! ColorScheme * highlight FloatBorder guifg=white]]
  local FB = "FloatBorder"
  local border = {
    {"┌", FB}, {"─", FB}, {"┐", FB}, {"│", FB}, {"┘", FB}, {"─", FB}, {"└", FB}, {"│", FB},
  }
end

-- override floating window globally, set max_width and border (if enabled)
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.max_width = 160
  if use_floating_window_border then
    opts.border = opts.border or border
  end
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- Change border of documentation hover window, See https://github.com/neovim/neovim/pull/13998.
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
})


-- Disable diagnostics in INSERT mode
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    -- delay update diagnostics
    update_in_insert = false,
  }
)

-- ## Other LSP related plugins:

-- lsp_signature
require "lsp_signature".setup({
  -- add you config here
  bind = true, -- This is mandatory, otherwise border config won't get registered.
  handler_opts = {
    border = use_floating_window_border and "single" or "none",
  },
  --floating_window_off_x = -2,
  --floating_window_off_y = 0,
  floating_window = false,
  floating_window_above_cur_line = true,
  max_width = 80,
  max_height = 10,
  --wrap = true,
  hint_enable = false,
  toggle_key = '<C-h>',
})

-- goto-preview
goto_preview.setup {}


-- lsp_lines
if use_lsp_lines then
  require("lsp_lines").setup()
end
