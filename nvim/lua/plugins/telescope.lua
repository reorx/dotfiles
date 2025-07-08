return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      vim.cmd([[
        noremap <c-/> :Telescope find_files<cr>
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
