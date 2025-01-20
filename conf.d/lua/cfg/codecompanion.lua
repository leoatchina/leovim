vim.keymap.set("n", "<M-i><Cr>", [[<Cmd>CodeCompanionActions<Cr>]], { noremap = true, silent = true })
local adapter = vim.g.ai_provider == 'claude' and 'anthropic' or vim.g.openai_custom and 'openai_compatible' or vim.g.ai_provider
require("codecompanion").setup({
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
          api_key = vim.g.openai_custom_api_key,
          url = vim.g.openai_custom_url,
        },
        schema = {
          model = {
            default = vim.g.openai_custom_model
          },
        },
      })
    end,
  },
  strategies = {
    inline = {
      adapter = adapter,
    },
    cmd = {
      adapter = adapter,
    },
    chat = {
      adapter = adapter,
      slash_commands = {
        ["buffer"] = {
          opts = {
            provider = 'mini_pick'
          }
        },
        ["file"] = {
          opts = {
            provider = 'mini_pick'
          }
        },
        ["help"] = {
          opts = {
            provider = 'mini_pick'
          }
        },
        ["symbols"] = {
          opts = {
            provider = 'mini_pick'
          }
        },
      },
      keymaps = {
        completion = {
          modes = {
            i = "<M-i>",
          },
        },
        send = {
          modes = {
            n = "<C-s>",
            x = "<C-s>",
            i = "<C-s>",
          },
        },
        close = {
          modes = {
            n = "<M-q>",
            x = "<M-q>",
            i = "<M-q>",
          },
        },
        hide = {
          modes = {
            n = "<M-i>",
            x = "<M-i>",
            i = "<M-i>",
          },
          callback = function(chat)
            chat.ui:hide()
          end,
          description = "Hide the chat buffer",
        },
      },
    }
  },
})
