local M = {}
local n = { "n" }
local x = { "x" }
local nx = { "n", "x" }
local map = vim.keymap.set
local utils = require('utils')
local autocmd = vim.api.nvim_create_autocmd
local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
lsp_capabilities.textDocument.foldingRange = {
    dynamicRegistration = true,
    lineFoldingOnly = true
}
lsp_capabilities.textDocument.semanticTokens.multilineTokenSupport = true
lsp_capabilities.textDocument.completion.completionItem.snippetSupport = true
--------------------------------------------
-- diagnostic
--------------------------------------------
vim.diagnostic.enable(false)
local config = {
  update_in_insert = false,
  virtual_text = false,
  underline = true,
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.HINT] = "",
      [vim.diagnostic.severity.INFO] = "",
    },
  },
  float = {
    focusable = false,
    style = "minimal",
    border = "single",
    source = "always",
    header = "",
    prefix = "",
    suffix = "",
  },
}
vim.diagnostic.config(config)
function _G.toggle_diagnostics()
  if vim.g.diagnostics_enable then
    print("diagnostics off")
    vim.g.diagnostics_enable = false
    vim.diagnostic.enable(false)
  else
    print("diagnostics on")
    vim.g.diagnostics_enable = true
    vim.diagnostic.enable()
  end
end
-- toggle diagnostic virtual text && underline
function _G.toggle_virtual_text()
  if vim.g.diagnostic_virtual_text then
    print("virtual_text off")
    vim.g.diagnostic_virtual_text = false
  else
    print("virtual_text on")
    vim.g.diagnostic_virtual_text = true
  end
  vim.diagnostic.config({
    virtual_text = vim.g.diagnostic_virtual_text
  })
end
if utils.installed_cmp() then
  lsp_capabilities = vim.tbl_deep_extend('force', lsp_capabilities, require('cmp_nvim_lsp').default_capabilities())
end
vim.lsp.config("*", {
  capabilities = lsp_capabilities,
})
-----------------------
-- symbol icons
-----------------------
local icons = {
  Class = " ",
  Color = " ",
  Constant = " ",
  Constructor = " ",
  Enum = " ",
  EnumMember = " ",
  Event = " ",
  Field = " ",
  File = " ",
  Folder = " ",
  Function = "󰊕 ",
  Interface = " ",
  Keyword = " ",
  Method = "ƒ ",
  Module = "󰏗 ",
  Property = " ",
  Snippet = " ",
  Struct = " ",
  Text = " ",
  Unit = " ",
  Value = " ",
  Variable = " ",
}
local completion_kinds = vim.lsp.protocol.CompletionItemKind
for i, kind in ipairs(completion_kinds) do
  completion_kinds[i] = icons[kind] and icons[kind] .. kind or kind
end
-----------------------
-- CodeLens (end of line)
-----------------------
local codelens = {}
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

function codelens.refresh(bufnr)
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
      codelens.refresh(bufnr)
    end
  end, 150)
end

function codelens.attach(bufnr)
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
      callback = function() vim.schedule(function() codelens.refresh(bufnr) end) end,
    })
    api.nvim_create_autocmd('BufWipeout', {
      group = group,
      buffer = bufnr,
      callback = function() buffers[bufnr] = nil end,
    })
  end
  codelens.refresh(bufnr)
end

function codelens.toggle(bufnr)
  local state = buffers[bufnr]
  if not state then
    return
  end
  state.enabled = not state.enabled
  state.generation = state.generation + 1
  if state.enabled then
    codelens.refresh(bufnr)
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
      codelens.refresh(bufnr)
    end
  end
  return response
end
-------------------------
-- mason lspconfig
-------------------------
local lsp_exclude = { 'rust_analyzer', 'jdtls' }
if vim.g.ensure_installed then
  if vim.fn.index(vim.g.ensure_installed, 'pyright') >= 0 then
    table.insert(lsp_exclude, 'basedpyright')
  elseif vim.fn.index(vim.g.ensure_installed, 'basedpyright') >= 0 then
    table.insert(lsp_exclude, 'pyright')
  end
end
require("mason-lspconfig").setup({
  ensure_installed = vim.g.ensure_installed and vim.tbl_filter(function(server)
    return server ~= "debugpy"
  end, vim.g.ensure_installed) or {},
  automatic_enable = {
    exclude = lsp_exclude,
  }
})
---------------------
-- LspAction
---------------------
local function get_lsp_loc(value)
  -- filename
  local filename = value.uri or value.targetUri
  if filename == nil then
    return nil
  end
  -- range
  local range = value.range or value.targetRange
  if range == nil then
    return nil
  end
  -- jumpto position
  local lnum = range.start.line + 1
  local col = range.start.character + 1
  -- return
  return {
    filename = filename,
    lnum = lnum,
    col = col
  }
