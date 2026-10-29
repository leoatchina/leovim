return {
  filetypes = { "lua" },
  root_markers = vim.list_extend({ '.luarc.json', '.luarc.jsonc' }, vim.g.root_patterns or { '.git' }),
  hint = {
    enable = true,
  },
  codeLens = {
    enable = false,
  },
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  }
}
