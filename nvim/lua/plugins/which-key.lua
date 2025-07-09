-- https://github.com/folke/which-key.nvim
-- https://github.com/joshmedeski/dotfiles/blob/main/.config/nvim/lua/plugins/which_key.lua
return {
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      delay = 0,
      -- spec = {}
    }
  }
}
