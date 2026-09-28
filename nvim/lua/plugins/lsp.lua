-- Symbols
-- @lsp.type.class          Identifiers that declare or reference a class type
-- @lsp.type.comment        Tokens that represent a comment
-- @lsp.type.decorator      Identifiers that declare or reference decorators and annotations
-- @lsp.type.enum           Identifiers that declare or reference an enumeration type
-- @lsp.type.enumMember     Identifiers that declare or reference an enumeration property, constant, or member
-- @lsp.type.event          Identifiers that declare an event property
-- @lsp.type.function       Identifiers that declare a function
-- @lsp.type.interface      Identifiers that declare or reference an interface type
-- @lsp.type.keyword        Tokens that represent a language keyword
-- @lsp.type.macro          Identifiers that declare a macro
-- @lsp.type.method         Identifiers that declare a member function or method
-- @lsp.type.modifier       Tokens that represent a modifier
-- @lsp.type.namespace      Identifiers that declare or reference a namespace, module, or package
-- @lsp.type.number         Tokens that represent a number literal
-- @lsp.type.operator       Tokens that represent an operator
-- @lsp.type.parameter      Identifiers that declare or reference a function or method parameters
-- @lsp.type.property       Identifiers that declare or reference a member property, member field, or member variable
-- @lsp.type.regexp         Tokens that represent a regular expression literal
-- @lsp.type.string         Tokens that represent a string literal
-- @lsp.type.struct         Identifiers that declare or reference a struct type
-- @lsp.type.type           Identifiers that declare or reference a type that is not covered above
local list_lsp_symbols = function(telescope_builtin)
  local symbols = {
    'interface',
    'struct',
    'type',
    'class',
    'constructor',
    'method',
    'function',
    'enum',
    'comment',
  }
  if vim.bo.filetype == "typescript" then
    table.insert(symbols, 'namespace')
  end
  telescope_builtin.lsp_document_symbols({
    symbols = symbols
  })
end

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
        'pyright', 'lua_ls', 'gopls',
      },
    },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      'saghen/blink.cmp',
      'neovim/nvim-lspconfig',
    },

    config = function(_, opts)
      -- Let mason setup lsp
      require("mason-lspconfig").setup(opts)

      -- Setup lsp diagnostic
      -- (if set in nvim-lspconfig opts, virtual_text does not work)
      vim.diagnostic.config({
        severity_sort = true,
        float = {
          border = 'rounded',
          source = 'if_many'
        },
        underline = { severity = vim.diagnostic.severity.ERROR },
        -- the cursor line shows full diagnostics as lines below it,
        -- other lines keep the short eol text (current_line = false skips the cursor line)
        virtual_lines = { current_line = true },
        virtual_text = {
          current_line = false,
          virt_text_pos = 'eol',
          prefix = '←',
        },
      })

      -- LSP server configs live in nvim/lsp/<name>.lua, see :help lsp-config

      -- nvim's default gr* LSP mappings make the `gr` mapping below wait for
      -- timeoutlen, remove the normal mode ones (x mode gra doesn't conflict)
      for _, lhs in ipairs({ 'grr', 'grn', 'gra', 'gri', 'grt', 'grx' }) do
        if vim.fn.maparg(lhs, 'n') ~= '' then
          vim.keymap.del('n', lhs)
        end
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
          map('<leader>o', function() list_lsp_symbols(telescope_builtin) end, 'Symb[o]ls')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', telescope_builtin.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          map("<leader>a", vim.lsp.buf.code_action, 'Code [A]ction')

          -- no float needed: virtual_lines shows the diagnostic of the line jumped to
          map("<leader>[", function() vim.diagnostic.jump({ count = -1 }) end, 'Prev Diagnostic')
          map("<leader>]", function() vim.diagnostic.jump({ count = 1 }) end, 'Next Diagnostic')

          --map("<leader>l", function() vim.diagnostic.setqflist({open = true}) end, '[L]ist Diagnostics')
          map("<leader>l", telescope_builtin.diagnostics, '[L]ist Diagnostics')
        end,
      })

    end,
  },
}
