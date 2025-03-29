-- neovim init file
-- github.com/davidjenni/dotfiles

-- neovim standard paths:
-- https://neovim.io/doc/user/starting.html#standard-path

if vim.fn.has("nvim-0.11.0") == 0 then
  vim.api.nvim_echo({
    { "This nvim config requires neovim >= 0.11.0\n", "ErrorMsg" },
    { "Press any key to exit", "MoreMsg" },
  }, true, {})
  vim.fn.getchar()
  vim.cmd([[quit]])
  return {}
end

require('options')
require('keymaps')
require('autocmds')
require('lazy-nvim')
require('lsp-config')

vim.cmd[[ colorscheme catppuccin-macchiato ]]
