return {
  name = 'pyright',
  filetypes = { "python" },
  cmd = executable('delance-langserver') and {'delance-langserver', '--stdio'} or {'pyright-langserver', '--stdio'},
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
        -- we can this setting below to redefine some diagnostics
        diagnosticSeverityOverrides = {
          deprecateTypingAliases = false,
        },
        -- inlay hint settings are provided by pylance?
        inlayHints = {
          callArgumentNames = "partial",
          functionReturnTypes = true,
          pytestParameters = true,
          variableTypes = true,
        },
      },
    },
  },
}

