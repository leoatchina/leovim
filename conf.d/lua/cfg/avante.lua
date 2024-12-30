require('avante_lib').load()
-- keymaps
vim.keymap.set("n", "<M-i>a", [[<Cmd>AvanteCommands<Cr>]], { noremap = true, silent = true })
vim.keymap.set("n", "<M-i><M-c>", [[<Cmd>AvanteClear<Cr>]], { noremap = true, silent = true })
-- tokens
local max_tokens = type(vim.g.max_tokens) == 'number'
  and vim.g.max_tokens > 0
  and vim.g.max_tokens < 1024 * 8
  and vim.g.max_tokens
  or 1024 * 8
-- base models
vim.g.claude_model = vim.g.claude_model or "claude-3.5-haiku"
vim.g.gemini_model = vim.g.gemini_model or "gemini-1.5-flash"
vim.g.openai_model = vim.g.openai_model or "gpt-4o"
-- provider
local provider = ''
local openai_endpoint = ''
if vim.env.DASHSCOPE_API_KEY then
  vim.env.OPENAI_API_KEY = vim.env.DASHSCOPE_API_KEY
  vim.g.avante_model = vim.g.qwen_model or "qwen-coder-plus-latest"
  provider = 'openai'
  openai_endpoint = "https://dashscope.aliyuncs.com/compatible-mode/v1"
elseif vim.env.HYPERBOLIC_API_KEY then
  vim.env.OPENAI_API_KEY = vim.env.HYPERBOLIC_API_KEY
  vim.g.avante_model = vim.g.hyperbolic_model or "Qwen/Qwen2.5-72B-Instruct"
  provider = 'openai'
  openai_endpoint = "https://api.hyperbolic.xyz/v1"
elseif vim.env.DEEPSEEK_API_KEY then
  vim.env.OPENAI_API_KEY = vim.env.DEEPSEEK_API_KEY
  vim.g.avante_model = vim.g.deepseek_model or "deepseek-chat"
  provider = 'openai'
  openai_endpoint = "https://api.deepseek.com/v1"
elseif vim.env.OPENROUTER_API_KEY then
  vim.env.OPENAI_API_KEY = vim.env.OPENROUTER_API_KEY
  vim.g.avante_model = vim.g.openrouter_model or "openai/gpt-4o"
  provider = 'openai'
  openai_endpoint = "https://openrouter.ai/api/v1"
elseif vim.env.OPENAI_API_KEY then
  vim.g.avante_model = vim.g.openai_model
  provider = 'openai'
  openai_endpoint = "https://api.openai.com/v1"
elseif vim.env.ANTHROPIC_API_KEY then
  vim.g.avante_model = vim.g.claude_model
  provider = 'claude'
elseif vim.env.GEMINI_API_KEY then
  vim.g.avante_model = vim.g.gemini_model
  provider = 'gemini'
else
  vim.g.avante_model = vim.g.copilot_model
  provider = 'copilot'
end
vim.g.ai_complete_engine = vim.g.avante_model == 'copilot' and 'copilot'
  or vim.g.ai_complete_engine and vim.g.avante_model .. '&&' .. vim.g.ai_complete_engine
  or vim.g.avante_model
require('avante').setup({
  provider = provider,
  auto_suggestions_provider = provider,
  -- openai is specifically configured
  openai = {
    -- NOTE: using avante_model here
    model = vim.g.avante_model,
    endpoint = openai_endpoint,
    max_tokens = max_tokens
  },
  -- other models
  claude = {
    model = vim.g.claude_model,
    max_tokens = max_tokens
  },
  gemini = {
    model = vim.g.gemini_model,
    max_tokens = max_tokens
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
