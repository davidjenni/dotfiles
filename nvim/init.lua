-- neovim init file
-- github.com/davidjenni/dotfiles

-- neovim standard paths:
-- https://neovim.io/doc/user/starting.html#standard-path

local cmd = vim.cmd

require('dotfiles.core.options')
require('dotfiles.core.keymaps')
require('dotfiles.lazy-nvim')

require('lualine').setup()

-- cmd[[ colorscheme tokyonight]]
cmd[[ colorscheme nord]]

