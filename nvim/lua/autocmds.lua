local api = vim.api

api.nvim_create_augroup("custom_buffer", { clear = true })
api.nvim_create_autocmd("TextYankPost", {
  group = "custom_buffer",
  pattern = "*",
  callback = function() vim.highlight.on_yank { timeout = 200 } end
})

