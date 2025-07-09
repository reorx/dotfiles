return {
  -- Docs:
  -- https://github.com/mason-org/mason-lspconfig.nvim
  -- https://github.com/neovim/nvim-lspconfig
  {
    'mason-org/mason-lspconfig.nvim',
    opts = {
      ensure_installed = {
        'pyright',
      },
    },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      'saghen/blink.cmp',
      'neovim/nvim-lspconfig',
    },

    config = function()
      -- Let mason setup lsp
      require("mason-lspconfig").setup()

      -- Auto show diagnostic when cursor over a place with problem
      vim.cmd([[ set updatetime=2000 ]]) -- set CursorHold wait time to 1s
      --vim.api.nvim_create_autocmd('CursorHold', {
      --  pattern = {"*"},
      --  callback = function()
      --    vim.diagnostic.open_float(nil, {focus=false, max_width=80})
      --  end,
      --})

      -- Setup lsp diagnostic
      -- (if set in nvim-lspconfig opts, virtual_text does not work)
      vim.diagnostic.config({
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        virtual_text = {
          virt_text_pos = 'eol',
          prefix = '',
        },
      })

      -- Configure LSP servers
      local servers = {
        pyright = {
          -- see :help lsp-config
          -- cmd = { ... },
          -- filetypes = { ... },
          -- capabilities = {},
          settings = {
            python = {
              analysis = {
                -- disable auto import so that it won't complete from the whole library
                autoImportCompletions = false,
              }
            }
          },
        },
      }
      for server_name, config in pairs(servers) do
        vim.lsp.config(server_name, config)
      end

      -- Key mappings --

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
      vim.keymap.set("n", "<C-[>", vim.diagnostic.goto_prev, opts)
      vim.keymap.set("n", "<C-]>", vim.diagnostic.goto_next, opts)
      vim.keymap.set("n", "<space>l", function() vim.diagnostic.setqflist({open = true}) end, opts)
      vim.keymap.set("n", "<space>a", vim.lsp.buf.code_action, opts)
      vim.keymap.set("n", "<space>rr", vim.lsp.buf.rename, opts)
    end,
  },
}
