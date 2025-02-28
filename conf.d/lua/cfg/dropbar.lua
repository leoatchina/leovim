  vim.keymap.set('n', '<Tab>s', require('dropbar.api').pick, { desc = 'Pick symbols in winbar' })
  vim.keymap.set('n', ',s', require('dropbar.api').goto_context_start, { desc = 'Go to start of current context' })
  vim.keymap.set('n', ';s', require('dropbar.api').select_next_context, { desc = 'Select next context' })
