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
    -- Spring Boot advertises document symbols but returns none for Java source.
    priority = { jdtls = 20, ['spring-boot'] = -1 },
    diagnostics_trigger_update = false,
    update_when_errors = true,
  },
})

function M.open()
  -- Keep symbols attached to code while stacking below the file tree at 4:6.
  require('aerial').open({ focus = false })
  local tree, aerial
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
    if ft == 'NvimTree' or ft == 'fern' then tree = win end
    if ft == 'aerial' then aerial = win end
  end
  if tree and aerial then
    vim.api.nvim_win_set_config(aerial, { win = tree, split = 'below' })
    -- Divide usable rows 4:6, excluding the split separator.
    local rows = vim.api.nvim_win_get_height(tree) + vim.api.nvim_win_get_height(aerial)
    vim.api.nvim_win_set_height(tree, math.max(1, math.floor(rows * 0.4)))
  end
end

vim.api.nvim_create_user_command('AerialTreeOpen', M.open, {
  desc = 'Open symbols below the file tree at 4:6 without changing focus',
})

return M
