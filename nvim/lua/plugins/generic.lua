return {
  { 'vim-airline/vim-airline' },
  { 'vim-airline/vim-airline-themes' },
  { 'junegunn/rainbow_parentheses.vim' },
  { 'junegunn/fzf' },
  { 'junegunn/fzf.vim' },
  { 'scrooloose/nerdtree' },
  { 'dominikduda/vim_current_word' },
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
  { 'ntpeters/vim-better-whitespace' },
  -- requires a nerd font
  { 'ryanoasis/vim-devicons' },
  { 'wellle/targets.vim' },
  { 'machakann/vim-sandwich' },
  { 'tpope/vim-repeat' },
  { 'editorconfig/editorconfig-vim' },
  { 'romainl/vim-qf' },
  { 'nvim-treesitter/nvim-treesitter', branch = 'master', lazy = false, build = ':TSUpdate' },

  -- LLM
  -- { 'github/copilot.vim' },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
  },

}
