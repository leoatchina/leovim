require"hop".setup({ keys = vim.g.search_keys })
local map = vim.keymap.set
local opt = { remap=true }
map({'n', 'x', 'o'}, 'sL', [[<Cmd>HopLineStart<Cr>]], opt)
map({'n', 'x', 'o'}, 'sl', [[<Cmd>HopAnywhereCurrentLine<Cr>]], opt)
map({'n', 'x', 'o'}, 's;', [[<Cmd>HopWordAC<Cr>]], opt)
map({'n', 'x', 'o'}, 's,', [[<Cmd>HopWordBC<Cr>]], opt)
map({'n', 'x', 'o'}, 'sf', [[<Cmd>HopChar1AC<Cr>]], opt)
map({'n', 'x', 'o'}, 'sF', [[<Cmd>HopChar1BC<Cr>]], opt)
map({'n', 'x', 'o'}, 'st', [[<Cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, hint_offset = -1 })]], opt)
map({'n', 'x', 'o'}, 'sT', [[<Cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, hint_offset = 1 })]], opt)
