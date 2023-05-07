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
  highlight_overrides = {
    mocha = function(C)
      return {
        TabLineSel = { bg = C.pink },
        CmpBorder = { fg = C.surface2 },
        Pmenu = { bg = C.none },
        TelescopeBorder = { link = "FloatBorder" },
      }
    end,
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

-- setup must be called before loading
vim.cmd.colorscheme "catppuccin"

