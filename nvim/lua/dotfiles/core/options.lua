-- neovim init file
-- github.com/davidjenni/dotfiles

local g, opt = vim.g, vim.opt

g.mapleader = ' '
g.maplocalleader = ' '

-- :he options
opt.backspace = 'indent,eol,start'
opt.showcmd = true
opt.laststatus = 3	-- new in neovim >= 0.7
-- TODO: :hightlight WinSeparator guibg=None

opt.autowrite = true
opt.autoread = true
opt.cursorline = true

opt.wildmode = { 'list', 'full' }
-- opt.wildmode = { 'list:full' }
opt.wildignorecase = true
opt.wildoptions = 'pum'
opt.pumheight = 12

opt.showmode = true
opt.showcmd = true
opt.showmatch = true

opt.number = true
opt.signcolumn = 'yes'
opt.shortmess = 'atToOcI'
opt.splitright = true
opt.splitbelow = true

opt.smarttab = true
opt.expandtab = true
local indent = 2
opt.tabstop = indent
opt.softtabstop = indent
opt.shiftwidth = indent
opt.autoindent = true
opt.smartindent = true
opt.shiftround = true
opt.cindent = true
opt.virtualedit = 'onemore'
opt.joinspaces = false
opt.formatoptions = 'crqnj'

opt.completeopt = 'menuone,noselect,preview'

opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

opt.cursorline = true
opt.scrolloff = 2
opt.sidescrolloff = 2

opt.listchars = { tab = '>.', trail = '#', extends = '>', precedes = '<' }
opt.list = true

opt.mouse = 'a'
opt.belloff = 'all'
opt.clipboard = 'unnamed'
opt.writebackup = false
opt.swapfile = false
opt.hidden = true
opt.switchbuf = 'useopen'

