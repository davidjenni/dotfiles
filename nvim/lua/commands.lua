local api = vim.api
local opt = vim.opt

local augroup = api.nvim_create_augroup("user.commands", { clear = true })

api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  pattern = "*",
  desc = "Highlight when yanking (copying) text",
  callback = function()
    vim.hl.on_yank()
  end,
})

api.nvim_create_autocmd("WinEnter", {
  group = augroup,
  pattern = "*",
  callback = function()
    local function count_non_floating_wins()
      local count = 0
      for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
        local cfg = api.nvim_win_get_config(win)
        if cfg.relative == "" then -- Empty means it's not floating
          count = count + 1
        end
      end
      return count
    end

    local locWins = count_non_floating_wins()
    if locWins > 1 then
      opt.winbar = "%f %m"
    else
      opt.winbar = ""
    end
  end
})



