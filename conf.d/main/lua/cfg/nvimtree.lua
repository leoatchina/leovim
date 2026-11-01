local M = {}

require('nvim-tree').setup({
  view = {
    side = 'left',
    width = function()
      return vim.g.sidebar_width or 40
    end,
    centralize_selection = true,
  },
  renderer = {
    group_empty = true, -- IDEA 风格：折叠中间空包 (如 com.example.service)
    highlight_git = "name",
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
    },
  },
  filters = {
    dotfiles = false,
    custom = { '^\\.git$' },
  },
  actions = {
    open_file = {
      quit_on_open = false,
      resize_window = false,
    },
  },
})

return M
