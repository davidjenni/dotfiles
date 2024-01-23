return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  build = ":TSUpdate",
  config = function()
    require('nvim-treesitter.configs').setup({
      event = {
        "BufReadPre",
        "BufNewFile",
      },
      ensure_installed = { 'lua', 'markdown', 'vimdoc', 'vim' },
      auto_install = false,

      highlight = { enable = true },
      indent = { enable = true },

      -- treesitter-textobjects config:
      textobjects = {
        select = {
          enable = true,
          keymaps = {
            ["af"] = { query = "@function.outer", desc = "Select outer part of function" },
            ["if"] = { query = "@function.inner", desc = "Select inner part of function" },
            ["ac"] = { query = "@class.outer", desc = "Select outer part of a class region" },
            ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
          },
          selection_modes = {
            ['@parameter.outer'] = 'v', -- charwise
            ['@function.outer'] = 'V', -- linewise
            ['@class.outer'] = '<c-v>', -- blockwise
          },
        },
      }
    })
  end,
}
