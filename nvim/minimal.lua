-- minimal, lite neovim configuration
-- loads just enough plugins to support lua LS and completions

local minVersion = '0.12.0'
if vim.fn.has("nvim-" .. minVersion) == 0 then
  vim.api.nvim_echo({
    { "This nvim config requires neovim >= " .. minVersion .. "\n", "ErrorMsg" },
    { "Press any key to exit", "MoreMsg" },
  }, true, {})
  vim.fn.getchar()
  vim.cmd([[quit]])
  return {}
end

-- set leader before loading plugins
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- load fidget's nicer notifications first
vim.pack.add({ 'https://github.com/j-hui/fidget.nvim' }, { confirm = false } )
require('fidget').setup({
  notification = {
    override_vim_notify = true,
  }
})

-- https://neovim.io/doc/user/pack/#_plugin-manager
vim.pack.add( {
  'https://github.com/folke/lazydev.nvim',
  'https://github.com/neovim/nvim-lspconfig',
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('1.10') },
  'https://github.com/williamboman/mason.nvim',
  'https://github.com/williamboman/mason-lspconfig.nvim',
  }, { confirm = false })

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
o.shortmess = 'atToOcI'
o.scrolloff = 10
o.sidescrolloff = 4
o.splitbelow = true
o.splitbelow = true
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
o.completeopt = "menuone,popup"

cmd.colorscheme("catppuccin")

vim.lsp.enable({
  'lua_ls',
  'stylua'
})

vim.lsp.config["*"] = {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
}

-- this also configures lua_ls
require('lazydev').setup({
  opts = {
    library = {
      -- See the configuration section for more details
      -- Load luvit types when the `vim.uv` word is found
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  },
})

require('blink.cmp').setup({
  keymap = {
    -- https://cmp.saghen.dev/configuration/keymap.html#default
    preset = 'default',
    ['<CR>'] = { 'select_and_accept', 'fallback' },
    ['<Tab>'] = { 'select_and_accept', 'fallback' },
},
  appearance = {
    nerd_font_variant = 'mono'
  },
  completion = {
    -- menu = { border = 'rounded' },
    documentation = { auto_show = true, auto_show_delay_ms = 500 }
  },
  fuzzy = {
    implementation = "prefer_rust"
  },
  signature = { enabled = true  },
  sources = {
    default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = 'lazydev.integrations.blink',
        score_offset = 100
      },
      path = {
        opts = {
          get_cwd = function(_)
            return vim.fn.getcwd()
          end,
        },
      },
    },
  },
})

require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = { 'lua_ls', 'stylua' },
})

local set = vim.keymap.set
set("n", "[b", ":bprevious<CR>", { desc = "previous buffer" })
set("n", "]b", ":bnext<CR>", { desc = "next buffer" })
set("n", "[B", ":bfirst<CR>", { desc = "first buffer" })
set("n", "]B", ":blast<CR>", { desc = "last buffer" })
set('n', '<leader>l', function()
    o.list = not o.list
  end, { desc = 'Toggle [l]istchars' })

set('n', '<leader>h', '<cmd>nohlsearch<CR>', { desc = 'Clear search [h]ighlights' })

-- see other diag defaults: https://neovim.io/doc/user/diagnostic/#_defaults
set("n", "<leader>D", vim.diagnostic.open_float, { desc = 'Show current line [D]iagnostics' })

local function toggle_quickfix()
  local windows = vim.fn.getwininfo()
  for _, win in pairs(windows) do
    if win["quickfix"] == 1 then
      cmd.cclose()
      return
    end
  end
  vim.diagnostic.setqflist()
  cmd.copen()
end
vim.keymap.set('n', '<leader>q', toggle_quickfix, { desc = 'Open diagnostic [Q]uickfix list' })

