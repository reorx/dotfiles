-- https://github.com/nvim-treesitter/nvim-treesitter
require'nvim-treesitter.configs'.setup {
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
}, { prefix = "<leader>" })

wk.register({
  -- FZF
  f = "Rg find selection",
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
