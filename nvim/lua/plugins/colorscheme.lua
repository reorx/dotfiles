local use_theme = 'catppuccin'
--local use_theme = 'kanagawa'
--local use_theme = 'rose-pine'

local plugins = {
  {
    "catppuccin/nvim",
    enabled = false,
    name = "catppuccin",
    priority = 1000,
    config = function()

      require("catppuccin").setup {
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        term_colors = true,
        no_italic = false, -- Force no italic
        no_bold = false, -- Force no bold
        -- No need to override color if enabling transparent_background
        --transparent_background = true,
        -- HEX colors: https://catbbrew.com/design
        color_overrides = {
          mocha = {
            base = "#030303",
            mantle = "#1A1A1A",
            crust = "#2B2B2B",
          },
        },
        custom_highlights = function(C)
          -- colors: https://github.com/catppuccin/catppuccin/blob/main/docs/style-guide.md
          return {
            -- tabby
            TabLine = { bg = C.mantle },
            TabLineSel = { bg = C.surface1, fg = C.text },
            TabLineSelSep = { bg = C.surface1, fg = C.blue },
            TabLineFocused = { fg = C.subtext0, style = { 'underline' } },

            -- nvim-treesitter-context
            TreesitterContext = { bg = C.surface1 },
            TreesitterContextBottom = { style = { 'underline' } },

            -- dropbar
            WinBar = { style = { 'underline' }, sp = C.surface2 },

            -- blink.cmp
            Pmenu = { link = 'CursorLine' },
            BlinkCmpSignatureHelp = { link = 'CursorLine' },
            --BlinkCmpSignatureHelpBorder = { bg = C.surface2, fg = C.surface2 },
            LspSignatureActiveParameter = { style = { 'underline' } },

            -- snacks
            --SnacksIndent = { fg = C.surface0 },
            SnacksIndentScope = { fg = C.surface0 },
          }
        end,
        styles = {
            comments = { "italic" },
            conditionals = { "italic" },
            loops = {},
            functions = {},
            keywords = {},
            strings = {},
            variables = {},
            numbers = {},
            booleans = {},
            properties = {},
            types = {},
            operators = {},
        },
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          telescope = true,
          notify = false,
          mini = false,
          indent_blankline = {
            enabled = true,
            -- scope_color = "base", -- catppuccin color (eg. `lavender`) Default: text
            colored_indent_levels = false,
          },
          snacks = {
            enabled = true,
            indent_scope_color = 'overlay2', -- catppuccin color (eg. `lavender`) Default: text
          },
          --blink_cmp = true,
          -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
        },
      }

      vim.cmd([[
        let $NVIM_TUI_ENABLE_TRUE_COLOR=1
        colorscheme catppuccin
      ]])
    end,
  },

  {
    -- https://github.com/rebelot/kanagawa.nvim
    'rebelot/kanagawa.nvim',
    name = 'kanagawa',
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
      require('kanagawa').setup({
      })
      vim.cmd('colorscheme kanagawa-dragon')
    end,
  },
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
      require('rose-pine').setup({
      })
      vim.cmd('colorscheme rose-pine')
    end,
  },
  {
    'projekt0n/github-nvim-theme',
    name = 'github',
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
      require('github-theme').setup({
        -- ...
      })

      vim.cmd('colorscheme github_dark_default')
    end,
  },
  {
    -- https://github.com/oxfist/night-owl.nvim
    "oxfist/night-owl.nvim",
    name = 'night-owl',
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
      -- load the colorscheme here
      require("night-owl").setup()
      vim.cmd.colorscheme("night-owl")
    end,
  },
  -- Plug 'bluz71/vim-moonfly-colors', { 'as': 'moonfly' }
}

-- Only enables the one with the colorscheme name
for _, plugin in ipairs(plugins) do
  if plugin.name == use_theme then
    plugin.enabled = true
  end
end

return plugins
