-- minimal, lite neovim configuration
-- loads just enough plugins to support markdown & lua LS/completions

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
  'https://github.com/mfussenegger/nvim-lint',
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
  'rumdl',
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
      lazydev = { name = "LazyDev", module = 'lazydev.integrations.blink', score_offset = 100 },
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

require('lint').linters_by_ft = {
  lua = { 'selene' },
  markdown = { 'rumdl' },
}
vim.api.nvim_create_autocmd({ "InsertLeave", "BufWritePost" }, {
  callback = function()
    local lint_status, lint = pcall(require, "lint")
    if lint_status then
      lint.try_lint()
    end
  end,
})

require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = { 'lua_ls', 'rumdl' },  -- selene needds to be manually installed via :Mason
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

-- diagnostics:
local virt_text = { source = "if_many", prefix = '●' }
vim.diagnostic.config({ virtual_text = virt_text })

local function jumpDiagVirtLines(jumpCount)
  pcall(vim.api.nvim_del_augroup_by_name, "jumpWithVirtLineDiags") -- prevent autocmd for repeated jumps

  vim.diagnostic.jump { count = jumpCount }

  -- local org_virtual_text = vim.diagnostic.config().virtual_text
  vim.diagnostic.config { virtual_text = false, virtual_lines = { current_line = true } }

  vim.defer_fn(function() -- deferred to not trigger by jump itself
    vim.api.nvim_create_autocmd("CursorMoved", {
      once = true,
      group = vim.api.nvim_create_augroup("jumpWithVirtLineDiags", {}),
      callback = function()
        vim.diagnostic.config { virtual_lines = false, virtual_text = virt_text }
      end,
    })
  end, 1)
end
-- see other diag defaults: https://neovim.io/doc/user/diagnostic/#_defaults
-- selene: allow(multiple_statements)
vim.keymap.set("n", "]d", function() jumpDiagVirtLines(1) end, { desc = "󰒕 Next diagnostic" })
-- selene: allow(multiple_statements)
vim.keymap.set("n", "[d", function() jumpDiagVirtLines(-1) end, { desc = "󰒕 Prev diagnostic" })

-- vim.diagnostic.config(virtual_Lines = new_config)
-- vim.ss
--
-- vim.defer_fn()

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

