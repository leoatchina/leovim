require('codesettings').setup({
  config_file_paths = {".vim/codesettings.json",  ".vscode/settings.json", "codesettings.json", "lspsettings.json" },
})
vim.keymap.set('n', "<M-l>s", [[<Cmd>Codesettings show<Cr>]], {noremap = true, silent = true})
vim.keymap.set('n', "<M-l>l", [[<Cmd>Codesettings local<Cr>]], {noremap = true, silent = true})
vim.keymap.set('n', "<M-l>f", [[<Cmd>Codesettings files<Cr>]], {noremap = true, silent = true})
vim.keymap.set('n', "<M-l>e", [[<Cmd>Codesettings edit<Cr>]], {noremap = true, silent = true})
vim.keymap.set('n', "<M-l>h", [[<Cmd>Codesettings health<Cr>]], {noremap = true, silent = true})