end
-- main action
function M.LspAction(method, open_position)
  local handler_dict = {
    definition = 'textDocument/definition',
    declaration = 'textDocument/declaration',
    implementation = 'textDocument/implementation',
    type_definition = 'textDocument/typeDefinition',
    references = 'textDocument/references',
  }
  local handler = handler_dict[method]
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local params
  if #clients > 0 then
    params = vim.tbl_extend('force', vim.lsp.util.make_position_params(0, clients[1].offset_encoding), method == 'references' and { context = { includeDeclaration = false } } or {})
  else
    params = vim.tbl_extend('force', vim.lsp.util.make_position_params(), method == 'references' and { context = { includeDeclaration = false } } or {})
  end
  local all_results = vim.lsp.buf_request_sync(0, handler, params, 500)
  if type(all_results) ~= 'table' then
    vim.api.nvim_set_var("lsp_found", 0)
    return
  end
  -- collect results from all clients
  local result = {}
  for _, client_result in pairs(all_results) do
    if client_result and client_result['result'] then
      for _, item in ipairs(client_result['result']) do
        table.insert(result, item)
      end
    end
  end
  if #result == 0 then
    vim.api.nvim_set_var("lsp_found", 0)
    return
  end
  local qflist = {}
  local add_qf = #result > 1 or open_position == 'quickfix'
  for _, value in pairs(result) do
    if value == nil then
      goto continue
    end
    local loc = get_lsp_loc(value)
    if loc == nil then
      goto continue
    else
      if loc.filename:match("^file:") then
        loc.filename = loc.filename:gsub("^file:[/]*", "")
        if vim.fn.has('win32') == 1 then
          loc.filename = loc.filename:gsub("%%3A", ":")
        else
          loc.filename = '/' .. loc.filename
        end
      end
      if add_qf then
        local text = vim.fn.readfile(loc.filename)[loc.lnum]
        table.insert(qflist , {
          filename = loc.filename,
          lnum = loc.lnum,
          col = loc.col,
          text = text
        })
      else
        vim.api.nvim_set_var("lsp_found", 1)
        vim.api.nvim_command(open_position .. ' ' .. loc.filename)
        vim.api.nvim_win_set_cursor(0, {loc.lnum, loc.col})
        return
      end
    end
    ::continue::
  end
  if next(qflist) then
    vim.api.nvim_set_var("lsp_found", 1)
    vim.fn.setqflist(qflist)
  else
    vim.api.nvim_set_var("lsp_found", 0)
  end
end
---------------------------
-- 符号局部使用跳转 (供 tags.vim 单向调用，纯同步服务，无反向依赖)
---------------------------
local function compare_pos(a, b)
  if a.line ~= b.line then
    return a.line < b.line and -1 or 1
  end
  if a.character ~= b.character then
    return a.character < b.character and -1 or 1
  end
  return 0
end

