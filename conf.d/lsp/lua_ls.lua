filetypes = { "lua" }
root_markers = function ()
  local lst = vim.g.root_parterns
  table.insert(lst, '.luarc.json')
  return lst
end
hint = {
  enable = true,
}
codeLens = {
  enable = false,
}
settings = {
  Lua = {
    diagnostics = {
      globals = { "vim" },
    },
  },
}
