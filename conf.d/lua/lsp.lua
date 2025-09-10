local M = {}
local n = { "n" }
local x = { "x" }
local nx = { "n", "x" }
local map = vim.keymap.set
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
-----------------------
-- symbol usage
-----------------------
local function hl(name) return vim.api.nvim_get_hl(0, { name = name }) end
-- hl-groups can have any name
vim.api.nvim_set_hl(0, 'SymbolUsageRounding', { fg = hl('CursorLine').bg, italic = true })
vim.api.nvim_set_hl(0, 'SymbolUsageContent', { bg = hl('CursorLine').bg, fg = hl('Comment').fg, italic = true })
vim.api.nvim_set_hl(0, 'SymbolUsageRef', { fg = hl('Function').fg, bg = hl('CursorLine').bg, italic = true })
vim.api.nvim_set_hl(0, 'SymbolUsageDef', { fg = hl('Type').fg, bg = hl('CursorLine').bg, italic = true })
vim.api.nvim_set_hl(0, 'SymbolUsageImpl', { fg = hl('@keyword').fg, bg = hl('CursorLine').bg, italic = true })
-- symbol_format
local function text_format(symbol)
  local res = {}
  if symbol.references then
    local round_start = { '', 'SymbolUsageRounding' }
    local round_end = { '', 'SymbolUsageRounding' }
    local num = symbol.references == 0 and 'no' or symbol.references
    local usage = symbol.references <= 1 and 'usage' or 'usages'
    table.insert(res, round_start)
    table.insert(res, { '󰌹 ', 'SymbolUsageRef' })
    table.insert(res, { ('%s %s'):format(num, usage), 'SymbolUsageContent' })
    table.insert(res, round_end)
  end
  return res
end
require('symbol-usage').setup({
  text_format = text_format,
  references = { enabled = true, include_declaration = false },
  implementation = { enabled = true },
  definition = { enabled = false },
  disable = {
    lsp = { 'vimls' },
    filetypes = { 'txt', 'log' },
  },
})
-------------------------
-- mason lspconfig
-------------------------
require("mason-lspconfig").setup({
  ensure_installed = vim.g.ensure_installed and vim.tbl_filter(function(server)
    return server ~= "debugpy" -- 过滤掉 debugpy，它是 DAP 而不是 LSP
  end, vim.g.ensure_installed) or {},
  automatic_enable = true
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
function M.LspAction(method, open_action)
  local handler_dict = {
    definition = 'textDocument/definition',
    declaration = 'textDocument/declaration',
    implementation = 'textDocument/implementation',
    type_definition = 'textDocument/typeDefinition',
    references = 'textDocument/references',
  }
  local handler = handler_dict[method]
  local params = vim.tbl_extend('force', vim.lsp.util.make_position_params(), method == 'references' and { context = { includeDeclaration = false } } or {})
  local results = vim.lsp.buf_request_sync(0, handler, params, 500)
  if type(results) ~= 'table' then
    vim.api.nvim_set_var("lsp_found", 0)
    return
  end
  _, results = next(results)
  if results == nil or results['result'] == nil then
    vim.api.nvim_set_var("lsp_found", 0)
    return
  end
  local qflist = {}
  local result = results['result']
  local add_qf = #result > 1 or open_action == 'list'
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
        vim.api.nvim_command(open_action .. ' ' .. loc.filename)
        vim.api.nvim_win_set_cursor(0, {loc.lnum, loc.col})
        return
      end
    end
    ::continue::
  end
  if next(qflist) then
    vim.api.nvim_set_var("lsp_found", 1)
    vim.fn.setqflist(qflist)
    vim.cmd('copen')
  else
    vim.api.nvim_set_var("lsp_found", 0)
  end
end
-----------------
-- lsp functions
-----------------
-- Attach
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(args)
    local bufnr = tonumber(args.bufnr)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
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
    -- code action
    map(n, "<F2>", vim.lsp.buf.rename, opts_echo)
    map(n, "<leader>a", vim.lsp.buf.code_action, opts_echo)
    -- vista
    map(nx, "<leader>t", [[<Cmd>Vista finder nvim_lsp<Cr>]], opts_silent)
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
    -- diagnostic
    map(n, 'ss', require('dropbar.api').pick, opts_silent)
    map(n, ',s', require('dropbar.api').goto_context_start, opts_silent)
    map(n, ';s', require('dropbar.api').select_next_context, opts_silent)
    -- select range
    local ok
    ok, _ = pcall(function()
      vim.treesitter.get_range(vim.treesitter.get_node(), bufnr)
    end, bufnr)
    if not ok then
      map(n, "<M-s>", require('lsp-selection-range').trigger, opts_silent)
      map(x, "<M-s>", require('lsp-selection-range').expand, opts_silent)
    end
    -- inlay_hint
    if client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
    end
    map(nx, "<leader>i", [[<Cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<Cr>]], opts_echo)
    -- codelens
    if client.server_capabilities.codeLensProvider then
      vim.api.nvim_set_hl(0, 'LspCodeLens', { fg = '#888888', bg = '#432345', italic = false })
      function M.codelens_toggle()
        if vim.b.codelens_enable == nil or vim.b.codelens_enable == false then
          vim.lsp.codelens.refresh({bufnr = bufnr})
          vim.b.codelens_enable = true
        else
          vim.lsp.codelens.clear(nil, 0)
          vim.b.codelens_enable = false
        end
      end
      M.codelens_toggle()
      map(nx, "<leader>C", require("lsp").codelens_toggle, opts_echo)
      map(nx, "<M-a>", vim.lsp.codelens.run, opts_echo)
    else
      map(nx, "<leader>C", [[<Cmd>echo "No codelens for current buffer."<Cr>]], opts_echo)
      map(nx, "<M-a>", [[<Cmd>echo "No codelens for current buffer."<Cr>]], opts_echo)
    end
    -- symbol-usage
    map(nx, "<leader>S", require('symbol-usage').toggle, opts_echo)
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
        vim.lsp.semantic_tokens.start(bufnr, client)
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
    map(n, "stc", "<Cmd>lua require'jdtls'.test_class()<CR>", opts_silent)
    map(n, "stm", "<Cmd>lua require'jdtls'.test_nearest_method()<CR>", opts_silent)
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
