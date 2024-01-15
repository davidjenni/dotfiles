-- neovim init file
-- github.com/davidjenni/dotfiles

local k = vim.keymap

k.set('n', '<leader>h', '<cmd>noh<CR>')
k.set('n', '<c-k>', ':wincmd k<CR>')
k.set('n', '<c-j>', ':wincmd j<CR>')
k.set('n', '<c-h>', ':wincmd h<CR>')
k.set('n', '<c-l>', ':wincmd l<CR>')

-- plugins set their own keymaps in ~/.config/nvim/lua/plugins/*.lua
--
