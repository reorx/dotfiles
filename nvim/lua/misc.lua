-- https://github.com/nvim-treesitter/nvim-treesitter
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "python", "javascript", "typescript", "html", "css", "go", "vim", "vimdoc" },

  highlight = {
    enable = true,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

-- https://github.com/folke/which-key.nvim
vim.o.timeoutlen = 500
local wk = require("which-key")

wk.register({
  -- vim-qf
  q = {
    name = "Quickfix combos",
    q = "close quickfix",
    n = "next quickfix",
    p = "previous quickfix",
  },

  -- FZF
  ["?"] = "Show key mappings",
  ["/"] = "Show buffers",

  -- sandwich
  s = {
    name = "Sandwich surround combos",
    a = "add surround (e.g. saiw')",
    d = "delete surround with match",
    db = "delete surround for any block",
    r = "replace surround with match",
    rb = "replace surround for any block",
  },
}, { prefix = "<leader>" })

wk.register({
  -- FZF
  f = "Rg find selection",

  -- sandwich
  s = {
    name = "Sandwich surround combos",
    a = "add surround (e.g. sa')",
    d = "delete surround with match",
    db = "delete surround for any block",
    r = "replace surround with match",
    rb = "replace surround for any block",
  },
}, { prefix = "<leader>", mode = "v" })

--wk.register({
--}, { prefix = "" })

wk.setup {
  plugins = {
    presets = {
      z = true,
      g = false,
    }
  }
}


-- telescope
require('telescope').setup{
  defaults = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    mappings = {
      i = {
        -- map actions.which_key to <C-h> (default: <C-/>)
        -- actions.which_key shows the mappings for your picker,
        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
        --["<C-h>"] = "which_key"
      }
    }
  },
  pickers = {
    -- Default configuration for builtin pickers goes here:
    -- picker_name = {
    --   picker_config_key = value,
    --   ...
    -- }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker
    colorscheme = {
      enable_preview = true
    }
  },
  extensions = {
    -- Your extension configuration goes here:
    -- extension_name = {
    --   extension_config_key = value,
    -- }
    -- please take a look at the readme of the extension you want to configure
  }
}
