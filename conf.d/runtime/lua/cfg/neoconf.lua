local utils = require('utils')

require("neoconf").setup({
  -- name of the local settings files
  local_settings = ".vim/neoconf.json",
  import = {
    vscode = true,
    coc = false,
    nlsp = false,
  }
})
vim.keymap.set('n', "<M-l>l", [[<Cmd>Neoconf local<Cr>]], {noremap = true, silent = true})
vim.keymap.set('n', "<M-l>g", [[<Cmd>Neoconf glocal<Cr>]], {noremap = true, silent = true})
vim.keymap.set('n', "<M-l>s", [[<Cmd>Neoconf show<Cr>]], {noremap = true, silent = true})
vim.keymap.set('n', "<M-l>L", [[<Cmd>Neoconf lsp<Cr>]], {noremap = true, silent = true})
-- neoconf.json 文件
function _G.OpenNeoconfJson()
  local vim_dir = utils.get_root_dir() .. "/.vim"
  local neoconf_json = vim_dir .. "/neoconf.json"
  if vim.fn.isdirectory(vim_dir) == 0 then
    vim.fn.mkdir(vim_dir, "p")
  end
  vim.cmd("tabedit " .. neoconf_json)
end
vim.keymap.set('n', "<M-l>o", OpenNeoconfJson, {noremap = true, silent = true, desc = "Open neoconf.json"})
