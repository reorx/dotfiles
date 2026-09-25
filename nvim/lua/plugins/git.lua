return {
  -- better alternative: https://github.com/lewis6991/gitsigns.nvim
  {
    'airblade/vim-gitgutter',
    init = function()
      -- https://github.com/airblade/vim-gitgutter
      vim.g.gitgutter_sign_modified = '~'
      vim.g.gitgutter_sign_modified_removed = '~'
      vim.g.gitgutter_sign_removed_first_line = '^'
      vim.g.gitgutter_sign_removed_above_and_below = 'x'
      -- sign colors are set in colorscheme.lua (custom_highlights)
    end,
  },
  { 'tpope/vim-fugitive', cmd = 'Git' },

  -- https://github.com/sindrets/diffview.nvim
  -- https://github.com/NeogitOrg/neogit
}
