-- ## References
-- * https://github.com/jdhao/nvim-config/blob/master/lua/config/nvim-cmp.lua


-- ## nvim-cmp.
local cmp = require'cmp'

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

cmp.setup({
  -- REQUIRED - you must specify a snippet engine
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  -- Supertab-like completion.
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-c>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert
    }),
    ['<Tab>'] = function(fallback)
      if not cmp.select_next_item() then
        if vim.bo.buftype ~= 'prompt' and has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end
    end,
  }),
  -- Groups of sources.
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'nvim_lsp_signature_help' },
    { name = 'omni' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'emoji' },
  }),
  -- Looks.
  -- completion = {
  --   keyword_length = 1,
  --   completeopt = "menu,noselect"
  -- },
  formatting = {
    format = function(entry, vim_item)
      vim_item.menu = ({
        omni = '[O]',
        path = '[P]',
        vsnip = '[S]',
        emoji = '[絵]',
        buffer = '[B]',
        nvim_lsp = '[LSP]',
      })[entry.source.name]
      return vim_item
    end,
  },
})
