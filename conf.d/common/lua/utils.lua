local fn = vim.fn
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

function _G.Require(...)
  return fn['Require'](...) > 0
end

function _G.Installed(...)
  return fn['Installed'](...) > 0
end

function _G.InstalledLsp()
  return fn['InstalledLsp']() > 0
end

function _G.InstalledCmp()
  return fn['InstalledCmp']() > 0
end

function _G.InstalledBlink()
  return fn['InstalledBlink']() > 0
end

function _G.InstalledCoc()
  return fn['InstalledCoc']() > 0
end

function _G.WINDOWS()
  return fn['WINDOWS']() > 0
end

function _G.LINUX()
  return fn['LINUX']() > 0
end

function _G.UNIX()
  return fn['UNIX']() > 0
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
