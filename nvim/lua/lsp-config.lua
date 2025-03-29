local lsp = vim.lsp

-- https://neovim.io/doc/user/lsp.html#_config
vim.lsp.config['luals'] = {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc' },
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = {
          vim.env.VIMRUNTIME,
          "${3rd}/luv/library",
        }
        -- much slower, but more complete
        -- library = vim.api.nvim_get_runtime_file("", true),
      },
    },
  }
}

lsp.enable('luals')

-- use neovim's built-in LSP auto-completion (neovim >= 0.11.0)
-- https://neovim.io/doc/user/lsp.html#_quickstart
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})
