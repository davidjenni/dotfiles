-- minimal, lite neovim configuration
-- loads just enough plugins to support markdown & lua LS/completions/formatting

local minVersion = '0.12.0'
if vim.fn.has('nvim-' .. minVersion) == 0 then
  vim.api.nvim_echo({
    { 'This nvim config requires neovim >= ' .. minVersion .. '\n', 'ErrorMsg' },
    { 'Press any key to exit', 'MoreMsg' },
  }, true, {})
  vim.fn.getchar()
  vim.cmd.quitall()
  return {}
end

-- set leader before loading plugins
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- load fidget's nicer notifications first
vim.pack.add({ 'https://github.com/j-hui/fidget.nvim' }, { confirm = false })
require('fidget').setup({
  display = {
    done_ttl = 8,
  },
  notification = {
    override_vim_notify = true,
  },
})

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
o.completeopt = 'menuone,popup,preinsert'
o.mouse = 'a'

cmd.colorscheme('catppuccin')

-- https://neovim.io/doc/user/pack/#_plugin-manager
vim.pack.add({
  -- sort by repo/plugin name:
  'https://github.com/stevearc/conform.nvim',
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('1.10') },
  'https://github.com/folke/lazydev.nvim',
  'https://github.com/williamboman/mason.nvim',
  'https://github.com/williamboman/mason-lspconfig.nvim',
  'https://github.com/echasnovski/mini.nvim',
  'https://github.com/mfussenegger/nvim-lint',
  'https://github.com/neovim/nvim-lspconfig',
}, { confirm = false })

vim.lsp.config['*'] = {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
}

-- global keybindings see: https://neovim.io/doc/user/lsp/#_defaults
vim.lsp.enable({
  'lua_ls',
  'marksman',
  'rumdl',
})
require('conform').setup({
  formatters_by_ft = {
    lua = { 'stylua' },
  },
  format_on_save = {
    lsp_format = 'fallback',
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
    nerd_font_variant = 'mono',
  },
  completion = {
    -- menu = { border = 'rounded' },
    documentation = { auto_show = true, auto_show_delay_ms = 500 },
  },
  fuzzy = {
    implementation = 'prefer_rust',
  },
  signature = { enabled = true },
  sources = {
    default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
    providers = {
      lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 },
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

-- this also configures lua_ls
require('lazydev').setup({
  library = {
    -- See the configuration section for more details
    -- Load luvit types when the `vim.uv` word is found
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
  },
})

require('lint').linters_by_ft = {
  lua = { 'selene' },
  markdown = { 'rumdl' },
}

local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
vim.api.nvim_create_autocmd({ 'LspAttach', 'BufReadPost', 'BufWritePost', 'InsertLeave' }, {
  group = lint_augroup,
  callback = function()
    if vim.bo.modifiable then
      local lint_status, lint = pcall(require, 'lint')
      if lint_status then
        local bufnr = vim.api.nvim_get_current_buf()
        local ft = vim.bo[bufnr].filetype
        local linters = lint.linters_by_ft[ft] or {}
        for _, linter in ipairs(linters) do
          local ns = lint.get_namespace and lint.get_namespace(linter) or nil
          if ns then
            vim.diagnostic.reset(ns, bufnr)
          end
        end
        lint.try_lint()
      end
    end
  end,
})

require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = { 'lua_ls', 'marksman' },
})
local toolsToInstall = { 'rumdl', 'stylua', 'selene' }
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

local set = vim.keymap.set
set('n', '[b', ':bprevious<CR>', { desc = 'previous buffer' })
set('n', ']b', ':bnext<CR>', { desc = 'next buffer' })
set('n', '[B', ':bfirst<CR>', { desc = 'first buffer' })
set('n', ']B', ':blast<CR>', { desc = 'last buffer' })
set('n', '<leader>l', function()
  o.list = not o.list
end, { desc = 'Toggle [l]istchars' })

set('n', '<leader>h', '<cmd>nohlsearch<CR>', { desc = 'Clear search [h]ighlights' })

-- diagnostics:
local virt_text = { source = 'always', prefix = '●' }
vim.diagnostic.config({ virtual_text = virt_text })

local function jumpDiagVirtLines(jumpCount)
  pcall(vim.api.nvim_del_augroup_by_name, 'jumpWithVirtLineDiags') -- prevent autocmd for repeated jumps

  vim.diagnostic.jump({ count = jumpCount })

  -- local org_virtual_text = vim.diagnostic.config().virtual_text
  vim.diagnostic.config({ virtual_text = false, virtual_lines = { current_line = true } })

  vim.defer_fn(function() -- deferred to not trigger by jump itself
    vim.api.nvim_create_autocmd('CursorMoved', {
      once = true,
      group = vim.api.nvim_create_augroup('jumpWithVirtLineDiags', {}),
      callback = function()
        vim.diagnostic.config({ virtual_lines = false, virtual_text = virt_text })
      end,
    })
  end, 1)
end
-- see other diag defaults: https://neovim.io/doc/user/diagnostic/#_defaults
-- selene: allow(multiple_statements)
vim.keymap.set('n', ']d', function()
  jumpDiagVirtLines(1)
end, { desc = '󰒕 Next diagnostic' })
-- selene: allow(multiple_statements)
vim.keymap.set('n', '[d', function()
  jumpDiagVirtLines(-1)
end, { desc = '󰒕 Prev diagnostic' })

local function toggle_quickfix()
  local windows = vim.fn.getwininfo()
  for _, win in pairs(windows) do
    if win['quickfix'] == 1 then
      cmd.cclose()
      return
    end
  end
  vim.diagnostic.setqflist()
  cmd.copen()
end
vim.keymap.set('n', '<leader>q', toggle_quickfix, { desc = 'Open diagnostic [Q]uickfix list' })
