
return {
  {
   "folke/neodev.nvim",
    -- neodev needs to start before nvim-lspconfig
    priority = 1000,
    config = function()
        require("neodev").setup({})
    end,
  },

  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },

  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls" },
      })
    end
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "folke/neodev.nvim",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "j-hui/fidget.nvim",
    },
    config = function()
      local lspconfig = require('lspconfig')
      lspconfig.lua_ls.setup({})

      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Show info about symbol under cursor'})
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
      vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { desc = 'Show code actions' })
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Show references' })
    end
  },

  {
    "j-hui/fidget.nvim",
    config = function()
      require("fidget").setup({})
    end
  }
}
