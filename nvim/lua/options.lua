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

-- frappe palette
local ttt={
	rosewater = "#f2d5cf",
	flamingo = "#eebebe",
	pink = "#f4b8e4",
	mauve = "#ca9ee6",
	red = "#e78284",
	maroon = "#ea999c",
	peach = "#ef9f76",
	yellow = "#e5c890",
	green = "#a6d189",
	teal = "#81c8be",
	sky = "#99d1db",
	sapphire = "#85c1dc",
	blue = "#8caaee",
	lavender = "#babbf1",
	text = "#c6d0f5",
	subtext1 = "#b5bfe2",
	subtext0 = "#a5adce",
	overlay2 = "#949cbb",
	overlay1 = "#838ba7",
	overlay0 = "#737994",
	surface2 = "#626880",
	surface1 = "#51576d",
	surface0 = "#414559",
	base = "#303446",
	mantle = "#292c3c",
	crust = "#232634",
}
