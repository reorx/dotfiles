return {
  -- Go: no plugin, gopls via mason + nvim/lsp/gopls.lua (organize imports & format on save)
  -- Optional: quicktemplate plugin (uncomment to enable)
  -- {
  --   'codelitt/vim-qtpl',
  --   ft = 'go',
  -- },

  -- Python
  {
    'Vimjas/vim-python-pep8-indent',
    ft = 'python',
  },

  -- Lua
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = 'nvim/lua' },
      },
    },
  },

  -- Nginx
  {
    'chr4/nginx.vim',
     ft = 'nginx',
  },

  -- HTML (emmet)
  {
    'mattn/emmet-vim',
    ft = 'html',
  },

  -- Protocol Buffers
  {
    'uarun/vim-protobuf',
    ft = 'proto',
  },

  -- Ansible YAML
  --{
  --  'pearofducks/ansible-vim',
  --  ft = 'yaml',
  --},

  -- Markdown
  {
    'noisesfromspace/touchup.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    ft = 'markdown',
    init = function()
      -- conceal 是 window-local；切回已有 Markdown buffer 时也要恢复完整源码。
      vim.api.nvim_create_autocmd({ 'FileType', 'BufWinEnter' }, {
        group = vim.api.nvim_create_augroup('markdown_source_view', { clear = true }),
        callback = function()
          if vim.bo.filetype == 'markdown' then
            vim.opt_local.conceallevel = 0
          end
        end,
      })
    end,
    opts = {},
  }
}
