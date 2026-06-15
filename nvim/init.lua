-- neovim init file
-- github.com/davidjenni/dotfiles

-- neovim standard paths:
-- https://neovim.io/doc/user/starting.html#standard-path

if vim.fn.has("nvim-0.12.0") == 0 then
  vim.api.nvim_echo({
    { "This nvim config requires neovim >= 0.12.0\n", "ErrorMsg" },
    { "Press any key to exit", "MoreMsg" },
  }, true, {})
  vim.fn.getchar()
  vim.cmd([[quit]])
  return {}
end

require('vim._core.ui2').enable()

-- set leader before loading plugins
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- diagnostics:
local virt_text = { source = 'always', prefix = '●' }
vim.diagnostic.config({ virtual_text = virt_text })

require("options")
require("pack")


