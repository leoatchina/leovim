require("aerial").setup({
  -- optionally use on_attach to set keymaps when aerial has attached to a buffer
  on_attach = function(bufnr)
    -- Jump forwards/backwards with '{' and '}'
    vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
    vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
  end,
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
