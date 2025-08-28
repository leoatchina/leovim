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
      vim.uv.cwd(),
    })
    client.config.root_dir = root
    return true
  end,
  -- 添加附加函数
  on_attach = function(client, bufnr)
    if client then
      vim.lsp.buf_attach_client(bufnr, client.id)
    end
  end,
}
