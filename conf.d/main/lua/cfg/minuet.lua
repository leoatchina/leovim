local utils = require('utils')

local config
local enabled_ft = {'lua', 'vim', 'python', 'r', 'c', 'cpp', 'rust', 'go', 'java', 'javascript', 'typescript'}

-- provider
vim.g.ai_provider = ''
vim.g.openai_url = ''
--  models
vim.g.xai_model = vim.g.xai_model or "grok-beta"
vim.g.deepseek_model = vim.g.deepseek_model or "deepseek-chat"
vim.g.mistral_model = vim.g.mistral_model or "mistral-large-latest"
vim.g.openai_model = vim.g.openai_model or "gpt4o"
vim.g.gemini_model = vim.g.gemini_model or "gemini-2.0-flash"
vim.g.claude_model = vim.g.claude_model or "claude-3.7-sonnet"
-- key
if vim.env.XAI_API_KEY then
  vim.g.ai_provider = 'xai'
  ai_model = vim.g.xai_model
elseif vim.env.DEEPSEEK_API_KEY then
  vim.g.ai_provider = 'deepseek'
  ai_model = vim.g.deepseek_model
elseif vim.env.MISTRAL_API_KEY then
  vim.g.ai_provider = 'mistral'
  ai_model = vim.g.claude_model
elseif vim.env.HUGGINGFACE_API_KEY then
  vim.g.ai_provider = 'huggingface'
  ai_model = vim.g.claude_model
elseif vim.env.OPENAI_API_KEY then
  vim.g.ai_provider = 'openai'
  vim.g.openai_url = "https://api.openai.com/v1"
  ai_model = vim.g.openai_model
elseif vim.env.GEMINI_API_KEY then
  vim.g.ai_provider = 'gemini'
  ai_model = vim.g.gemini_model
elseif vim.env.ANTHROPIC_API_KEY then
  vim.g.ai_provider = 'anthropic'
  ai_model = vim.g.claude_model
else
  vim.g.ai_provider = 'openai_compatible'
  vim.env.OPENAI_API_KEY = vim.g.openai_model_api_key
  vim.g.openai_url = vim.g.openai_compatible_url
  ai_model = vim.g.openai_compatible_model
end
-- set ai_complete_engine
vim.g.ai_complete_engine = vim.g.ai_complete_engine and ai_model .. '&&' .. vim.g.ai_complete_engine or ai_model

if utils.installed_blink() or utils.installed_cmp() then
  config = {
    provider = vim.g.ai_provider,
  }
elseif utils.installed_lsp() then
  config = {
    provider = vim.g.ai_provider,
    lsp = {
      enabled_ft = enabled_ft,
      enabled_auto_trigger_ft = enabled_ft
    }
  }
  vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(args)
          local client_id = args.data.client_id
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(client_id)
          if not client then
              return
          end

          if client.server_capabilities.completionProvider and client.name ~= 'minuet' then
              vim.lsp.completion.enable(true, client_id, bufnr, { autotrigger = true })
          end
      end,
      desc = 'Enable built-in auto completion',
  })
else
  config = {
    provider = vim.g.ai_provider,
    virtualtext = {
      auto_trigger_ft = {},
      keymap = {
        -- accept whole completion
        accept = '<M-i>',
        -- accept one line
        accept_line = '<M-:>',
        -- accept n lines (prompts for number)
        -- e.g. "M-z 2 CR" will accept 2 lines
        accept_n_lines = '<M-?>',
        -- Cycle to prev completion item, or manually invoke completion
        prev = '<M-,>',
        -- Cycle to next completion item, or manually invoke completion
        next = '<M-;>',
        dismiss = '<M-/>',
      },
    },
  }
end
require('minuet').setup (
  config
)
