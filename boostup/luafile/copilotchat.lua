local chat = require "CopilotChat"
local map = vim.keymap.set
local modes = { "n", "i", "v", "x" }
local opts = { noremap = true, silent = true }
chat.setup({
  history_path = vim.fn.Expand("~/.leovim.d"):gsub("/$", "") .. "/copilot",
  window = {
    layout = 'float'
  }
})
map(modes, "<M-i><M-i>", [[<Cmd>CopilotChatToggle<Cr>]], opts)
map(modes, "<M-i>e", [[<Cmd>CopilotChatExplain<Cr>]], opts)
map(modes, "<M-i>o", [[<Cmd>CopilotChatOptimize<Cr>]], opts)
map(modes, "<M-i>t", [[<Cmd>CopilotChatTest<Cr>]], opts)
map(modes, "<M-i>f", [[<Cmd>CopilotChatFix<Cr>]], opts)
map(modes, "<M-i>F", [[<Cmd>CopilotChatFixDiagnostic<Cr>]], opts)
map(modes, "<M-i>C", [[<Cmd>CopilotChatCommit<Cr>]], opts)
map(modes, "<M-i>S", [[<Cmd>CopilotChatCommitStaged<Cr>]], opts)
