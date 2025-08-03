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
      multi_window = true,
      keys = {'f', 'F', 't', 'T'},
    },
    treesitter = {
      labels = vim.g.EasyMotion_key
    }
  }
})
local map = vim.keymap.set
-- buffer jump
map({ 'n', 'x'}, 'ss', function()
  require("flash").jump()
end, { silent = true })
map({ 'o' }, 's', function()
  require("flash").jump()
end, { silent = true })
-- jump forward
map({ 'n', 'x'}, 'sj', function()
  require("flash").jump({search = { forward = true,  wrap = false, multi_window = false }})
end, { silent = true })
map({ 'o' }, 'j', function()
  require("flash").remote({search = { forward = true,  wrap = false, multi_window = false }})
end, { silent = true })
-- jump backward
map({ 'n', 'x' }, 'sk', function()
  require("flash").jump({search = { forward = false, wrap = false, multi_window = false }})
end, { silent = true })
map({ 'o' }, 'k', function()
  require("flash").remote({search = { forward = false, wrap = false, multi_window = false }})
end, { silent = true })
-- remote
map({ 'o' }, 'r', function()
  require("flash").remote()
end,  { silent = true })
-- treesitter_search
if Installed('nvim-treesitter') then
  map({ 'x', 'o' }, 'R', function()
    require("flash").treesitter_search()
  end, { silent = true })
end
