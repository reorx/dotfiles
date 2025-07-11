return {
  {
    'airblade/vim-gitgutter',
    init = function()
      -- https://github.com/airblade/vim-gitgutter
      vim.g.gitgutter_sign_modified = '~'
      vim.g.gitgutter_sign_modified_removed = '~'
      vim.g.gitgutter_sign_removed_first_line = '^'
      vim.g.gitgutter_sign_removed_above_and_below = 'x'
      vim.cmd([[
        set signcolumn=yes
        highlight GitGutterAdd    guifg=#009900 ctermfg=2
        highlight GitGutterChange guifg=#bbbb00 ctermfg=3
        highlight GitGutterDelete guifg=#ff2222 ctermfg=1
      ]])
    end,
  },
  { 'tpope/vim-fugitive', cmd = 'Git' },

  -- https://github.com/sindrets/diffview.nvim
}
