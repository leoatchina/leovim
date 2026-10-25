local M = {}
local api = vim.api
local namespace = api.nvim_create_namespace('LeoCodeLens')
local group = api.nvim_create_augroup('LeoCodeLens', { clear = true })
local buffers = {}

local function render(bufnr, entries)
  local rows = {}
  for _, entry in ipairs(entries) do
    local command = entry.lens.command
    if command then
      local row = entry.lens.range.start.line
      rows[row] = rows[row] or { { '  ', 'LspCodeLens' } }
      local chunks = rows[row]
      if #chunks > 1 then
        chunks[#chunks + 1] = { ' | ', 'LspCodeLensSeparator' }
      end
      chunks[#chunks + 1] = { command.title:gsub('[\r\n]+', ' '), 'LspCodeLens' }
    end
  end
  api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  for row, chunks in pairs(rows) do
    api.nvim_buf_set_extmark(bufnr, namespace, row, 0, {
      virt_text = chunks,
      virt_text_pos = 'eol',
      hl_mode = 'combine',
    })
  end
end

function M.refresh(bufnr)
  local state = buffers[bufnr]
  if not state or not state.enabled or not api.nvim_buf_is_loaded(bufnr) then
    return
  end
  state.generation = state.generation + 1
  if #vim.lsp.get_clients({ bufnr = bufnr, method = 'textDocument/codeLens' }) == 0 then
    api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
    return
  end
  local generation = state.generation
  local changedtick = api.nvim_buf_get_changedtick(bufnr)
  local function current()
    return buffers[bufnr] == state and state.enabled and state.generation == generation
      and api.nvim_buf_is_loaded(bufnr) and api.nvim_buf_get_changedtick(bufnr) == changedtick
  end
  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
  vim.lsp.buf_request_all(bufnr, 'textDocument/codeLens', params, function(results)
    if not current() then
      return
    end
    local entries = {}
    for client_id, response in pairs(results) do
      if response.err then
        vim.lsp.log.error('CodeLens', response.err)
      end
      for _, lens in ipairs(response.result or {}) do
        entries[#entries + 1] = { client_id = client_id, lens = lens }
      end
    end
    table.sort(entries, function(a, b)
      if a.client_id ~= b.client_id then
        return a.client_id < b.client_id
      end
      return a.lens.range.start.character < b.lens.range.start.character
    end)
    render(bufnr, entries)
    for _, entry in ipairs(entries) do
      local client = vim.lsp.get_client_by_id(entry.client_id)
      if client and not entry.lens.command then
        client:request('codeLens/resolve', entry.lens, function(err, resolved)
          if current() and not err and resolved then
            entry.lens = resolved
            render(bufnr, entries)
          end
        end, bufnr)
      end
    end
  end)
end

local function queue_refresh(bufnr)
  local state = buffers[bufnr]
  if not state or not state.enabled then
    return
  end
  state.generation = state.generation + 1
  local generation = state.generation
  vim.defer_fn(function()
    if buffers[bufnr] == state and state.generation == generation then
      M.refresh(bufnr)
    end
  end, 150)
end

function M.attach(bufnr)
  -- Disable only the built-in display; codelens.run() still requests/executes lenses.
  vim.lsp.codelens.enable(false, { bufnr = bufnr })
  if not buffers[bufnr] then
    buffers[bufnr] = { enabled = true, generation = 0 }
    api.nvim_create_autocmd({ 'BufEnter', 'TextChanged', 'TextChangedI', 'InsertLeave' }, {
      group = group,
      buffer = bufnr,
      callback = function() queue_refresh(bufnr) end,
    })
    api.nvim_create_autocmd('LspDetach', {
      group = group,
      buffer = bufnr,
      callback = function() vim.schedule(function() M.refresh(bufnr) end) end,
    })
    api.nvim_create_autocmd('BufWipeout', {
      group = group,
      buffer = bufnr,
      callback = function() buffers[bufnr] = nil end,
    })
  end
  M.refresh(bufnr)
end

function M.toggle(bufnr)
  local state = buffers[bufnr]
  if not state then
    return
  end
  state.enabled = not state.enabled
  state.generation = state.generation + 1
  if state.enabled then
    M.refresh(bufnr)
  else
    api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  end
end

-- A server can refresh lenses after changes elsewhere in the workspace.
local refresh_handler = vim.lsp.handlers['workspace/codeLens/refresh']
vim.lsp.handlers['workspace/codeLens/refresh'] = function(err, result, ctx, config)
  local response = refresh_handler(err, result, ctx, config)
  if not err then
    for _, bufnr in ipairs(vim.lsp.get_buffers_by_client_id(ctx.client_id)) do
      M.refresh(bufnr)
    end
  end
  return response
end

return M
