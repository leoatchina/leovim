require('yarepl').setup {
  metas = { aider = require('yarepl.extensions.aider').create_aider_meta() }
}
local map = vim.api.nvim_set_keymap
-- general map from yarepl
map('n', '<M-i><Cr>', '<Plug>(REPLStart-aider)', {
  desc = 'Start an aider REPL',
})
map('n', '<M-i>f', '<Plug>(REPLFocus-aider)', {
  desc = 'Focus on aider REPL',
})
map('n', '<M-i>h', '<Plug>(REPLHide-aider)', {
  desc = 'Hide aider REPL',
})
map('v', '<M-i>r', '<Plug>(REPLSendVisual-aider)', {
  desc = 'Send visual region to aider',
})
map('n', '<M-i>r', '<Plug>(REPLSendOperator-aider)', {
  desc = 'Send Operator to aider',
})
map('n', '<M-i><M-i>', '<Plug>(REPLSendLine-aider)', {
  desc = 'Send lines to aider',
})
-- special map from aider
map('n', '<M-i>e', '<Plug>(AiderExec)', {
  desc = 'Execute command in aider',
})
map('n', '<M-i>y', '<Plug>(AiderSendYes)', {
  desc = 'Send y to aider',
})
map('n', '<M-i>n', '<Plug>(AiderSendNo)', {
  desc = 'Send n to aider',
})
map('n', '<M-i>p', '<Plug>(AiderSendPaste)', {
  desc = 'Send /paste to aider',
})
map('n', '<M-i>q', '<Plug>(AiderSendAbort)', {
  desc = 'Send abort to aider',
})
map('n', '<M-i>Q', '<Plug>(AiderSendExit)', {
  desc = 'Send exit to aider',
})
map('n', '<M-i>i', '<cmd>AiderSetPrefix<cr>', {
  desc = 'set aider prefix',
})
map('n', '<M-i>I', '<cmd>AiderRemovePrefix<cr>', {
  desc = 'remove aider prefix',
})
map('n', '<M-i>a', '<Plug>(AiderSendAskMode)', {
  desc = 'Switch aider to ask mode',
})
map('n', '<M-i>A', '<Plug>(AiderSendArchMode)', {
  desc = 'Switch aider to architect mode',
})
map('n', '<M-i>c', '<Plug>(AiderSendCodeMode)', {
  desc = 'Switch aider to code mode',
})
map('n', '<M-i>C', '<cmd>checktime<cr>', {
  desc = 'sync file changes by aider to nvim buffer',
})
