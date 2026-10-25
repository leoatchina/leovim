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
vim.lsp.config("*", {
  on_attach = function(client, bufnr)
    local ok, diag = pcall(require, "rj.extras.workspace-diagnostic")
    if ok then
      diag.populate_workspace_diagnostics(client, bufnr)
    end
  end,
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
-------------------------
-- mason lspconfig
-------------------------
require("mason-lspconfig").setup({
  ensure_installed = vim.g.ensure_installed and vim.tbl_filter(function(server)
    return server ~= "debugpy"
  end, vim.g.ensure_installed) or {},
  automatic_enable = {
    exclude = {
      vim.fn.index(vim.g.ensure_installed, 'pyright') >= 0 and 'basedpyright' or vim.fn.index(vim.g.ensure_installed, 'basedpyright') >= 0 and 'pyright'
    }
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
    map(nx, "<M-l>r", [[<Cmd>LspRestart<Cr>]], opts_silent)
    -- aerial
    map(nx, "F<Cr>", [[<Cmd>AerialNavToggle<Cr>]], opts_silent)
    -- call-graph
    map(nx, "gr", [[<Cmd>CallGraphR<Cr>]], opts_silent)
    map(nx, "gh", [[<Cmd>CallGraphI<Cr>]], opts_silent)
    map(nx, "gl", vim.lsp.buf.outgoing_calls, opts_silent)
    -- diagnostic error
    map(nx, ';d', vim.diagnostic.goto_next, opts_silent)
    map(nx, ',d', vim.diagnostic.goto_prev, opts_silent)
    map(nx, ';e', [[<Cmd>lua vim.diagnostic.goto_next({severity=vim.diagnostic.severity.ERROR, wrap=false})<CR>]], opts_silent)
    map(nx, ',e', [[<Cmd>lua vim.diagnostic.goto_prev({severity=vim.diagnostic.severity.ERROR, wrap=false})<CR>]], opts_silent)
    -- native lsp
    map(nx, "<C-q>", [[<Cmd>FormatWrite<Cr>]], opts_echo)
    map(nx, "K", function() vim.lsp.buf.hover { border = "rounded" } end, opts_silent)
    -- get workspace_symbol
    map(n, "<leader>w", ":lua vim.lsp.buf.workspace_symbol('<C-r><C-w>')<left><left>", opts_silent)
    map(x, "<leader>w", "y:lua vim.lsp.buf.workspace_symbol('<C-r>\"')<left><left>", opts_silent)
    map(nx, "cdL", [[<Cmd>lua vim.print(vim.lsp.buf.list_workspace_folders())<Cr>]], opts_silent)
    -- diagnostic
    map(nx, "<leader>o", toggle_diagnostics, opts_silent)
    map(nx, "<leader>O", toggle_virtual_text, opts_silent)
    map(nx, "<leader>d", [[<Cmd>lua vim.diagnostic.setloclist({open=true})<Cr>]], opts_silent)
    map(nx, "<leader>D", [[<Cmd>lua vim.diagnostic.setloclist({open=true, workspace=true})<Cr>]], opts_silent)
    map(nx, "<leader>d", [[<Cmd>lua vim.diagnostic.setloclist({open=true})<Cr>]], opts_silent)
    map(nx, "<leader>e", [[<Cmd>lua vim.diagnostic.setloclist({open=true, severity=vim.diagnostic.severity.ERROR})<Cr>]], opts_silent)
    -- inlay_hint
    if client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
    end
    map(nx, "<leader>i", [[<Cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<Cr>]], opts_echo)
    -- codelens
    if #vim.lsp.get_clients({ bufnr = bufnr, method = 'textDocument/codeLens' }) > 0 then
      vim.api.nvim_set_hl(0, 'LspCodeLens', { fg = '#888888', bg = '#432345', italic = false })
      local codelens = require('codelens')
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
        vim.lsp.semantic_tokens.start(bufnr, client.id)
      end
    end
  end
})
-- Stop
vim.api.nvim_create_user_command("LspStop", function(opts)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    if opts.args == "" or opts.args == client.name then
      client:stop(true)
      vim.notify(client.name .. ": stopped")
    end
  end
end, {
desc = "Stop all LSP clients or a specific client attached to the current buffer.",
nargs = "?",
complete = function(_, _, _)
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local client_names = {}
  for _, client in ipairs(clients) do
    table.insert(client_names, client.name)
  end
  return client_names
end,
})
-- Restart
vim.api.nvim_create_user_command("LspRestart", function()
  local detach_clients = {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    client:stop(true)
    if vim.tbl_count(client.attached_buffers) > 0 then
      detach_clients[client.name] = { client, vim.lsp.get_buffers_by_client_id(client.id) }
    end
  end
  local timer = vim.uv.new_timer()
  if not timer then
    return vim.notify("Servers are stopped but havent been restarted")
  end
  timer:start(
  100,
  50,
  vim.schedule_wrap(function()
    for name, client in pairs(detach_clients) do
      local client_id = vim.lsp.start(client[1].config, { attach = false })
      if client_id then
        for _, buf in ipairs(client[2]) do
          vim.lsp.buf_attach_client(buf, client_id)
        end
        vim.notify(name .. ": restarted")
      end
      detach_clients[name] = nil
    end
    if next(detach_clients) == nil and not timer:is_closing() then
      timer:close()
    end
  end)
  )
end, {
  desc = "Restart all the language client(s) attached to the current buffer",
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
-- AutoCmd for different filetypes
------------------------------------
vim.api.nvim_create_autocmd('FileType', {
  pattern = {'python'},
  callback = function()
    map(nx, "<leader>A", require("lspimport").import, opts_silent)
    local ok, venv = pcall(require, "rj.extras.venv")
    if ok then
      venv.setup()
    end
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"java"},
  callback = function()
    map(nx, "<leader>A", "<Cmd>lua require'jdtls'.organize_imports()<CR>", opts_silent)
    map(n, "sev", "<Cmd>lua require('jdtls').extract_variable()<CR>", opts_silent)
    map(n, "sec", "<Cmd>lua require('jdtls').extract_constant()<CR>", opts_silent)
    map(n, "stc", "<Cmd>lua require('jdtls').test_class()<CR>", opts_silent)
    map(n, "stm", "<Cmd>lua require('jdtls').test_nearest_method()<CR>", opts_silent)
    -- Visual 模式下的映射
    map(x, "sev", "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", opts_silent)
    map(x, "sec", "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", opts_silent)
    map(x, "sem", "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", opts_silent)
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
