-- R.nvim (https://github.com/R-nvim/R.nvim) configuration.
-- Declared in plug/languages.vim when g:packs includes 'r.nvim'.
-- All R-specific setup AND legacy Nvim-R keymaps live here; the existing
-- ftplugin/r.vim keeps only generic R editing abbreviations and stays
-- untouched.
local function legacy_keymaps()
  local bufmap = function(mode, key, target)
    local rhs = string.format("<Cmd>lua %s<Cr>", target)
    vim.api.nvim_buf_set_keymap(0, mode, key, rhs, { silent = true, noremap = true })
  end

  -- Object Browser: M<Space> opens/closes (r.browser.start toggles an open
  -- window), M<Tab> switches between the GlobalEnv and libraries views.
  bufmap("n", "M<Tab>", "require('r.browser').toggle_view()")

  -- Fuzzy-find R.nvim commands, matching the M<Cr> convention from rust.vim.
  vim.api.nvim_buf_create_user_command(0, 'RCommands', function()
    vim.fn.FzfCallCommands('RCommands', 'R')
  end, {})
  bufmap("n", "M<Cr>", "RCommands")
  -- View / print the object under cursor.
  bufmap("n", "J", "require('r.run').action('print')")
  bufmap("n", "-", "require('r.run').action('viewobj')")

  -- Send above lines / everything up to the last line / whole file. \E mimics
  -- the old VG:SendLineToR('down') by jumping to the last line before sending.
  bufmap("n", "\\B", "require('r.send').above_lines()")
  bufmap("n", "\\E", [[vim.fn.cursor(vim.fn.line('$'), 0) require('r.send').line('move')]])
  bufmap("n", "\\A", "require('r.send').source_file()")

  -- Insert the commented output of the current line.
  bufmap("n", "<M-r>i", "require('r.run').insert_commented()")

  -- Send the current function, the current line (stay), and the current line
  -- (move cursor down) with legacy keys on the <M-r> prefix.
  bufmap("n", "<M-r>f", "require('r.send').funs(false, false)")
  bufmap("n", "<M-r>h", "require('r.send').line('stay')")
  bufmap("n", "<M-r>j", "require('r.send').line('move')")

  -- Clear console / clear everything with <M-r> prefix keys.
  bufmap("n", "<M-r>c", "require('r.run').clear_console()")
  bufmap("n", "<M-r>C", "require('r.run').clear_all()")

  -- Start / quit R with legacy keys; \Q saves the workspace on quit.
  bufmap("n", "\\r", "require('r.run').start_R('R')")
  bufmap("n", "\\q", "require('r.run').quit_R('nosave')")
  bufmap("n", "\\Q", "require('r.run').quit_R('save')")
end

require('r').setup({
  -- Match legacy R_objbr_place='RIGHT': full-height column at the far right.
  objbr_place = 'RIGHT',
  objbr_w = 50,
  objbr_opendf = false,
  objbr_openlist = false,
  rconsole_height = 14,
  rconsole_width = 0,
  min_editor_width = 18,
  objbr_mappings = {
    -- Legacy Nvim-R object browser keys, active inside the browser buffer.
    ['M<Space>'] = function()
      require('r.browser').start()
    end,
    ['M<Tab>'] = function()
      require('r.browser').toggle_view()
    end,
  },
  hook = {
    on_filetype = legacy_keymaps,
  },
})
