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
  { 'github/copilot.vim' },

  -- File finder
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
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
      local opts = { noremap = true, silent = true }

      vim.keymap.set('n', '<leader>f', builtin.grep_string, opts)
      vim.keymap.set('v', '<leader>f', function()
        local text = vim.getVisualSelection()
        builtin.current_buffer_fuzzy_find({ default_text = text })
      end, opts)
    end,
  },
}
