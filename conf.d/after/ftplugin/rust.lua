local unpack = unpack or table.unpack
local map = vim.keymap.set
vim.g.rustaceanvim = {
  server = {
    on_attach = function(client, bufnr)
      -- you can also put keymaps in here
      map("i", "<M-M>", vim.lsp.buf.signature_help, opts_silent)
    end,
  }
}
