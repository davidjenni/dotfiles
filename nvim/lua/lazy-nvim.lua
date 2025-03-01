-- neovim init file
-- github.com/davidjenni/dotfiles

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  print('Bootstrapping lazy.nvim into: ' .. lazypath .. '...')
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local opts = {
  install = {
    colorscheme = { "catppuccin-macchiato" },
  },
}

-- merge and load all .lua files under lua/plugins, see:
-- https://github.com/folke/lazy.nvim#-structuring-your-plugins
require("lazy").setup("plugins", opts)
