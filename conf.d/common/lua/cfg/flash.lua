local exclude = {
  "notify",
  "cmp_menu",
  "noice",
  "flash_prompt",
  function(win)
    return not vim.api.nvim_win_get_config(win).focusable
  end,
}
-- NOTE: treesitter related mved to lsp.lua
require("flash").setup({
  labels = vim.g.EasyMotion_key,
  search = {
    exclude = exclude,
  },
  modes = {
    search = {
      enabled = false
    },
    char = {
      jump_labels = true,
      keys = {'f', 'F', 't', 'T'},
    },
    treesitter = {
      labels = vim.g.EasyMotion_key
    }
  }
})
local map = vim.keymap.set
-- omap
map({ 'o' }, 'r', function()
  require("flash").remote()
end, { silent = true })
-- buffer jump
map({ 'n', 'x', 'o' }, 'ss', function()
  require("flash").jump()
end, { silent = true })
-- jump forward
map({ 'n', 'x', 'o' }, 'sj', function()
  require("flash").jump({search = { forward = true,  wrap = false, multi_window = false }})
end, { silent = true })
-- jump backward
map({ 'n', 'x', 'o' }, 'sk', function()
  require("flash").jump({search = { forward = false, wrap = false, multi_window = false }})
end, { silent = true })
-- yank remote
map({ 'n', 'x', 'o' }, 'yr', function()
  require("flash").jump({remote_op = { restore = true, motion = true}})
end,  { silent = true })
-- yank remote
map({ 'n', 'x', 'o' }, 'ys', function()
  require("flash").jump({remote_op = { restore = true, motion = nil}})
end, { silent = true })
