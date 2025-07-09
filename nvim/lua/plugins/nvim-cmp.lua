return {
  {
    enabled = false, -- use blink.cmp related snippet engine instead
    'hrsh7th/vim-vsnip',
    event = "InsertEnter",
    dependencies = {
      'hrsh7th/cmp-vsnip',
    },
  },
  {
    enabled = false,
    'hrsh7th/nvim-cmp', -- use blink.cmp instead
    event = "InsertEnter",
    -- these dependencies will only be loaded when cmp loads
    -- dependencies are always lazy-loaded unless specified otherwise
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-nvim-lsp-signature-help',
    },
    config = function()
      local cmp = require'cmp'

      cmp.setup({
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
          end,
        },

        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),

        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'vsnip' }, -- For vsnip users.
          { name = 'nvim_lsp_signature_help' },
        }, {
          { name = 'buffer' },
          { name = 'path' },
          -- { name = 'emoji' },
        }),

        formatting = {
          format = function(entry, vim_item)
            vim_item.menu = ({
              -- omni = '[O]',
              path = '[P]',
              vsnip = '[S]',
              -- emoji = '[絵]',
              buffer = '[B]',
              nvim_lsp = '[L]',
            })[entry.source.name]
            return vim_item
          end,
        },

      })
    end,
  },
}
