vim.pack.add({
  'https://github.com/j-hui/fidget.nvim',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/stevearc/oil.nvim',
  'https://github.com/williamboman/mason.nvim',
  'https://github.com/williamboman/mason-lspconfig.nvim',
}, { confirm = false })

local set = vim.keymap.set

-- nicer notifications:
require('fidget').setup({
  display = {
    done_ttl = 8,
  },
  notification = {
    override_vim_notify = true,
  },
})

require('mini.cmdline').setup()
require('mini.icons').setup()

local win_config = function()
  local height = math.floor(0.618 * vim.o.lines)
  local width = math.floor(0.618 * vim.o.columns)
  return {
    anchor = 'NW', height = height, width = width,
    row = math.floor(0.5 * (vim.o.lines - height)),
    col = math.floor(0.5 * (vim.o.columns - width)),
  }
end
local _miniPick = require("mini.pick")
_miniPick.setup(
  -- Centered on screen
  { window = { config = win_config } }
)
set("n", "<leader>b", function() _miniPick.builtin.buffers() end, { desc = "Buffer picker" })
set("n", "<leader>f", function() _miniPick.builtin.files() end, { desc = "Files picker" })
set("n", "<leader>h", function() _miniPick.builtin.help() end, { desc = "Help picker" })

require("oil").setup()
set("n", "-", "<cmd>Oil --float<CR>", { desc = "Toggle floating Oil file explorer" })

require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = { 'lua_ls' },
})
local toolsToInstall = { 'stylua' }
for _, tool in ipairs(toolsToInstall) do
  if vim.fn.executable(tool) == 0 then
    cmd([[MasonInstall ]] .. tool)
  end
end

require('mini.surround').setup({
  -- retain muscle memory from tpope's vim-surround
  mappings = {
    add = 'ys',
    delete = 'ds',
    find = '',
    find_left = '',
    highlight = '',
    replace = 'cs',
    suffix_last = '',
    suffix_next = '',
  },
})