function M.UsageNav(direction)
  local bufnr = vim.api.nvim_get_current_buf()
  local has_hl, has_sym = false, false
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    local cap = client.server_capabilities or {}
    if cap.documentHighlightProvider then has_hl = true end
    if cap.documentSymbolProvider then has_sym = true end
  end
  if not (has_hl and has_sym) then
    vim.api.nvim_set_var('lsp_usage_found', 0)
    return false
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local pos = { line = cursor[1] - 1, character = cursor[2] }
  local text_document = vim.lsp.util.make_text_document_params(bufnr)

  -- 1. 获取最内层的作用域范围（包含当前光标且行数跨度最小的符号）
  local sym_res = vim.lsp.buf_request_sync(bufnr, 'textDocument/documentSymbol', { textDocument = text_document }, 1000)
  local scope, min_lines = nil, -1
  local function check_range(range)
    if compare_pos(range.start, pos) <= 0 and compare_pos(pos, range['end']) <= 0 then
      local lines = range['end'].line - range.start.line
      if min_lines < 0 or lines < min_lines then
        min_lines = lines
        scope = range
      end
    end
  end
  local function walk(symbols)
    for _, sym in ipairs(symbols) do
      if sym.range then
        check_range(sym.range)
        if sym.children then walk(sym.children) end
      elseif sym.location and sym.location.range then
        check_range(sym.location.range)
      end
    end
  end
  for _, res in pairs(sym_res or {}) do
    if res.result and not vim.tbl_isempty(res.result) then walk(res.result) end
  end
  if not scope then
    vim.api.nvim_set_var('lsp_usage_found', 0)
    return false
  end

  -- 2. 获取作用域内的所有高亮引用
  local hl_res = vim.lsp.buf_request_sync(bufnr, 'textDocument/documentHighlight', { textDocument = text_document, position = pos }, 1000)
  local occurrences = {}
  for _, res in pairs(hl_res or {}) do
    for _, h in ipairs(res.result or {}) do
      local r = h.range
      if r and compare_pos(scope.start, r.start) <= 0 and compare_pos(r['end'], scope['end']) <= 0 then
        table.insert(occurrences, r)
      end
    end
  end
  if #occurrences == 0 then
    vim.api.nvim_set_var('lsp_usage_found', 0)
    return false
  end

  -- 3. 排序与去重
  table.sort(occurrences, function(a, b) return compare_pos(a.start, b.start) < 0 end)
  local uniq = {}
  for _, r in ipairs(occurrences) do
    if #uniq == 0 or compare_pos(uniq[#uniq].start, r.start) ~= 0 then
      table.insert(uniq, r)
    end
  end

  -- 4. 根据方向跳转
  local dest = nil
  if direction == 'first' then
    dest = uniq[1]
  elseif direction == 'prev' then
    for i = #uniq, 1, -1 do
      if compare_pos(uniq[i]['end'], pos) < 0 then
        dest = uniq[i]
        break
      end
    end
    dest = dest or uniq[#uniq]
  else
    for _, r in ipairs(uniq) do
      if compare_pos(r.start, pos) > 0 then
        dest = r
        break
      end
    end
    dest = dest or uniq[1]
  end

  vim.api.nvim_win_set_cursor(0, { dest.start.line + 1, dest.start.character })
  vim.api.nvim_set_var('lsp_usage_found', 1)
  return true
end
-----------------
-- lsp functions
-----------------
-- Attach
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(args)
    local bufnr = tonumber(args.buf or args.bufnr)
    local client_id = args.data and args.data.client_id or nil
    local client = client_id and vim.lsp.get_client_by_id(client_id) or nil
    if not bufnr or not client then
      return
    end
    local opts_echo = { noremap = true, silent = false, nowait= true, buffer = bufnr }
    local opts_silent = { noremap = true, silent = true, nowait = true, buffer = bufnr }
    if client.server_capabilities.completionProvider then
      vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", {scope = 'local', buf = bufnr})
    end
    if client.server_capabilities.definitionProvider then
      vim.api.nvim_set_option_value("tagfunc", "v:lua.vim.lsp.tagfunc", {scope = 'local', buf = bufnr})
    end
    -- signature_help
    map("i", "<C-x><C-x>", function() vim.lsp.buf.signature_help { border = 'single' } end, opts_silent)
    -- lsp info/restart
    map(nx, "<M-l>i", [[<Cmd>LspInfo<Cr>]], opts_silent)
    map(nx, "<M-l>r", [[<Cmd>lsp restart<Cr>]], opts_silent)
    -- aerial
    map(nx, "F<Cr>", [[<Cmd>AerialNavToggle<Cr>]], opts_silent)
    -- call-graph
    map(nx, "gr", [[<Cmd>CallGraphR<Cr>]], opts_silent)
    map(nx, "gh", [[<Cmd>CallGraphI<Cr>]], opts_silent)
    map(nx, "gl", vim.lsp.buf.outgoing_calls, opts_silent)
    -- diagnostic error
    map(nx, ';d', function() vim.diagnostic.jump({ count = 1, wrap = true }) end, opts_silent)
    map(nx, ',d', function() vim.diagnostic.jump({ count = -1, wrap = true }) end, opts_silent)
    map(nx, ';e', function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, wrap = false }) end, opts_silent)
    map(nx, ',e', function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, wrap = false }) end, opts_silent)
    -- native lsp
    map(nx, "<C-q>", function() require('conform').format({ lsp_format = 'fallback' }) end, opts_echo)
    map(nx, "K", function() vim.lsp.buf.hover { border = "rounded" } end, opts_silent)
    -- get workspace_symbol
    map(n, "<leader>S", function() Snacks.picker.lsp_workspace_symbols({ search = vim.fn.expand('<cword>') }) end, opts_silent)
    map(x, "<leader>S", ":<C-u>lua Snacks.picker.lsp_workspace_symbols({ search = vim.fn['utils#get_visual']() })<Cr>", opts_silent)
    map(nx, "cdL", [[<Cmd>lua vim.print(vim.lsp.buf.list_workspace_folders())<Cr>]], opts_silent)
    -- diagnostic
    map(nx, "<leader>o", toggle_diagnostics, opts_silent)
    map(nx, "<leader>O", toggle_virtual_text, opts_silent)
    map(nx, "<leader>d", function() Snacks.picker.diagnostics_buffer() end, opts_silent)
    map(nx, "<leader>D", function() Snacks.picker.diagnostics() end, opts_silent)
    map(nx, "<leader>e", function() Snacks.picker.diagnostics({ severity = vim.diagnostic.severity.ERROR }) end, opts_silent)
    -- inlay_hint
    if client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
    end
    map(nx, "<leader>i", [[<Cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<Cr>]], opts_echo)
    -- codelens
    if #vim.lsp.get_clients({ bufnr = bufnr, method = 'textDocument/codeLens' }) > 0 then
      vim.api.nvim_set_hl(0, 'LspCodeLens', { fg = '#888888', bg = '#432345', italic = false })
      codelens.attach(bufnr)
      map(nx, "<M-c>", function() codelens.toggle(bufnr) end, opts_echo)
      map(nx, "<leader>C", vim.lsp.codelens.run, opts_echo)
    else
      map(nx, "<M-c>", [[<Cmd>echo "No codelens for current buffer."<Cr>]], opts_echo)
      map(nx, "<leader>C", [[<Cmd>echo "No codelens for current buffer."<Cr>]], opts_echo)
    end
    -- code action
    map(n, "<F2>", vim.lsp.buf.rename, opts_echo)
    map(n, "<M-C>", vim.lsp.buf.code_action, opts_echo)
    ---------------------------
    -- semantic token highlight
    ---------------------------
    ok, _ = pcall(function()
      vim.treesitter.get_parser(bufnr)
    end, bufnr)
    if not ok then
      if client.server_capabilities.semanticTokensProvider then
        autocmd("TextChanged", {
          group = vim.api.nvim_create_augroup("SemanticTokens", {}),
          buffer = bufnr,
          callback = function()
            vim.lsp.semantic_tokens.force_refresh(bufnr)
          end,
        })
        -- fire it first time on load as well
        vim.lsp.semantic_tokens.enable(true, { bufnr = bufnr, client_id = client.id })
      end
    end
  end
})
-- Log
vim.api.nvim_create_user_command("LspLog", function()
  vim.cmd.vsplit(vim.lsp.log.get_filename())
end, {
  desc = "Get all the lsp logs",
})
-- Info
vim.api.nvim_create_user_command("LspInfo", function()
  vim.cmd("silent checkhealth vim.lsp")
end, {
  desc = "Get all the information about all LSP attached",
})
------------------------------------
-- conform.nvim formatting
------------------------------------
local conform = require('conform')
conform.setup({
  -- 常用语言：按序执行，stop_after_first 用第一个可用的
  formatters_by_ft = {
    lua = { 'stylua' },
    python = { 'ruff_format', 'black', stop_after_first = true },
    javascript = { 'prettierd', 'prettier', stop_after_first = true },
    typescript = { 'prettierd', 'prettier', stop_after_first = true },
    javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
    typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
    json = { 'prettierd', 'prettier', stop_after_first = true },
    yaml = { 'prettierd', 'prettier', stop_after_first = true },
    markdown = { 'prettierd', 'prettier', stop_after_first = true },
    go = { 'gofmt' },
    rust = { 'rustfmt' },
    c = { 'clang-format' },
    cpp = { 'clang-format' },
    sh = { 'beautysh' },
  },
  -- 不自动保存格式化；<C-q> 语义由 LspAttach 映射决定
  format_on_save = false,
  default_format_opts = {
    -- 有配置的格式化器用配置的，否则回退 LSP
    lsp_format = 'fallback',
  },
})
------------------------------------
-- AutoCmd for different filetypes
------------------------------------
vim.api.nvim_create_autocmd('FileType', {
  pattern = {'python'},
  callback = function()
    map(nx, "<leader>A", require("lspimport").import, opts_silent)
  end,
})
---------------------------
-- other related plugins
---------------------------
require("nvim-autopairs").setup({
  disable_filetype = {}
})
require('call_graph').setup({
  log_level = "info",
  reuse_buf = true,
  auto_toggle_hl = true,
  hl_delay_ms = 200,
  ref_call_max_depth = 3
})
return M
