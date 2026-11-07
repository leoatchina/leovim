local M = {}

-- Vimscript's Ex-oriented path helpers escape spaces; Lua finders need raw paths.
function M.root(kind)
  local file = vim.api.nvim_buf_get_name(0)
  local dir = file ~= '' and vim.fs.dirname(file) or vim.fn.getcwd()
  local markers
  if kind == 'git' then
    markers = { '.git' }
  elseif kind == 'vcs' then
    markers = { '.git', '.svn', '.hg', '.cvs', '.bzr' }
  else
    markers = vim.g.root_patterns
  end
  local found = vim.fs.find(markers, { path = dir, upward = true })[1]
  return found and vim.fs.dirname(found) or dir
end


local snacks = require('snacks')

local function jump(picker, item, action)
  picker:norm(function()
    -- :sbuffer must not reuse the picker's real-buffer preview window.
    local switchbuf = vim.o.switchbuf
    vim.o.switchbuf = ''
    local ok, err = pcall(require('snacks.picker.actions').jump, picker, item, action)
    vim.o.switchbuf = switchbuf
    if not ok then
      error(err)
    end
  end)
end

snacks.setup({
  bigfile = { enabled = true },
  words = { enabled = true },
  input = { enabled = true },
  explorer = { enabled = true },
  indent = { enabled = false },
  notifier = { enabled = true, timeout = 3000 },
  image = {
    enabled = true,
    doc = {
      enabled = true,
      inline = true,
      float = true,
      max_width = 80,
      max_height = 40,
    },
    math = { enabled = false },
  },
  picker = {
    enabled = true,
    ui_select = true,
    sources = {
      explorer = {
        jump = { close = true },
        layout = { preset = "default", preview = false },
      },
    },
    actions = { confirm = jump, jump = jump, edit = jump },
    win = {
      input = {
        keys = {
          ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
          ['<C-]>'] = { 'edit_vsplit', mode = { 'i', 'n' } },
        },
      },
      list = {
        keys = {
          ['<C-]>'] = 'edit_vsplit',
        },
      },
    },
  },
})

snacks.toggle.indent():map("<leader>I")

vim.keymap.set('n', '<M-k>n', function()
  snacks.picker.notifications()
end, { silent = true, desc = 'Search notification history' })

vim.keymap.set('n', 'ZF', function()
  snacks.zen()
end, { silent = true, desc = 'Toggle Zen' })

vim.keymap.set('n', 'ZO', function()
  snacks.zen.zoom()
end, { silent = true, desc = 'Toggle Zoom' })

-- Available even when FZF or LeaderF owns the common finder mappings.
vim.api.nvim_create_user_command('SnacksPicker', function()
  snacks.picker()
end, { desc = 'Choose a Snacks picker' })

vim.keymap.set('n', '<leader>fo', function()
  snacks.explorer()
end, { silent = true, nowait = true, desc = 'Open file explorer' })

vim.keymap.set('n', '<leader>fe', function()
  snacks.scratch()
end, { silent = true, nowait = true, desc = 'Toggle scratch buffer' })

vim.keymap.set('n', '<leader>fs', function()
  snacks.scratch.select()
end, { silent = true, nowait = true, desc = 'Select scratch buffer' })

return M
