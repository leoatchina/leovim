---@diagnostic disable: unbalanced-assignments
local fn = vim.fn

function _G.inspect(item)
  vim.print(item)
end

function _G.executable(name)
  if fn.executable(name) > 0 then
    return true
  end
  return false
end

function _G.exists(name)
   return fn.exists(name) > 0
end

function _G.Installed(name)
  if fn['Installed'](name) > 0 then
    return true
  end
  return false
end

function _G.WINDOWS()
  if fn['WINDOWS']() > 0 then
    return true
  end
  return false
end

function _G.LINUX()
  if fn['LINUX']() > 0 then
    return true
  end
  return false
end

function _G.UNIX()
  if fn['UNIX']() > 0 then
    return true
  end
  return false
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

