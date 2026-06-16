vim.pack.add({
  { src="https://github.com/catppuccin/nvim", name = "catppuccin" },
  'https://github.com/j-hui/fidget.nvim',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/nvim-lualine/lualine.nvim',
  'https://github.com/stevearc/oil.nvim',
  'https://github.com/williamboman/mason.nvim',
  'https://github.com/williamboman/mason-lspconfig.nvim',
}, { confirm = false })

local cmd = vim.cmd
local set = vim.keymap.set

require("catppuccin").setup({
  flavour = "frappe",
  transparent_background = true,
  custom_highlights = function(colors)
    local sepColor = colors.mauve
    return {
      WinSeparator = { fg = sepColor },
      VertSplit = { fg = sepColor },
    }
  end
})
cmd.colorscheme('catppuccin')

-- nicer notifications:
require('fidget').setup({
  display = {
    done_ttl = 15,
  },
  notification = {
    override_vim_notify = true,
  },
})

require('mini.icons').setup()

require("lualine").setup({
  options = {
    theme = "auto",
    globalstatus = true,
    component_separators = { left = "|", right = "|" },
    section_separators = { left = "", right = "" },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { "filename", "filesize" },
    lualine_x = { "encoding", "fileformat", "filetype" },
    lualine_y = { "progress", "searchcount", "lsp_status" },
    lualine_z = { "location", '%B' },
  },
  tabline = {},
})

require('mini.cmdline').setup()

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
  {
    window = { config = win_config },
    mappings = {
      move_down = '<C-j>',
      move_up = '<C-k>',
    }
  }
)
set("n", "<leader>b", function() _miniPick.builtin.buffers() end, { desc = "Buffer picker" })
set("n", "<leader>f", function() _miniPick.builtin.files() end, { desc = "Files picker" })
set("n", "<leader>h", function() _miniPick.builtin.help() end, { desc = "Help picker" })
set("n", "<leader>/", function() _miniPick.builtin.grep_live() end, { desc = "Help picker" })

require("oil").setup({
  columns = { "icons", "size", "mtime" },
  keymaps = {
    ["<Esc><Esc>"] = { "actions.close", mode = "n" },
  },
  view_options = {
    sort = {
      { "type", "asc" },
      { "name", "asc" },
    }
  },
  float = {
    max_width = 0.6,
    max_height = 0.4,
  },
})
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

