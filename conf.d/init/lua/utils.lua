local fn = vim.fn
local utils = {}

if fn.has("nvim-0.10") == 1 then
  vim.keymap.del({ "n" }, "gcc")
  vim.keymap.del({ "n", "x", "o" }, "gc")
end
if fn.has("nvim-0.11") == 1 then
  vim.keymap.del({ "n" }, "grr")
  vim.keymap.del({ "n" }, "grt")
  vim.keymap.del({ "n" }, "grn")
  vim.keymap.del({ "n" }, "gri")
  vim.keymap.del({ "n", "x"}, "gra")
  vim.deprecate = function() end
end

function _G.inspect(item)
  vim.print(item)
end

function _G.executable(...)
  return fn.executable(...) > 0
end

-- File path functions
function utils.abs_path()
  return fn['utils#abs_path']()
end

function utils.abs_dir()
  return fn['utils#abs_dir']()
end

function utils.file_name()
  return fn['utils#file_name']()
end

function utils.get_root_dir(...)
  return fn['utils#get_root_dir'](...)
end

-- String utility functions
function utils.trim(str)
  return fn['utils#trim'](str)
end

function utils.expand_path(path, ...)
  return fn['utils#expand'](path, ...)
end

-- System detection functions (using utils#)
function utils.is_win()
  return fn['utils#is_win']() > 0
end

function utils.is_linux()
  return fn['utils#is_linux']() > 0
end

function utils.is_unix()
  return fn['utils#is_unix']() > 0
end

function utils.is_macos()
  return fn['utils#is_macos']() > 0
end

function utils.has_gui()
  return fn['utils#has_gui']() > 0
end

function utils.has_tmux()
  return fn['utils#is_unix']() > 0 and vim.fn.exists('$TMUX') > 0
end

-- Package management functions (using utils#)
function utils.get(name)
  return fn['pack#get'](name) > 0
end

function utils.installed(name)
  return fn['pack#installed'](name) > 0
end

function utils.planned(name)
  return fn['pack#planned'](name) > 0
end

function utils.installed_lsp()
  return fn['pack#installed_lsp']() > 0
end

function utils.installed_cmp()
  return fn['pack#installed_cmp']() > 0
end

function utils.installed_blink()
  return fn['pack#installed_blink']() > 0
end

function utils.installed_coc()
  return fn['pack#installed_coc']() > 0
end


vim.ui.select = function(items, opts, on_choice)
  vim.validate({
    items = { items, 'table', false },
    on_choice = { on_choice, 'function', false },
  })
  opts = opts or {}
  local choices = { opts.prompt or 'Select one of:' }
  local format_item = opts.format_item or tostring
  for i, item in ipairs(items) do
    table.insert(choices, string.format('%d: %s', i, format_item(item)))
  end
  local ok, choice = pcall(vim.fn.inputlist, choices)
  if ok then
    if choice < 1 or choice > #items then
      on_choice(nil, nil)
    else
      on_choice(items[choice], choice)
    end
  else
    vim.api.nvim_feedkeys("\n", "n", true)
  end
end

return utils
