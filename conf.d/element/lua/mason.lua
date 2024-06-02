if Installed('nvim-java') then
  local registries = {
    "github:nvim-java/mason-registry",
    "github:mason-org/mason-registry"
  }
else
  local registries = {
    "github:mason-org/mason-registry"
  }
end
require("mason").setup({
  registries = registries,
  install_root_dir = vim.fn.expand("~/.leovim.d/mason"),
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})
vim.keymap.set("n", "<M-l>m", [[<Cmd>Mason<Cr>]], { noremap = true, silent = true })
