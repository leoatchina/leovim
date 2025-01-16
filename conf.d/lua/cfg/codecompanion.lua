vim.keymap.set("n", "<M-i><Cr>", [[<Cmd>CodeCompanionCommands<Cr>]], { noremap = true, silent = true })
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
            default = "grok-beta",
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
            default = "claude-3-opus-20240229",
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
      adapter = 'xai',
      linine = 'xai'
    }
  },
})
