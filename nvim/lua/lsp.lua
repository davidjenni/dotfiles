local cmd = vim.cmd
local set = vim.keymap.set
local diag = vim.diagnostic

-- diagnostics:
local virt_text = { source = 'always', prefix = '●' }
diag.config({ virtual_text = virt_text })

set("n", "<leader>q", function()
  diag.setloclist({ open = true })
end, { desc = "Open diagnostic list" })
