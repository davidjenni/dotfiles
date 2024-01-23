-- neovim init file
-- github.com/davidjenni/dotfiles

local k = vim.keymap

k.set('n', '<leader>h', '<cmd>noh<CR>', { desc = 'Clear highlights' })
k.set('n', '<c-k>', ':wincmd k<CR>', { desc = 'Move to window above' })
k.set('n', '<c-j>', ':wincmd j<CR>', { desc = 'Move to window below' })
k.set('n', '<c-h>', ':wincmd h<CR>', { desc = 'Move to window left' })
k.set('n', '<c-l>', ':wincmd l<CR>', { desc = 'Move to window right' })

-- plugins set their own keymaps in ~/.config/nvim/lua/plugins/*.lua
--
