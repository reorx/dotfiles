return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()

      require("catppuccin").setup {
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        term_colors = true,
        transparent_background = true,
        term_colors = false,
        dim_inactive = {
            enabled = false,
            shade = "dark",
            percentage = 0.15,
        },
        no_italic = false, -- Force no italic
        no_bold = false, -- Force no bold
        custom_highlights = function(C)
          return {
            -- barbar.lua: https://github.com/catppuccin/nvim/blob/main/lua/catppuccin/groups/integrations/barbar.lua
            BufferCurrent = { bg = C.surface1, fg = C.text },
            BufferCurrentSign = { bg = C.surface1, fg = C.blue },
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
