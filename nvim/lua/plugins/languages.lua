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
    ft = { 'markdown' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      file_types = { 'markdown' },
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
