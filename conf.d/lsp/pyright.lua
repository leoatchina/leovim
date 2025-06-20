return {
  name = 'pyright',
  filetypes = { "python" },
  settings = {
    pyright = {
      disableOrganizeImports = false,
      disableTaggedHints = false,
    },
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        typeCheckingMode = "standard",
        useLibraryCodeForTypes = true,
        reportUnusedClass = 'hint',
        reportUnusedVariable = 'hint',
        reportUnusedFunction = 'hint',
        reportUnusedImport = 'hint',
      },
    },
  },
}

