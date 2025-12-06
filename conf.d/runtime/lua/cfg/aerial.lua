is_require("aerial").setup({
  layout = {
    default_direction = "prefer_left",
  },
    -- Options for the floating nav windows
  nav = {
    preview = true,
    -- Keymaps in the nav window
    keymaps = {
      ["<C-]>"] = "actions.jump_vsplit",
      ["<C-s>"] = "actions.jump_split",
      ["q"] = "actions.close"
    },
  },
})
