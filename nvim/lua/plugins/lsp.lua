return {
  {
    'mason-org/mason-lspconfig.nvim',
    opts = {
      ensure_installed = {
        'pyright',
      },
    },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
      'saghen/blink.cmp',
    },

    config = function()
      -- https://github.com/mason-org/mason-lspconfig.nvim
      require("mason-lspconfig").setup()

      local opts = { silent = true, buffer = bufnr, noremap = true }

      vim.keymap.set('n', 'ge', vim.diagnostic.open_float, opts)
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
    end,
  },
}
