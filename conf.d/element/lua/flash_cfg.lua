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
      jump_labels = true
    },
    treesitter = {
      labels = vim.g.EasyMotion_key
    }
  }
})
local map = vim.keymap.set
map({ 'n', 'x', 'o' }, 'so', function() require("flash").jump() end, { silent = true })
map({ 'n', 'x', 'o' }, 'sj', function() require("flash").jump({search = { forward = true,  wrap = false, multi_window = false }}) end, { silent = true })
map({ 'n', 'x', 'o' }, 'sk', function() require("flash").jump({search = { forward = false, wrap = false, multi_window = false }}) end, { silent = true })
map({ 'c', 'i' }, '<C-s>', function() require("flash").toggle() end, { silent = false })
map({ 'o' }, 'r', function() require("flash").remote() end, { silent = true })
