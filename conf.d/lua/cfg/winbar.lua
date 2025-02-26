require("winbar").setup({
  enabled = true,
  show_file_path = true,
  show_symbols = true,
  colors = {
    path = "", -- You can customize colors like #c946fd
    file_name = "",
    symbols = "",
  },
  icons = {
    file_icon_default = "",
    seperator = ">",
    editor_state = "●",
    lock_icon = "",
  },
  exclude_filetype = {
    "help",
    "startify",
    "dashboard",
    "neogitstatus",
    "netrw",
    "floaterm",
    "terminal",
    "flog",
    "fzf",
    "fugitive",
    "vim-plug",
    "qf",
    "NvimTree",
    "fern",
    "coc-explorer"
  },
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "fzf",
    "leaderf",
    "fern",
    "NvimTree",
    "vista",
    "vista_kind",
    "vista_toc",
    "netrw",
    "vim-plug",
    "nofile",
    "floaterm",
    "coctree",
    "fzf-funky",
  },
  callback = function()
    vim.wo.winbar = ""
  end,
})
vim.api.nvim_create_autocmd({ "BufEnter", "BufRead", "BufReadPost", "BufCreate" }, {
  callback = function()
    if vim.bo.buftype == "" or vim.bo.buftype == "terminal" then
      vim.wo.winbar = ""
    end
  end,
})
