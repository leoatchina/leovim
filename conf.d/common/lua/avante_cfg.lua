vim.keymap.set({ "n", "v", "x" }, "<M-i><M-a>", [[<Cmd>AvanteCommands<Cr>]], { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "x" }, "<M-i><M-c>", [[<Cmd>AvanteClear<Cr>]], { noremap = true, silent = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "AvanteInput",
  callback = function()
    vim.keymap.set("i", "<C-s>", "<ESC>", { noremap = false, silent = true, buffer = true })
  end,
})
local max_tokens = type(vim.g.max_tokens) == 'number'
  and vim.g.max_tokens > 0
  and vim.g.max_tokens < 4096
  and vim.g.max_tokens
  or 4096
local provider = vim.g.avante_provider
  or vim.fn.exists('$ANTHROPIC_API_KEY') > 0 and 'claude'
  or vim.fn.exists('$OPENAI_API_KEY') > 0 and 'openai'
  or 'copilot'
local suggestions_provider = vim.g.avante_suggestions_provider or provider
vim.g.claude_model = vim.g.claude_model or "claude-3-haiku-20240307"
vim.g.openai_model = vim.g.openai_model or "gpt-4o"
vim.g.copilot_model = vim.g.copilot_model or "gpt-4o-2024-05-13"
vim.g.avante_model = string.find(provider, 'claude') and vim.g.claude_model
  or string.find(provider, 'openai') and vim.g.openai_model
  or vim.g.copilot_model
-- setup
require('avante').setup({
  ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
  provider = provider,
  auto_suggestions_provider = suggestions_provider,
  claude = {
    model = vim.g.claude_model,
    max_tokens = max_tokens
  },
  openai = {
    model = vim.g.openai_model,
    max_tokens = max_tokens
  },
  copilot = {
    model = vim.g.copilot_model,
    max_tokens = max_tokens
  },
  behaviour = {
    auto_suggestions = suggestions_provider ~= 'copilot' or not Installed('copilot-cmp'),
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
    focus = "<M-i><M-f>",
    refresh = "<M-i><M-r>",
    toggle = {
      hint = "<M-i><M-h>",
      debug = "<M-i><M-d>",
      default = "<M-i><M-t>",
      suggestion = "<M-i><M-s>",
    },
    sidebar = {
      switch_windows = "<Tab>",
      reverse_switch_windows = "<S-Tab>",
    },
  },
  hints = { enabled = true },
  windows = {
    ---@type "right" | "left" | "top" | "bottom" | "smart"
    position = "smart", -- the position of the sidebar
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
