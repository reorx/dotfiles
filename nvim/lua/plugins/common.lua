return {
  -- UI
  --{ 'vim-airline/vim-airline' },
  --{ 'vim-airline/vim-airline-themes' },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      -- https://github.com/nvim-lualine/lualine.nvim
      require('lualine').setup()
    end,
  },
  { 'romainl/vim-qf' },
  -- https://github.com/Bekaboo/dropbar.nvim
  {
    -- https://github.com/folke/trouble.nvim
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>bx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>bX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>bs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
    },
  },

  -- Editing
  {
    'machakann/vim-sandwich',
    config = function()
      vim.cmd([[
        " sandwich
        let g:sandwich_no_default_key_mappings = 1
        "
        " add
        nmap <leader>sa <Plug>(sandwich-add)
        xmap <leader>sa <Plug>(sandwich-add)
        omap <leader>sa <Plug>(sandwich-add)
        "
        " delete
        nmap <leader>sd <Plug>(sandwich-delete)
        xmap <leader>sd <Plug>(sandwich-delete)
        nmap <leader>sdb <Plug>(sandwich-delete-auto)
        "
        " replace
        nmap <leader>sr <Plug>(sandwich-replace)
        xmap <leader>sr <Plug>(sandwich-replace)
        nmap <leader>srb <Plug>(sandwich-replace-auto)
      ]])
    end,
  },
  -- consider replace vim-sandwich
  {
    "kylechui/nvim-surround",
    enable = false,
    version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      -- https://github.com/kylechui/nvim-surround
      require("nvim-surround").setup({
          -- Configuration here, or leave empty to use defaults
      })
    end
  },
  { 'tpope/vim-repeat' },
  { 'wellle/targets.vim' },
  { 'editorconfig/editorconfig-vim' },
  -- https://github.com/MagicDuck/grug-far.nvim
  -- https://github.com/j-hui/fidget.nvim

  -- Navigation
  -- https://github.com/folke/flash.nvim
  -- "Plug 'easymotion/vim-easymotion'
  -- https://github.com/justinmk/vim-sneak
  -- https://github.com/ggandor/leap.nvim

  -- File explorer
  --{ 'scrooloose/nerdtree' },
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    config = function()
      require("nvim-tree").setup({
        sort = {
          sorter = "case_sensitive",
        },
        view = {
          width = 30,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = true,
        },
      })
    end,
  },

  -- Text rendering
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    lazy = false,
    build = ':TSUpdate',

    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-context',
        event = 'BufReadPost',
        opts = function()
          return { mode = 'cursor', max_lines = 3 }
        end,
      },
    },

    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    opts = {
      ensure_installed = {
        "lua", "vim", "vimdoc", "markdown", "markdown_inline",
        "go", "python", "javascript", 'typescript', 'tsx',
      },
      --auto_install = true,
      highlight = { enable = true, },
    },
  },
  -- alternative: https://github.com/HiPhish/rainbow-delimiters.nvim
  { 'junegunn/rainbow_parentheses.vim' },
  { 'dominikduda/vim_current_word' },
  { 'ntpeters/vim-better-whitespace' },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
  },

  -- LLM
  {
    'github/copilot.vim',
    cmd = 'Copilot',
  },

  -- File finder
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      vim.cmd([[
        noremap <c-/> :Telescope find_files<cr>
        noremap <c-t> :Telescope<cr>
        noremap <c-f> :Telescope current_buffer_fuzzy_find<cr>
      ]])

      local builtin = require('telescope.builtin')
      local map = function(mode, keys, func, desc)
        vim.keymap.set(mode, keys, func, { noremap = true, silent = true, desc = '🔭 ' .. desc })
      end

      map('n', '<leader>F', builtin.grep_string, '[F]ind string globally')
      map('v', '<leader>F', function()
        local text = vim.getVisualSelection()
        builtin.grep_string({ default_text = text })
      end, '[F]ind string')

      map('n', '<leader>f', builtin.current_buffer_fuzzy_find, '[F]ind string in current buffer')
      map('v', '<leader>f', function()
        local text = vim.getVisualSelection()
        builtin.current_buffer_fuzzy_find({ default_text = text })
      end, '[F]ind string in current buffer')
    end,
  },

  -- Additional panels
  -- https://github.com/hedyhli/outline.nvim

}
