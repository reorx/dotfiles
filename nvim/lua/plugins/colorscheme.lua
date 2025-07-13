return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()

      require("catppuccin").setup {
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        transparent_background = true,
        dim_inactive = {
            enabled = false,
            shade = "dark",
            percentage = 0.15,
        },
        no_italic = false, -- Force no italic
        no_bold = false, -- Force no bold
        custom_highlights = function(C)
          -- see colors: https://github.com/catppuccin/catppuccin/blob/main/docs/style-guide.md
          return {
            -- barbar.lua:
            -- - https://github.com/romgrk/barbar.nvim#highlighting
            -- - https://github.com/catppuccin/nvim/blob/main/lua/catppuccin/groups/integrations/barbar.lua
            BufferCurrent = { bg = C.surface1, fg = C.text },
            BufferCurrentSign = { bg = C.surface1, fg = C.blue },
            BufferCurrentMod = { bg = C.surface1 },
            -- nvim-treesitter-context
            TreesitterContext = { bg = C.surface1 },
            TreesitterContextBottom = { style = { 'underline' } },
            -- dropbar
            WinBar = { style = { 'underline' }, sp = C.surface2 },
            -- blink.cmp
            --Pmenu = { bg = C.surface0 },
            Pmenu = { link = 'CursorLine' },
            BlinkCmpSignatureHelp = { link = 'CursorLine' },
            --BlinkCmpSignatureHelpBorder = { bg = C.surface2, fg = C.surface2 },
            LspSignatureActiveParameter = { style = { 'underline' } },
            -- snacks
            --SnacksIndent = { fg = C.surface1 },
            --SnacksIndentScope = { fg = C.surface3 },
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

  -- Other candidates
  -- Plug 'rebelot/kanagawa.nvim'  " https://github.com/rebelot/kanagawa.nvim
  -- Plug 'EdenEast/nightfox.nvim'  " https://github.com/EdenEast/nightfox.nvim
  -- Plug 'oxfist/night-owl.nvim'  " https://github.com/oxfist/night-owl.nvim
  -- Plug 'bluz71/vim-moonfly-colors', { 'as': 'moonfly' }
  -- Plug 'tanvirtin/monokai.nvim'  " https://github.com/tanvirtin/monokai.nvim
}
