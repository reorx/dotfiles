return {
  -- Go
  {
    'fatih/vim-go',
    ft = 'go',
  },
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
  {
    'hdima/python-syntax',
    ft = 'python',
  },
  {
    'tmhedberg/SimpylFold',
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

  -- JSX
  {
    'maxmellon/vim-jsx-pretty',
    ft = { 'javascript', 'javascriptreact', 'typescriptreact' },
  },

  -- Protocol Buffers
  {
    'uarun/vim-protobuf',
    ft = 'proto',
  },

  -- Ansible YAML
  {
    'pearofducks/ansible-vim',
    ft = 'yaml',
  },

  -- Markdown
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    ft = { 'markdown', 'Avante' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      file_types = { 'markdown', 'Avante' },
      heading = {
        enabled = false,
      },
      code = {
        disable_background = true,
        style = 'normal',
        border = 'none',
      },
    },
  }
}
