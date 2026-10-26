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
    markers = vim.list_extend(vim.deepcopy(vim.g.root_patterns), vim.g.root_files)
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
  input = { enabled = true },
  explorer = { enabled = true },
  indent = { enabled = false },
  notifier = { enabled = true, timeout = 3000 },
  picker = {
    enabled = true,
    ui_select = true,
    sources = {
      explorer = {
        layout = { preset = "default", preview = false },
      },
    },
    actions = { confirm = jump, jump = jump, edit = jump },
    win = {
      input = {
        keys = {
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

vim.api.nvim_create_user_command('SnacksNote', function()
  vim.ui.input({ prompt = '笔记名称：' }, function(name)
    if not name or vim.trim(name) == '' then
      return
    end
    snacks.scratch({
      name = vim.trim(name),
      ft = 'markdown',
      filekey = { cwd = false, branch = false, count = false },
    })
  end)
end, { desc = 'Open a named notebook' })

vim.api.nvim_create_user_command('SnacksBufferLines', function()
  local sources = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buflisted and vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == '' then
      sources[#sources + 1] = { source = 'lines', buf = buf }
    end
  end
  snacks.picker.pick({ title = 'Buffer Lines', multi = sources })
end, { desc = 'Search loaded buffers, including unsaved changes' })

vim.api.nvim_create_user_command('SnacksTagsWorkspace', function()
  snacks.picker.tags({ title = 'Tags (workspace)' })
end, { desc = 'Snacks: search workspace ctags' })

vim.api.nvim_create_user_command('SnacksTagsBuf', function()
  if vim.api.nvim_buf_get_name(0) == '' then
    vim.notify('SnacksTagsBuf: buffer has no file name', vim.log.levels.WARN)
    return
  end
  snacks.picker.tags({
    title = 'Tags (buffer)',
    filter = { buf = vim.api.nvim_get_current_buf() },
    finder = function(opts, ctx)
      return ctx.filter(require('snacks.picker.source.vim').tags(opts, ctx))
    end,
  })
end, { desc = 'Snacks: search current-buffer ctags' })

return M
