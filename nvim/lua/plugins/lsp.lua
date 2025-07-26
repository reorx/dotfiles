return {
  -- Docs:
  -- * https://github.com/mason-org/mason-lspconfig.nvim
  -- * https://github.com/neovim/nvim-lspconfig
  --
  -- References:
  -- * https://github.com/joshmedeski/dotfiles/blob/main/.config/nvim/lua/plugins/lspconfig.lua
  {
    'mason-org/mason-lspconfig.nvim',
    opts = {
      ensure_installed = {
        'pyright', 'lua_ls',
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
      vim.cmd([[ set updatetime=1000 ]]) -- set CursorHold wait time to 1s
      vim.api.nvim_create_autocmd({ "CursorHold" }, {
        pattern = "*",
        callback = function()
          -- Get all floating windows
          local float_wins = vim.tbl_filter(function(win)
            return vim.api.nvim_win_get_config(win).relative ~= ""
          end, vim.api.nvim_list_wins())
          -- Only open if no floating windows exist
          if #float_wins == 0 then
            return
          end
          vim.diagnostic.open_float({
            scope = "line",
            --focusable = false,
            --close_events = {
            --  "CursorMoved",
            --  "CursorMovedI",
            --  "BufHidden",
            --  "InsertCharPre",
            --  "WinLeave",
            --},
          })
        end
      })

      -- Setup lsp diagnostic
      -- (if set in nvim-lspconfig opts, virtual_text does not work)
      vim.diagnostic.config({
        severity_sort = true,
        float = {
          border = 'rounded',
          source = 'if_many'
        },
        underline = { severity = vim.diagnostic.severity.ERROR },
        virtual_text = {
          virt_text_pos = 'eol',
          prefix = '←',
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

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(event)
          -- Key mappings --
          local telescope_builtin = require('telescope.builtin')

          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- hover doc
          -- https://neovim.io/doc/user/lsp.html#vim.lsp.buf.hover%28%29
          -- According to :help vim.lsp.buf.hover(), you should be able to jump into the floating window by calling the function twice in a row (or pressing K twice in your case)
          map("K", function() vim.lsp.buf.hover({ border = "rounded", max_height = 25, max_width = 120 }) end, 'Displays hover info about the symbol.')

          -- Jump to the definition of the word under your cursor.
          map('gd', telescope_builtin.lsp_definitions, '[G]oto [D]efinition')
          --vim.keymap.set('n', '<space>d', vim.lsp.buf.definition, opts)

          map('gb', '<cmd>pop<CR>', '[G]o [B]ack in tag stack')

          -- Jump to the declaration of the word under your cursor.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          --vim.keymap.set('n', '<space>D', vim.lsp.buf.declaration, opts)

          -- Jump to the type of the word under your cursor.
          map('gt', telescope_builtin.lsp_type_definitions, '[G]oto [T]ype Definition')
          --map('gt', vim.lsp.buf.type_definition, '[G]oto [T]ype Definition')

          -- Find references for the word under your cursor.
          map('gr', telescope_builtin.lsp_references, '[G]oto [R]eferences')
          --map('gr', vim.lsp.buf.references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          map('gi', telescope_builtin.lsp_implementations, '[G]oto [I]mplementation')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', telescope_builtin.lsp_document_symbols, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', telescope_builtin.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          map("<leader>a", vim.lsp.buf.code_action, 'Code [A]ction')

          map("<leader>[", vim.diagnostic.goto_prev, 'Prev Diagnostic')
          map("<leader>]", vim.diagnostic.goto_next, 'Next Diagnostic')

          --map("<leader>l", function() vim.diagnostic.setqflist({open = true}) end, '[L]ist Diagnostics')
          map("<leader>l", telescope_builtin.diagnostics, '[L]ist Diagnostics')
        end,
      })

    end,
  },
}
