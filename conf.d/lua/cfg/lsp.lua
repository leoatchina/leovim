local M = {}
local unpack = unpack or table.unpack
local map = vim.keymap.set
local autocmd = vim.api.nvim_create_autocmd
local lsp_capabilities = require("lsp-selection-range").update_capabilities(vim.lsp.protocol.make_client_capabilities())
lsp_capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}
-------------
-- diagnostic
-------------
vim.diagnostic.enable(false)
vim.diagnostic.config({
  virtual_text = false,
  underline = false,
  float = {border = "single"}
})
function _G.toggle_diagnostics()
  if vim.g.diagnostics_enable then
    print("diagnostics off")
    vim.diagnostic.enable(false)
  else
    print("diagnostics on")
    vim.g.diagnostics_enable = true
    vim.diagnostic.enable()
  end
end
-- toggle diagnostic virtual text && underline
function _G.toggle_diagnostics_highlight()
  if vim.g.diagnostic_virtualtext_underline then
    print("virtualtext_underline off")
    vim.g.diagnostic_virtualtext_underline = false
    vim.diagnostic.config({
      virtual_text = false,
      underline = false,
    })
  else
    print("virtualtext_underline on")
    vim.g.diagnostic_virtualtext_underline = true
    vim.diagnostic.config({
      virtual_text = true,
      underline = true,
    })
  end
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
  ensure_installed = vim.g.ensure_installed,
  automatic_enable = true,
  handlers = {
    function (server_name)
      vim.lsp.config(server_name, {capabilities = lsp_capabilities})
      vim.lsp.enable(server_name)
    end,
    ['pyright'] = function()
      vim.lsp.config('pyright', {
        filetypes = { "python" },
        cmd = executable('delance-langserver') and {'delance-langserver', '--stdio'} or {'pyright-langserver', '--stdio'},
        settings = {
          pyright = {
            disableOrganizeImports = false,
            disableTaggedHints = false,
            analysis = {
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",  -- 更全面的诊断
              -- 可选：忽略特定警告（如未使用变量）
              diagnosticSeverityOverrides = {
                reportUnusedVariable = "warning",  -- 未使用变量设为警告
                reportUnusedImport = "warning",     -- 未使用导入设为警告
              }
            }
          },
          python = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "workspace",
              typeCheckingMode = "standard",
              useLibraryCodeForTypes = true,
              -- we can this setting below to redefine some diagnostics
              diagnosticSeverityOverrides = {
                deprecateTypingAliases = false,
              },
              -- 启用严格的未使用诊断
              reportUnusedImport = true,
              reportUnusedVariable = true,
              reportUnusedFunction = true,
              -- inlay hint settings are provided by pylance?
              inlayHints = {
                callArgumentNames = "partial",
                functionReturnTypes = true,
                pytestParameters = true,
                variableTypes = true,
              },
            },
          },
        },
      })
    end,
    ['lua_ls'] = function()
      vim.lsp.config('lua_ls', {
        filetypes = { "lua" },
        hint = {
          enable = true,
        },
        codeLens = {
          enable = false,
        },
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      })
    end,
    ['gopls'] = function()
      vim.lsp.config('gopls', {
        filetypes = { "go" },
        hint = {
          enable = true,
        },
        codeLens = {
          enable = true,
        },
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = vim.g.gobin_exe_version ~= nil and vim.g.gobin_exe_version > 1.1913,
            gofumpt = vim.g.gobin_exe_version ~= nil and vim.g.gobin_exe_version > 1.1913,
          },
        },
      })
    end,
    ['jdtls'] = function()
      vim.lsp.config('jdtls', {
        filetypes = { "java", "javac", "jar" },
      })
    end
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
-- lsp attach
-----------------
require('call_graph').setup({
  log_level = "info",
  reuse_buf = true,
  auto_toggle_hl = true,
  hl_delay_ms = 200,
  ref_call_max_depth = 3
})
local nx = { 'n', 'x' }
local opts_echo = { noremap = true, silent = false, nowait= true, buffer = bufnr }
local opts_silent = { noremap = true, silent = true, nowait = true, buffer = bufnr }
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(args)
    local bufnr = args.bufnr
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if lsp_capabilities and lsp_capabilities.completionProvider then
      vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
    end
    if lsp_capabilities and lsp_capabilities.definitionProvider then
      vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
    end
    -- lsp info/restart
    map(nx, "<M-l>i", [[<Cmd>LspInfo<Cr>]], opts_silent)
    map(nx, "<M-l>r", [[<Cmd>LspRestart<Cr>]], opts_silent)
    -- code action
    map('n', "<F2>", vim.lsp.buf.rename, opts_echo)
    map('n', "<M-a>", vim.lsp.buf.code_action, opts_silent)
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
    map(nx, "<leader>W", vim.lsp.buf.workspace_symbol, opts_silent)
    map(nx, "cdL", [[<Cmd>lua vim.print(vim.lsp.buf.list_workspace_folders())<Cr>]], opts_silent)
    map('i', "<C-x><C-x>", function() vim.lsp.buf.signature_help { border = 'single' } end, opts_silent)
    -- diagnostic
    map(nx, "<leader>o", toggle_diagnostics, opts_silent)
    map(nx, "<leader>O", toggle_diagnostics_highlight, opts_silent)
    map(nx, "<leader>d", [[<Cmd>lua vim.diagnostic.setloclist({open=true})<Cr>]], opts_silent)
    map(nx, "<leader>D", [[<Cmd>lua vim.diagnostic.setloclist({open=true, workspace=true})<Cr>]], opts_silent)
    -- select range
    local ok
    ok, _ = pcall(function()
      vim.treesitter.get_range(vim.treesitter.get_node(), bufnr)
    end, bufnr)
    if not ok then
      map('n', "<M-s>", require('lsp-selection-range').trigger, opts_silent)
      map('x', "<M-s>", require('lsp-selection-range').expand, opts_silent)
    end
    -- semantic token highlight
    ok, _ = pcall(function()
      vim.treesitter.get_parser(bufnr)
    end, bufnr)
    if not ok then
      if lsp_capabilities and lsp_capabilities.semanticTokensProvider and lsp_capabilities.semanticTokensProvider.full then
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
    -- inlay_hint
    if client.supports_method("textDocument/inlayHint", { bufnr = bufnr }) then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      map(nx, "<leader>i", [[<Cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<Cr>]], opts_echo)
    end
    -- codelens
    if client.supports_method("textDocument/codeLens", { bufnr = bufnr }) then
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
      map(nx, "<leader>a", vim.lsp.codelens.run, opts_echo)
    end
    map(nx, "<leader>S", require('symbol-usage').toggle, opts_echo)
  end
})
-- lspimport for python and pyright
vim.api.nvim_create_autocmd('FileType', {
  pattern = {'python'},
  callback = function()
    map(nx, "<leader>A", require("lspimport").import, opts_silent)
  end,
})
---------------------------
-- autopairs
---------------------------
local autopairs = require("nvim-autopairs")
autopairs.setup({
  disable_filetype = {},
})
return M
