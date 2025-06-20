name = "basedpyright"
filetypes = { "python" }
cmd = { "basedpyright-langserver", "--stdio" }
settings = {
  python = {
    venvPath = vim.fn.expand("~") .. "/.virtualenvs",
  },
  basedpyright = {
    disableOrganizeImports = true,
    analysis = {
      autoSearchPaths = true,
      autoImportCompletions = true,
      useLibraryCodeForTypes = true,
      diagnosticMode = "openFilesOnly",
      typeCheckingMode = "strict",
      inlayHints = {
        variableTypes = true,
        callArgumentNames = true,
        functionReturnTypes = true,
        genericTypes = false,
      },
    },
  },
}
