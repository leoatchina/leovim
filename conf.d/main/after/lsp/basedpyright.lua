return {
  name = 'basedpyright',
  filetypes = { "python" },
  cmd = { "basedpyright-langserver", "--stdio" },
  settings = {
    basedpyright = {
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
  on_init = function(client)
    local root = vim.fs.root(0, {
      "pyproject.toml",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      "Pipfile",
      "pyrightconfig.json",
      ".git",
    }) or vim.uv.cwd()
    client.config.root_dir = root
    return true
  end,
}
