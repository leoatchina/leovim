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
map(modes, "<M-i><M-l>", [[<Cmd>CopilotChatToggle<Cr>]], opts)
map(modes, "<M-i>e", [[<Cmd>CopilotChatExplain<Cr>]], opts)
map(modes, "<M-i>o", [[<Cmd>CopilotChatOptimize<Cr>]], opts)
map(modes, "<M-i>t", [[<Cmd>CopilotChatTest<Cr>]], opts)
map(modes, "<M-i>f", [[<Cmd>CopilotChatFix<Cr>]], opts)
map(modes, "<M-i>d", [[<Cmd>CopilotChatFixDiagnostic<Cr>]], opts)
map(modes, "<M-i>C", [[<Cmd>CopilotChatCommit<Cr>]], opts)
map(modes, "<M-i>S", [[<Cmd>CopilotChatCommitStaged<Cr>]], opts)
require('copilot').setup({
  panel = { enabled = false },
  suggestion = { enabled = false},
})
if Installed('avante.nvim') then
  require('avante').setup({
    ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
    provider = "copilot", -- Recommend using Claude
    behaviour = {
      auto_suggestions = false, -- Experimental stage
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = false,
    },
    copilot = {
      endpoint = "https://api.githubcopilot.com",
      model = "gpt-4o-2024-05-13",
      proxy = nil,
      allow_insecure = true,
      timeout = 30000,
      temperature = 0,
      max_tokens = 4096 * 128,
    },
    mappings = {
      --- @class AvanteConflictMappings
      diff = {
        ours = "co",
        theirs = "ct",
        all_theirs = "ca",
        both = "cb",
        cursor = "cc",
        next = "c]",
        prev = "c[",
      },
      suggestion = {
        accept = "<M-.>",
        next = "<M-;>",
        prev = "<M-,>",
        dismiss = "<M-?>",
      },
      jump = {
        next = "]]",
        prev = "[[",
      },
      submit = {
        normal = "<CR>",
        insert = "<C-s>",
      },
      ask = "<M-i><M-i>",
      edit = "<M-i><M-e>",
      refresh = "<M-i><M-r>",
      toggle = {
        default = "<M-i><M-t>",
        debug = "<M-i><M-d>",
        hint = "<M-i><M-h>",
        suggestion = "<M-i><M-s>",
      }
    },
    hints = { enabled = true },
    windows = {
      ---@type "right" | "left" | "top" | "bottom"
      position = "right", -- the position of the sidebar
      wrap = true, -- similar to vim.o.wrap
      width = 30, -- default % based on available width
      sidebar_header = {
        align = "center", -- left, center, right for title
        rounded = true,
      },
    },
    highlights = {
      ---@type AvanteConflictHighlights
      diff = {
        current = "DiffText",
        incoming = "DiffAdd",
      },
    },
    --- @class AvanteConflictUserConfig
    diff = {
      autojump = true,
      ---@type string | fun(): any
      list_opener = "copen",
    },
  })
  require('avante_lib').load()
end
