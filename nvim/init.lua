-- neovim init file
-- github.com/davidjenni/dotfiles

-- neovim standard paths:
-- https://neovim.io/doc/user/starting.html#standard-path

local minVer = '0.12.0'
if vim.fn.has("nvim-" .. minVer) == 0 then
  vim.api.nvim_echo({
    { "This nvim config requires neovim >= " .. minVer .. "\n", "ErrorMsg" },
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

require("options")
require("pack")
require("lsp")
require("commands")

