-- provider
vim.g.ai_provider = ''
vim.g.openai_url = ''
-- base models
vim.g.xai_model = vim.g.xai_model or "grok-beta"
vim.g.claude_model = vim.g.claude_model or "claude-3.5-haiku"
vim.g.gemini_model = vim.g.gemini_model or "gemini-1.5-pro"
vim.g.openai_model = vim.g.openai_model or "o1-mini"
-- setup
if vim.g.openai_custom_model and vim.g.openai_custom_url and vim.g.openai_model_api_key then
  vim.env.OPENAI_API_KEY = vim.g.openai_model_api_key
  vim.g.llm_model = vim.g.openai_custom_model
  vim.g.openai_url = vim.g.openai_custom_url
  vim.g.ai_provider = 'openai'
elseif vim.env.OPENAI_API_KEY then
  vim.g.llm_model = vim.g.openai_model
  vim.g.openai_url = "https://api.openai.com/v1"
  vim.g.ai_provider = 'openai'
elseif vim.env.XAI_API_KEY then
  vim.g.llm_model = vim.g.xai_model
  vim.g.ai_provider = 'xai'
elseif vim.env.ANTHROPIC_API_KEY then
  vim.g.llm_model = vim.g.claude_model
  vim.g.ai_provider = 'claude'
elseif vim.env.GEMINI_API_KEY then
  vim.g.llm_model = vim.g.gemini_model
  vim.g.ai_provider = 'gemini'
end
