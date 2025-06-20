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
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    local ok, venv = pcall(require, "rj.extras.venv")
    if ok then
      venv.setup()
    end
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
    local client =
      vim.lsp.start(vim.tbl_extend("force", vim.lsp.config.basedpyright, { root_dir = root }), { attach = false })
    if client then
      vim.lsp.buf_attach_client(0, client)
    end
  end,
})
