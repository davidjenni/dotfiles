-- neovim init file
-- github.com/davidjenni/dotfiles

return {
  'nvim-lua/plenary.nvim',

  { 'nvim-lualine/lualine.nvim',
    opts = {
        theme = 'auto'
    }
  },

  'tpope/vim-commentary',
  'tpope/vim-fugitive',
  'tpope/vim-surround',
  'tpope/vim-unimpaired',
}