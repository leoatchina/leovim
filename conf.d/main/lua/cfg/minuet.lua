local utils = require('utils')

local config
local enabled_ft = {'lua', 'vim', 'python', 'r', 'c', 'cpp', 'rust', 'go', 'java', 'javascript', 'typescript'}
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
