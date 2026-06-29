local cmd = vim.cmd
local set = vim.keymap.set
local diag = vim.diagnostic

-- diagnostics:
diag.config({
  -- float = {
  --   border = 'rounded',
  --   source = 'if_many',
  -- },
  severity_sort = true,
  virtual_text = {
    prefix = '●',
    source = 'if_many',
    spacing = 6,
  },
  signs = {
    active = true,
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚",  -- icon for error
      [vim.diagnostic.severity.WARN]  = "󰀪",  -- icon for warning
      [vim.diagnostic.severity.INFO]  = "󰋽",  -- icon for info
      [vim.diagnostic.severity.HINT]  = "󰌶",  -- icon for hint
    },
  },
})

require('mason-lspconfig').setup({
  ensure_installed = { 'jsonls', 'lua_ls', 'roslyn_ls', 'rust_analyzer' },
})
-- local toolsToInstall = { 'stylua' }
local toolsToInstall = { }
for _, tool in ipairs(toolsToInstall) do
  if vim.fn.executable(tool) == 0 then
    cmd([[MasonInstall ]] .. tool)
  end
end

set("n", "<leader>q", function()
  diag.setloclist({ open = true })
end, { desc = "Open diagnostic list" })

vim.lsp.enable({ 'jsonls', 'lua_ls' })

vim.o.autocomplete = false

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', {}),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    -- if client:supports_method('textDocument/implementation') then
    --   -- Create a keymap for vim.lsp.buf.implementation ...
    -- end

    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, {autotrigger = false})

      local function feedkeys(keys)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'n', true)
      end

      local function pumvisible()
        return tonumber(vim.fn.pumvisible()) ~= 0
      end

      -- vim.lsp.handlers["textDocument/hover"] = function(_, _, _, config)
      --   config = config or {}
      --   config.border = 'rounded'
      --   vim.lsp.buf.signature_help( { config })
      -- end
      set("i", "<c-space>", function() vim.lsp.completion.get() end, { desc = 'Start completion popup menu'})

      set('i', '<cr>', function()
        if pumvisible() then feedkeys '<C-y>' else feedkeys '<cr>' end
      end, { desc = 'Accept current selected completion' })

      set('i', '/', function()
        if pumvisible() then feedkeys '<C-e>' else feedkeys '/' end
      end, { desc = 'Dismiss completion menu' })

      -- LSP key mappings:
      set('i', '<C-u>', '<C-x><C-n>', { desc = 'Buffer completions' })

      set({ 'i', 's' }, '<Tab>', function()
        if pumvisible() then
          feedkeys '<C-n>'
        elseif vim.snippet.active { direction = 1 } then
          vim.snippet.jump(1)
        else
          feedkeys '<Tab>'
        end
      end, { desc = 'Select next completion' })

      set({ 'i', 's' }, '<S-Tab>', function()
        if pumvisible() then
          feedkeys '<C-p>'
        elseif vim.snippet.active { direction = -1 } then
          vim.snippet.jump(-1)
        else
          feedkeys '<S-Tab>'
        end
      end, { desc = 'Select previoua completion' })

      -- Inside a snippet, use backspace to remove the placeholder.
      set('s', '<BS>', '<C-o>s', { desc = 'Remove snippet placeholder' })
    end

    -- Auto-format ("lint") on save.
    -- if not client:supports_method('textDocument/willSaveWaitUntil')
    --     and client:supports_method('textDocument/formatting') then
    --   vim.api.nvim_create_autocmd('BufWritePre', {
    --     group = vim.api.nvim_create_augroup('my.lsp', {clear=false}),
    --     buffer = ev.buf,
    --     callback = function()
    --       vim.lsp.buf.format({ bufnr = ev.buf, id = client.id, timeout_ms = 1000 })
    --     end,
    --   })
    -- end
  end,
})
