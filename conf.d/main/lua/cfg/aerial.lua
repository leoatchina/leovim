local M = {}

require("aerial").setup({
  layout = {
    default_direction = "prefer_left",
    resize_to_content = false,
    max_width = { 60, 0.4 },
    min_width = 35,
  },
  -- Options for the floating nav windows
  nav = {
    preview = true,
    keymaps = {
      ["<C-]>"] = "actions.jump_vsplit",
      ["<C-x>"] = "actions.jump_split",
      ["q"] = "actions.close"
    },
  },
})

function M.open_symbol_tree()
  local code_win = vim.api.nvim_get_current_win()
  local width = vim.g.sidebar_width or 40
  local api = require('nvim-tree.api')

  -- 1. Close any conflicting sidebars (Fern, existing Aerial/NvimTree)
  pcall(function() require('aerial').close() end)
  pcall(function() api.tree.close() end)
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    local b = vim.api.nvim_win_get_buf(w)
    local ft = vim.bo[b].filetype
    if ft == 'fern' or ft == 'vista' or ft == 'tagbar' then
      pcall(vim.api.nvim_win_close, w, true)
    end
  end

  -- 2. Open NvimTree
  api.tree.open({ focus = false })

  local tree_win = nil
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    local b = vim.api.nvim_win_get_buf(w)
    if vim.bo[b].filetype == 'NvimTree' then
      tree_win = w
      break
    end
  end

  -- 3. Split below inside tree_win and open Aerial
  if tree_win and vim.api.nvim_win_is_valid(tree_win) then
    vim.api.nvim_win_set_width(tree_win, width)
    vim.api.nvim_set_current_win(tree_win)
    vim.cmd('belowright split')
    local lower_win = vim.api.nvim_get_current_win()
    require('aerial').open_in_win(lower_win, code_win)
    vim.api.nvim_win_set_width(lower_win, width)
    vim.api.nvim_set_current_win(code_win)
  end
end

function M.close_symbol_tree()
  pcall(function() require('aerial').close() end)
  pcall(function() require('nvim-tree.api').tree.close() end)
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    local b = vim.api.nvim_win_get_buf(w)
    local ft = vim.bo[b].filetype
    if ft == 'aerial' or ft == 'NvimTree' then
      pcall(vim.api.nvim_win_close, w, true)
    end
  end
end

vim.api.nvim_create_user_command('SymbolTreeOpen', M.open_symbol_tree, { desc = 'Open NvimTree (top) and Aerial (bottom) on left' })
vim.api.nvim_create_user_command('SymbolTreeClose', M.close_symbol_tree, { desc = 'Close NvimTree and Aerial' })

return M
