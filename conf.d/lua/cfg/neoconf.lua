require("neoconf").setup({
  -- name of the local settings files
  local_settings = ".vim/.neoconf.json",
  import = {
    vscode = true,
    coc = true,
    nlsp = false,
  }
})
vim.keymap.set('n', "<M-l>n", [[<Cmd>Neoconf local<Cr>]], {noremap = true, silent = true})
vim.keymap.set('n', "<M-l>g", [[<Cmd>Neoconf glocal<Cr>]], {noremap = true, silent = true})
vim.keymap.set('n', "<M-l>s", [[<Cmd>Neoconf show<Cr>]], {noremap = true, silent = true})
vim.keymap.set('n', "<M-l>l", [[<Cmd>Neoconf lsp<Cr>]], {noremap = true, silent = true})
