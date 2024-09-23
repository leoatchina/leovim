vim.keymap.set({ "n", "v", "x" }, "<M-i><M-a>", [[<Cmd>AvanteCommands<Cr>]], { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "x" }, "<M-i><M-c>", [[<Cmd>AvanteClear<Cr>]], { noremap = true, silent = true })
local max_tokens = vim.g.max_tokens
  and type(vim.g.max_tokens) == 'number'
  and vim.g.max_tokens > 0
  and vim.g.max_tokens < 8192
  and vim.g.max_tokens
  or 8192
local provider = vim.g.avante_provider
  or vim.fn.exists('$ANTHROPIC_API_KEY') > 0 and 'claude'
  or vim.fn.exists('$OPENAI_API_KEY') > 0 and 'openai'
  or 'copilot'
require('avante').setup({
  ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
  provider = provider,
  auto_suggestions_provider = vim.g.avante_suggestions_provider or provider,
  claude = {
    model = vim.g.claude_model or "claude-3-5-sonnet-20240620",
    max_tokens =  max_tokens
  },
  copilot = {
    model = vim.g.copilot_model or "gpt-4o-2024-05-13",
    max_tokens =  max_tokens
  },
  openai = {
    model = vim.g.openai_model or "gpt-4o",
    max_tokens = max_tokens
  },
  behaviour = {
    auto_suggestions = provider ~= 'copilot', -- Experimental stage
    auto_set_highlight_group = true,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = false,
    support_paste_from_clipboard = true,
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
      accept = "<M-i>",
      next = "<M-;>",
      prev = "<M-,>",
      dismiss = "<M-/>",
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
