require('java').setup()

-- Neovim consumes JDTLS symbols; it does not provide a client-side symbol service.
-- nvim-java's true default makes JDTLS hide documentSymbolProvider from Aerial.
vim.lsp.config('jdtls', {
  init_options = {
    extendedClientCapabilities = {
      clientDocumentSymbolProvider = false,
    },
  },
})
vim.lsp.enable('jdtls')
