cmd = { "gopls" }
filetypes = { "go", "gotempl", "gowork", "gomod" }
hint = {
  enable = true,
}
codeLens = {
  enable = true
}
settings = {
  gopls = {
    analyses = {
      unusedparams = true,
    },
    staticcheck = vim.g.gobin_exe_version ~= nil and vim.g.gobin_exe_version > 1.1913,
    gofumpt = vim.g.gobin_exe_version ~= nil and vim.g.gobin_exe_version > 1.1913,
    completeUnimported = true,
    usePlaceholders = true,
    ["ui.inlayhint.hints"] = {
      compositeLiteralFields = true,
      constantValues = true,
      parameterNames = true,
      rangeVariableTypes = true,
    },
  },
}
