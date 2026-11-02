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

return M
