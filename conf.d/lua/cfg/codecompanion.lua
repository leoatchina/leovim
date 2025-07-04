vim.keymap.set("n", "<M-i><M-a>", [[<Cmd>CodeCompanionActions<Cr>]], { noremap = true, silent = true })
vim.keymap.set("n", "<M-i><Cr>", [[<Cmd>CodeCompanionChat<Cr>]], { noremap = true, silent = true })
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
    deepseek = function()
      return require("codecompanion.adapters").extend("deepseek", {
        env = {
          api_key = vim.env.DEEPSEEK_API_KEY
        },
        schema = {
          model = {
            default = vim.g.deepseek_model
          },
        },
      })
    end,
    openai_compatible = function()
      return require("codecompanion.adapters").extend("openai_compatible", {
        env = {
          api_key = vim.g.openai_compatible_api_key,
        },
        url = vim.g.openai_compatible_url,
        schema = {
          model = {
            default = vim.g.openai_compatible_model
          },
        },
      })
    end,
  },
  strategies = {
    inline = {
      adapter = vim.g.ai_provider,
    },
    cmd = {
      adapter = vim.g.ai_provider,
    },
    chat = {
      adapter = vim.g.ai_provider,
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
            n = {"<C-s>", "<Cr>"},
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
  extensions = {
    history = {
      enabled = true,
      opts = {
        -- Keymap to open history from chat buffer (default: gh)
        keymap = "gh",
        -- Keymap to save the current chat manually (when auto_save is disabled)
        save_chat_keymap = "sc",
        -- Save all chats by default (disable to save only manually using 'sc')
        auto_save = true,
        -- Number of days after which chats are automatically deleted (0 to disable)
        expiration_days = 0,
        -- Picker interface (auto resolved to a valid picker)
        picker = "telescope", --- ("telescope", "snacks", "fzf-lua", or "default")
        -- Customize picker keymaps (optional)
        picker_keymaps = {
          rename = { n = "r", i = "<M-r>" },
          delete = { n = "d", i = "<M-d>" },
          duplicate = { n = "<C-y>", i = "<C-y>" },
        },
        ---Automatically generate titles for new chats
        auto_generate_title = true,
        title_generation_opts = {
          ---Adapter for generating titles (defaults to current chat adapter)
          adapter = nil, -- "copilot"
          ---Model for generating titles (defaults to current chat model)
          model = nil, -- "gpt-4o"
          ---Number of user prompts after which to refresh the title (0 to disable)
          refresh_every_n_prompts = 0, -- e.g., 3 to refresh after every 3rd user prompt
          ---Maximum number of times to refresh the title (default: 3)
          max_refreshes = 3,
        },
        ---On exiting and entering neovim, loads the last chat on opening chat
        continue_last_chat = false,
        ---When chat is cleared with `gx` delete the chat from history
        delete_on_clearing_chat = false,
        ---Directory path to save the chats
        dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
        ---Enable detailed logging for history extension
        enable_logging = false,
        ---Optional filter function to control which chats are shown when browsing
        chat_filter = nil, -- function(chat_data) return boolean end
      }
    }
  }
})
