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
--
k.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

k.set("n", "<leader>fp", "<cmd>echo expand('%:p')<cr>", { desc = "Show full path of current buffer"})

local nvimTreeFocusOrToggle = function ()
	local nvimTree=require("nvim-tree.api")
	local currentBuf = vim.api.nvim_get_current_buf()
	local currentBufFt = vim.api.nvim_get_option_value("filetype", { buf = currentBuf })
	if currentBufFt == "NvimTree" then
		nvimTree.tree.toggle()
	else
		nvimTree.tree.focus()
	end
end


vim.keymap.set("n", "<leader>e", nvimTreeFocusOrToggle, { desc = "Toggle tree explorer"})
