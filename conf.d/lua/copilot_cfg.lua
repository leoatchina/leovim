local map = vim.keymap.set
local mode = { "n", "v", "x" }
local opts = { noremap = true, silent = true }
-- copilot
require('copilot').setup({
  panel = { enabled = false },
  suggestion = {
    enabled = false,
    keymap = {
      accept = "<M-i>",
      accept_word = "<M-}>",
      accept_line = "<M-{>",
      next = "<M-;>",
      prev = "<M-,>",
      dismiss = "<M-/>",
    },
  },
})
