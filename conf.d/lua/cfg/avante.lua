require('avante_lib').load()
-- keymaps
vim.keymap.set("n", "<M-i><Cr>", [[<Cmd>AvanteCommands<Cr>]], { noremap = true, silent = true })
vim.keymap.set("n", "<M-i><M-c>", [[<Cmd>AvanteClear<Cr>]], { noremap = true, silent = true })
require('avante').setup({
  provider = vim.g.ai_provider,
  auto_suggestions_provider = vim.g.ai_provider,
  -- openai is specifically configured
  openai = {
    -- NOTE: using llm_model here
    model = vim.g.llm_model or vim.g.openai_model,
    endpoint = vim.g.openai_url,
    max_tokens = vim.g.max_tokens
  },
  -- other models
  claude = {
    model = vim.g.claude_model,
    max_tokens = vim.g.max_tokens
  },
  gemini = {
    model = vim.g.gemini_model,
    max_tokens = vim.g.max_tokens
  },
  -- behaviour
  behaviour = {
    auto_suggestions = not Installed('codeium.vim') and not Installed('copilot.vim'),
    auto_set_highlight_group = true,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = false,
    support_paste_from_clipboard = true,
  },
  -- basic config
  mappings = {
    diff = {
      ours = "co",
      theirs = "ct",
      all_theirs = "ca",
      both = "cb",
      cursor = "cc",
      next = "c;",
      prev = "c,",
    },
    jump = {
      next = "]]",
      prev = "[[",
    },
    submit = {
      normal = "<CR>",
      insert = "<C-s>",
    },
    ask = "<M-a>",
    edit = "<M-i>",
    focus = "<M-i><M-f>",
    refresh = "<M-i><M-r>",
    toggle = {
      hint = "<M-i><M-h>",
      debug = "<M-i><M-d>",
      default = "<M-i><M-i>",
      repo_map = "<M-i><M-m>",
      suggestion = "<M-i><M-s>",
    },
    sidebar = {
      switch_windows = "<S-Tab>",
      reverse_switch_windows = "<Nop>",
    },
    suggestion = {
      accept = "<M-i>",
      next = "<M-;>",
      prev = "<M-,>",
      dismiss = "<M-/>",
    },
  },
  windows = {
    position = "smart", -- the position of the sidebar
    wrap = true, -- similar to vim.o.wrap
    width = 30, -- default % based on available width in vertical layout
    height = 30, -- default % based on available height in horizontal layout
    sidebar_header = {
      enabled = false
    },
    input = {
      prefix = "> ",
    },
    edit = {
      border = "rounded",
      start_insert = true, -- Start insert mode when opening the edit window
    },
    ask = {
      border = "rounded",
      floating = true, -- Open the 'AvanteAsk' prompt in a floating window
      start_insert = true, -- Start insert mode when opening the ask window
    },
    highlights = {
      diff = {
        current = "DiffText",
        incoming = "DiffAdd",
      },
    },
    diff = {
      autojump = true,
      ---@type string | fun(): any
      list_opener = "copen",
    },
  }
})
