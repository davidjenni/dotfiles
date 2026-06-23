local cmd = vim.cmd
local set = vim.keymap.set
local diag = vim.diagnostic

-- diagnostics:
local virt_text = { source = 'always', prefix = '●' }
diag.config({
  virtual_text = virt_text,
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
