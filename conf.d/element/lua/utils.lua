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

function _G.CheckHandler(handler)
  local ok, res = pcall(function() return vim.lsp.buf_request_sync(0, handler, vim.lsp.util.make_position_params()) end)
  if ok then
    if res and type(res) == 'table' and next(res) then
      return 1
    else
      return 0
    end
  else
    return 0
  end
end

if vim.fn.has('nvim-0.10') > 0 then
  vim.lsp.inlay_hint.enable()
end
