-- References:
-- - https://github.com/joshmedeski/dotfiles/tree/main/.config/nvim/lua/plugins
--

local plugins = {
  -- UI
  {
    -- https://github.com/nvim-lualine/lualine.nvim
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        extensions = {
          'nvim-tree', 'trouble',
        }
      })
    end,
  },
  {
    'crispgm/nvim-tabline',
    enabled = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' }, -- optional
    opts = {
      show_index = false,           -- show tab index
      show_modify = true,          -- show buffer modification indicator
      show_icon = true,           -- show file extension icon
      fnamemodify = ':t',          -- file name modifier string
                                   -- can be a function to modify buffer name
      modify_indicator = '*',    -- modify indicator
      no_name = 'No name',         -- no name buffer name
      brackets = { '', '' },     -- file name brackets surrounding
      inactive_tab_max_length = 0  -- max length of inactive tab titles, 0 to ignore
    }
  },
  {
    'nanozuki/tabby.nvim',
    config = function()
      function interleave(array, separator)
        local result = {}
        for i, v in ipairs(array) do
          table.insert(result, v)
          if i < #array then
            table.insert(result, separator)
          end
        end
        return result
      end
      local theme = {
        -- Also you can do this: fill = { fg='#f2e9de', bg='#907aa9', style='italic' }
        fill = 'TabLineFill',
        tab = 'TabLine',
        current_tab = 'TabLineSel',
        current_tab_sep = 'TabLineSelSep',
        win = 'TabLine',
        focused = 'TabLineFocused',
      }
      require('tabby').setup({
        line = function(line)
          return {
            line.tabs().foreach(function(tab)
              return {
                {
                  '▎ ',
                  hl = tab.is_current() and theme.current_tab_sep or theme.tab,
                },
                --line.sep('▎ ', theme.sep, theme.sep),  -- don't use line.sep as it works like shit-get fg from the first group and bg from the second group, why the fuck not using one single group?
                --tab.number(),
                tab.name(),
                ' ',
                tab.close_btn(''),
                ' ',
                hl = tab.is_current() and theme.current_tab or theme.tab,
                --margin = ' ',
              }
            end),
            line.spacer(),
            interleave(
              line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
                return {
                  ' ',
                  {
                    win.buf_name(),
                    hl = win.is_current() and theme.focused or theme.win,
                  },
                  ' ',
                  --margin = ' ',
                }
              end),
              { '|', hl = theme.win }
            ),
            --hl = theme.fill,
          }
        end,
        -- option = {}, -- setup modules' option,
      })
    end,
  },
  {
    -- https://github.com/Bekaboo/dropbar.nvim
    'Bekaboo/dropbar.nvim',  -- The symbol breadcrumb plugin
    -- optional, but required for fuzzy finder support
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make'
    },
    config = function()
      local sources = require('dropbar.sources')
      local utils = require('dropbar.utils')
      local default_opts = require('dropbar.configs').opts

      local excluded_ft = {
        lua = true
      }
      require('dropbar').setup({
        bar = {
          enable = function(buf, win, info)
            if excluded_ft[vim.bo[buf].ft] then
              return false
            end
            return default_opts.bar.enable(buf, win, info)
          end,
          sources = function(buf, _)
            local ft = vim.bo[buf].ft
            if ft == 'markdown' then
              return {
                sources.markdown
              }
            end
            if vim.bo[buf].buftype == 'terminal' then
              return {
                sources.terminal,
              }
            end
            -- for regular files, sources.path is excluded
            return {
              utils.source.fallback({
                sources.lsp,
                sources.treesitter,
              }),
            }
          end,
        },
      })

      local dropbar_api = require('dropbar.api')
      vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
      vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
      vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
    end
  },
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
  { 'romainl/vim-qf' },

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
  {
    -- consider replace vim-sandwich with this one
    -- https://github.com/kylechui/nvim-surround
    "kylechui/nvim-surround",
    enabled = false,
    version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require('nvim-surround').setup({
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
  -- alternative: https://github.com/echasnovski/mini.files
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
      require('nvim-tree').setup({
        sort = {
          sorter = 'case_sensitive',
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

        --on_attach = function(bufnr)
        --  local map = function(mode, keys, func, desc)
        --    vim.keymap.set(mode, keys, func, { noremap = true, silent = true, desc = '🔭 ' .. desc })
        --  end
        --end,
      })

      local map = function(mode, keys, func, desc)
        vim.keymap.set(mode, keys, func, { noremap = true, silent = true, desc = '🔭 ' .. desc })
      end
      map('n', '<C-1>', '<cmd>NvimTreeFindFileToggle<CR>', 'Toggle Tree on current file')
    end,

  },

  -- Text rendering
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    lazy = false,
    build = ':TSUpdate',

    dependencies = {
      -- NOTE: use dropbar instead of nvim-treesitter-context for code context
      --{
      --  'nvim-treesitter/nvim-treesitter-context',
      --  event = 'BufReadPost',
      --  opts = function()
      --    return { mode = 'cursor', max_lines = 2 }
      --  end,
      --},
    },

    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    opts = {
      ensure_installed = {
        'comment', "lua", "vim", "vimdoc", "markdown", "markdown_inline",
        "go", "python", "javascript", 'typescript', 'tsx',
      },
      --auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    },
  },
  {
    "folke/snacks.nvim",
    ---@module 'snacks'
    ---@type snacks.Config
    opts = {
      -- works better than indent-blankline.nvim
      indent = {
        animate = { enabled = false },
      },
      notifier = {
        enabled = true,
        top_down = false,
      },
      --quickfile = { enabled = true },
    },
 },
  {
    -- https://github.com/folke/todo-comments.nvim
    'folke/todo-comments.nvim',
    main = "todo-comments",
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {},
  },
  -- alternative: https://github.com/HiPhish/rainbow-delimiters.nvim
  { 'junegunn/rainbow_parentheses.vim' },
  { 'dominikduda/vim_current_word' },
  { 'ntpeters/vim-better-whitespace' },
  {
    -- https://github.com/lukas-reineke/indent-blankline.nvim
    'lukas-reineke/indent-blankline.nvim',
    enabled = false,
    main = "ibl",
    opts = {
      scope = {
        enabled = false,
        show_start = false,
        show_end = false,
      },
    },
  },
  -- https://github.com/luukvbaal/statuscol.nvim (fold/unfold chevrons)

  -- LLM
  {
    'github/copilot.vim',
    enabled = false,
    cmd = 'Copilot',
  },

  -- Fuzzy finder
  -- alternative: https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
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

      -- Text search

      map('n', '<C-\\>', builtin.live_grep, 'Live grep string')

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

      -- Other pickers
      map('n', '<leader>pg', builtin.git_commits, '[G]it commits')
    end,
  },

  -- Additional panels
  -- https://github.com/hedyhli/outline.nvim
}

return plugins
