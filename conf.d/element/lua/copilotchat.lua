local map = vim.keymap.set
local mode = { "n", "v", "x" }
local opts = { noremap = true, silent = true }
require "CopilotChat".setup({
  history_path = vim.fn.Expand("~/.leovim.d"):gsub("/$", "") .. "/copilot",
  window = {
    layout = 'float'
  }
})
map(mode, "<M-i><M-l>", [[<Cmd>CopilotChatToggle<Cr>]], opts)
map(mode, "<M-i>e", [[<Cmd>CopilotChatExplain<Cr>]], opts)
map(mode, "<M-i>o", [[<Cmd>CopilotChatOptimize<Cr>]], opts)
map(mode, "<M-i>t", [[<Cmd>CopilotChatTest<Cr>]], opts)
map(mode, "<M-i>f", [[<Cmd>CopilotChatFix<Cr>]], opts)
map(mode, "<M-i>d", [[<Cmd>CopilotChatFixDiagnostic<Cr>]], opts)
map(mode, "<M-i>C", [[<Cmd>CopilotChatCommit<Cr>]], opts)
map(mode, "<M-i>S", [[<Cmd>CopilotChatCommitStaged<Cr>]], opts)
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
