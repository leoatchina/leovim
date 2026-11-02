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
  lsp = {
    diagnostics_trigger_update = false,
    update_when_errors = true,
  },
})

function M.open()
  -- Keep symbols attached to the code buffer while stacking below NvimTree.
  require('aerial').open({ focus = false })
  local tree, aerial
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
    if ft == 'NvimTree' then tree = win end
    if ft == 'aerial' then aerial = win end
  end
  if tree and aerial then
    vim.api.nvim_win_set_config(aerial, { win = tree, split = 'below' })
  end
end

return M
