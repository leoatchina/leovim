-- provider
vim.g.ai_provider = ''
vim.g.openai_url = ''
-- base models
vim.g.xai_model = vim.g.xai_model or "grok-beta"
vim.g.openai_model = vim.g.openai_model or "gpt4o"
vim.g.claude_model = vim.g.claude_model or "claude-3.5-sonnet"
vim.g.gemini_model = vim.g.gemini_model or "gemini-1.5-pro"
vim.g.deepseek_model = vim.g.deepseek_model or "deepseek-chat"
if vim.env.OPENAI_API_KEY then
  vim.g.ai_provider = 'openai'
  vim.g.openai_url = "https://api.openai.com/v1"
  ai_model = vim.g.openai_model
elseif vim.env.ANTHROPIC_API_KEY then
  vim.g.ai_provider = Installed('avante.nvim') and 'claude' or 'anthropic'
  ai_model = vim.g.claude_model
elseif vim.env.GEMINI_API_KEY then
  vim.g.ai_provider = 'gemini'
  ai_model = vim.g.gemini_model
elseif vim.env.DEEPSEEK_API_KEY then
  vim.g.ai_provider = 'deepseek'
  ai_model = vim.g.deepseek_model
else
  vim.g.ai_provider = Installed('avante.nvim') and 'openai' or 'openai_compatible'
  vim.env.OPENAI_API_KEY = vim.g.openai_model_api_key
  vim.g.openai_url = vim.g.openai_compatible_url
  ai_model = vim.g.openai_compatible_model
end
-- set ai_complete_engine
vim.g.ai_complete_engine = vim.g.ai_complete_engine and ai_model .. '&&' .. vim.g.ai_complete_engine
  or ai_model
