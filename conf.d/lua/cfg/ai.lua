-- provider
vim.g.ai_provider = ''
vim.g.openai_url = ''
-- base models
vim.g.openai_model = vim.g.openai_model or "o1-mini"
vim.g.claude_model = vim.g.claude_model or "claude-3.5-haiku"
vim.g.gemini_model = vim.g.gemini_model or "gemini-1.5-pro"
vim.g.xai_model = vim.g.xai_model or "grok-beta"
-- setup
if vim.g.openai_custom_model and vim.g.openai_custom_url and vim.g.openai_model_api_key then
  vim.env.OPENAI_API_KEY = vim.g.openai_model_api_key
  vim.g.openai_url = vim.g.openai_custom_url
  vim.g.ai_provider = 'openai'
  ai_model = vim.g.openai_custom_model
elseif vim.env.OPENAI_API_KEY then
  vim.g.openai_url = "https://api.openai.com/v1"
  vim.g.ai_provider = 'openai'
  ai_model = vim.g.openai_model
elseif vim.env.ANTHROPIC_API_KEY then
  vim.g.ai_provider = 'claude'
  ai_model = vim.g.claude_model
elseif vim.env.GEMINI_API_KEY then
  vim.g.ai_provider = 'gemini'
  ai_model = vim.g.gemini_model
elseif vim.env.XAI_API_KEY then
  vim.g.ai_provider = 'xai'
  ai_model = vim.g.xai_model
end
vim.g.ai_complete_engine = vim.g.ai_complete_engine and ai_model .. '&&' .. vim.g.ai_complete_engine
  or ai_model
