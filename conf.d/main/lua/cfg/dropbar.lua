local nx = { "n", "x" }
local map = vim.keymap.set
map(nx, 'ss', require('dropbar.api').pick, { noremap = true, silent = false, nowait= true })
map(nx, ',s', require('dropbar.api').goto_context_start, { noremap = true, silent = false, nowait= true })
map(nx, ';s', require('dropbar.api').select_next_context, { noremap = true, silent = false, nowait= true })

