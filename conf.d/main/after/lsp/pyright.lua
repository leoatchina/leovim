return {
  name = 'pyright',
  filetypes = { "python" },
  cmd = vim.fn.executable("delance-langserver") == 1 and {"delance-langserver", "--stdio"} or {"pyright-langserver", "--stdio"},
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
  -- 添加启动函数
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
