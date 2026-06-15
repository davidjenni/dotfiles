local api = vim.api
local cmd = vim.cmd
local o = vim.o

o.cursorline = true
o.smarttab = true
o.expandtab = true
o.incsearch = true
o.ignorecase = true
o.smartcase = true
o.number = true
o.signcolumn = 'yes:2'
-- o.shortmess = 'atToOc'
o.scrolloff = 10
o.sidescrolloff = 4
o.splitbelow = true
o.splitright = true
o.pumborder = 'rounded'
o.winborder = 'rounded'
o.list = true
o.listchars = 'tab:>.,trail:#,extends:>,precedes:<'
o.showmatch = true
o.matchtime = 2

local indent = 2
o.tabstop = indent
o.softtabstop = indent
o.shiftwidth = indent
-- o.completeopt = 'menuone,popup,preinsert'
o.completeopt = 'menuone,noselect,fuzzy,nosort'
o.mouse = 'a'

o.swapfile = false
o.backup = false
o.undodir = vim.fn.stdpath("data") .. "/undodir"

cmd.colorscheme('catppuccin')

api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    callback = function()
        vim.hl.on_yank()
    end,
})
