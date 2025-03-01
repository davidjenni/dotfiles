-- neovim init file
-- github.com/davidjenni/dotfiles

-- neovim standard paths:
-- https://neovim.io/doc/user/starting.html#standard-path

require('options')
require('keymaps')
require('autocmds')
require('lazy-nvim')

vim.cmd[[ colorscheme catppuccin-macchiato ]]
