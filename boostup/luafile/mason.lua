vim.keymap.set("n", "<M-l>m", [[<Cmd>Mason<Cr>]], { noremap = true, silent = true })
require("mason").setup({
  install_root_dir = vim.fn.expand("~/.leovim.d/mason"),
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})
