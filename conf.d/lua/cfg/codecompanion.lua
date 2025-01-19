vim.keymap.set("n", "<M-i><Cr>", [[<Cmd>CodeCompanionActions<Cr>]], { noremap = true, silent = true })
require("codecompanion").setup({
  display = {
    diff = {
      provider = "mini_diff",
    },
  },
  opts = {
    log_level = "DEBUG",
    language = vim.g.codecompanion_language or 'Chinese'
  },
  adapters = {
    xai = function()
      return require("codecompanion.adapters").extend("xai", {
        env = {
          api_key = vim.env.XAI_API_KEY
        },
        schema = {
          model = {
            default = vim.g.xai_model,
          },
        },
      })
    end,
    anthropic = function()
      return require("codecompanion.adapters").extend("anthropic", {
        env = {
          api_key = vim.env.ANTHROPIC_API_KEY
        },
        schema = {
          model = {
            default = vim.g.claude_model
          },
        },
      })
    end,
    gemini = function()
      return require("codecompanion.adapters").extend("gemini", {
        env = {
          api_key = vim.env.GEMINI_API_KEY
        },
        schema = {
          model = {
            default = vim.g.gemini_model_model
          },
        },
      })
    end,
    openai = function()
      return require("codecompanion.adapters").extend("openai", {
        env = {
          api_key = vim.env.OPENAI_API_KEY
        },
        schema = {
          model = {
            default = vim.g.openai_model
          },
        },
      })
    end,
    openai_compatible = function()
      return require("codecompanion.adapters").extend("openai_compatible", {
        env = {
          api_key = vim.g.openai_custom.api_key,
          url = vim.g.openai_custom.url,
        },
        schema = {
          model = {
            default = vim.g.openai_custom.model
          },
        },
      })
    end,
  },
  strategies = {
    chat = {
      keymaps = {
        send = {
          modes = {
            n = "<C-s>",
            x = "<C-s>",
            i = "<C-s>",
          },
        },
        hide = {
          modes = {
            n = "<M-q>",
            x = "<M-q>",
            i = "<M-q>",
          },
          callback = function(chat)
            chat.ui:hide()
          end,
          description = "Hide the chat buffer",
        },
      },
      adapter = vim.g.ai_provider == 'claude' and 'anthropic' or vim.g.openai_custom and 'openai_compatible' or vim.g.ai_provider,
      linine = vim.g.ai_provider == 'claude' and 'anthropic' or vim.g.openai_model and 'openai_compatible' or vim.g.ai_provider
    }
  },
})
