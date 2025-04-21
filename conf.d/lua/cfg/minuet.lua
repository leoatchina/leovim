local config = {}
if InstalledLsp() then
  if not InstalledBlink() and not InstalledCmp then
    local enabled_ft = {'lua', 'vim', 'python', 'r', 'c', 'cpp', 'rust', 'go', 'java', 'javascript', 'typescript'}
    config = {
      lsp = {
        enabled_ft = enabled_ft ,
        -- Enables automatic completion triggering using `vim.lsp.completion.enable`
        enabled_auto_trigger_ft = enabled_ft
      }
    }
  end
else
  config = {
    virtualtext = {
      auto_trigger_ft = {},
      keymap = {
        -- accept whole completion
        accept = '<M-i>',
        -- accept one line
        accept_line = '<M-:>',
        -- accept n lines (prompts for number)
        -- e.g. "M-z 2 CR" will accept 2 lines
        accept_n_lines = '<M-}>',
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
