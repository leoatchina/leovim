local unpack = unpack or table.unpack
local map = vim.keymap.set
vim.g.rustaceanvim = {
  server = {
    on_attach = function(client, bufnr)
      -- you can also put keymaps in here
    end,
  }
}
