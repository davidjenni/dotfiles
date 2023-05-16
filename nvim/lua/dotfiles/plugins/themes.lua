-- neovim init file
-- github.com/davidjenni/dotfiles

return {

  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = { style = "moon" },
  },

  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
  },

  {
    "nordtheme/vim",
    lazy = true,
    name = "nordtheme",
  },
}
