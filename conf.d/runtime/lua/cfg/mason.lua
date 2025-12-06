local registries
if is_installed('nvim-java') then
  registries = {
    "github:nvim-java/mason-registry",
    "github:mason-org/mason-registry"
  }
else
  registries = {
    "github:mason-org/mason-registry"
  }
end
is_require("mason").setup({
  registries = registries,
  install_root_dir = vim.fn.expand("~/.leovim.d/mason/" .. vim.g.complete_engine),
  ui = {
    icons = {
      package_installed = "âœ?,
      package_pending = "âž?,
      package_uninstalled = "âœ?,
    },
  },
})
vim.keymap.set("n", "<M-l>m", [[<Cmd>Mason<Cr>]], { noremap = true, silent = true })
