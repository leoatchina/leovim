local M = {}
local unpack = unpack or table.unpack
local map = vim.keymap.set
local autocmd = vim.api.nvim_create_autocmd
local lsp_capabilities = require("lsp-selection-range").update_capabilities(vim.lsp.protocol.make_client_capabilities())
-----------------
-- neoconf
-----------------
require("neoconf").setup({
  -- name of the local settings files
  local_settings = ".neoconf.json",
  import = {
    vscode = true,
    coc = true,
    nlsp = false,
  }
})
local opts_neoconf = { noremap = true, silent = true }
map('n', "<M-l>n", [[<Cmd>Neoconf local<Cr>]], opts_neoconf)
map('n', "<M-l>g", [[<Cmd>Neoconf glocal<Cr>]], opts_neoconf)
map('n', "<M-l>s", [[<Cmd>Neoconf show<Cr>]], opts_neoconf)
map('n', "<M-l>l", [[<Cmd>Neoconf lsp<Cr>]], opts_neoconf)
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
  local round_start = { '', 'SymbolUsageRounding' }
  local round_end = { '', 'SymbolUsageRounding' }
  if symbol.references then
    local num = symbol.references == 0 and 'no' or symbol.references
    local usage = symbol.references <= 1 and 'usage' or 'usages'
    table.insert(res, round_start)
    table.insert(res, { '󰌹 ', 'SymbolUsageRef' })
    table.insert(res, { ('%s %s'):format(num, usage), 'SymbolUsageContent' })
    table.insert(res, round_end)
  end
  if symbol.implementation then
    table.insert(res, round_start)
    table.insert(res, { '󰡱 ', 'SymbolUsageImpl' })
    table.insert(res, { symbol.implementation .. ' impls', 'SymbolUsageContent' })
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
local lspconfig = require("lspconfig")
local default_setup = function(server)
  lspconfig[server].setup({
    capabilities = lsp_capabilities
  })
end
require("mason-lspconfig").setup({
  ensure_installed = vim.g.ensure_installed,
  handlers = {
    default_setup,
    lua_ls = function()
      lspconfig.lua_ls.setup({
        filetypes = { "lua" },
        capabilities = lsp_capabilities,
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
    gopls = function()
      lspconfig.gopls.setup({
        filetypes = { "go" },
        capabilities = lsp_capabilities,
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
    jdtls = function()
      lspconfig.jdtls.setup({
        capabilities = lsp_capabilities,
      })
    end,
  }
})
-----------------
-- lspui
-----------------
require('LspUI').setup({
  pos_keybind = {
    main = {
      hide_secondary = "<leader>h",
      back = "<leader>l",
    },
    secondary = {
      next_file_entry = "J",
      prev_file_entry = "K",
      jump = "<Cr>",
      jump_split = "<C-x>",
      jump_vsplit = "<C-]>",
      jump_tab = "<C-t>",
      toggle_fold = "o",
      quit = "<M-q>",
      fold_all = "X",
      expand_all = "O",
      hide_main = "<leader>h",
      enter = "<leader>l",
    },
  }
})
function M.LspUIApi(method)
  if method == 'references' then
    method = 'reference'
  end
  require("LspUI")["api"][method](function(data)
    if data then
      vim.api.nvim_set_var("lsp_found", 1)
    else
      vim.api.nvim_set_var("lsp_found", 0)
    end
  end)
end
function M.LspHandler(method, open_action)
  local handler_dict = {
    definition = 'textDocument/definition',
    references = 'textDocument/references',
    type_definition = 'textDocument/typeDefinition',
    implementation = 'textDocument/implementation',
    declaration = 'textDocument/declaration'
  }
  local handler = handler_dict[method]
  local params = vim.lsp.util.make_position_params()
  local results = vim.lsp.buf_request_sync(0, handler, params, 500)
  if type(results) == 'table' and next(table) then
    results = results[1]
    if results == nil then
      vim.api.nvim_set_var("lsp_found", 0)
      return
    end
    for key, values in pairs(results) do
      if key == 'error' then
        vim.fn['preview#errmsg'](values['message'])
        vim.api.nvim_set_var("lsp_found", 0)
        return
      elseif key == 'result' then
        if values == nil then
          vim.api.nvim_set_var("lsp_found", 0)
          return
        elseif #values > 1 then
          vim.api.nvim_set_var("lsp_found", 1)
          M.LspUIApi(method)
          return
        else
          -- value
          local value = values[1]
          if value == nil then
            vim.api.nvim_set_var("lsp_found", 0)
            return
          end
          -- range
          local range = value.range or value.targetRange
          if range == nil then
            vim.api.nvim_set_var("lsp_found", 0)
            return
          end
          -- file
          local file = value.uri or value.targetUri
          if file == nil then
            vim.api.nvim_set_var("lsp_found", 0)
            return
          end
          -- jumpto
          local line = range.start.line + 1
          local col = range.start.character
          vim.api.nvim_command(open_action .. ' ' .. file)
          vim.api.nvim_win_set_cursor(0, {line, col})
          vim.api.nvim_set_var("lsp_found", 1)
          return
        end
      end
    end
    vim.api.nvim_set_var("lsp_found", 0)
  else
    vim.api.nvim_set_var("lsp_found", 0)
  end
end
-----------------
-- lsp attach
-----------------
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(args)
    local nx = { 'n', 'x' }
    local bufnr = args.bufnr
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local opts_silent = { noremap = true, silent = true, buffer = bufnr }
    local opts_echo = { noremap = true, silent = false, buffer = bufnr }
    if lsp_capabilities and lsp_capabilities.completionProvider then
      vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
    end
    if lsp_capabilities and lsp_capabilities.definitionProvider then
      vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
    end
    -- LspUI
    map('n', "<F2>", [[<Cmd>LspUI rename<Cr>]], opts_echo)
    map('n', "<M-a>", [[<Cmd>LspUI code_action<Cr>]], opts_silent)
    -- lsp info/restart
    map(nx, "<M-l>i", [[<Cmd>LspInfo<Cr>]], opts_silent)
    map(nx, "<M-l>r", [[<Cmd>LspRestart<Cr>]], opts_silent)
    -- vista
    map(nx, "<leader>t", [[<Cmd>Vista finder nvim_lsp<Cr>]], opts_silent)
    -- diagnostic error
    map(nx, ';d', [[<Cmd>LspUI diagnostic next<CR>]], opts_silent)
    map(nx, ',d', [[<Cmd>LspUI diagnostic prev<CR>]], opts_silent)
    map(nx, ';e', [[<Cmd>LspUI diagnostic next error<CR>]], opts_silent)
    map(nx, ',e', [[<Cmd>LspUI diagnostic prev error<CR>]], opts_silent)
    -- native lsp
    map('i', "<C-x><C-x>", vim.lsp.buf.signature_help, opts_silent)
    map(nx, "gl", vim.lsp.buf.outgoing_calls, opts_silent)
    map(nx, "gh", vim.lsp.buf.incoming_calls, opts_silent)
    map(nx, "<C-q>", vim.lsp.buf.format, opts_silent)
    map(nx, "<leader>W", vim.lsp.buf.workspace_symbol, opts_silent)
    map(nx, "cdL", [[<Cmd>lua vim.print(vim.lsp.buf.list_workspace_folders())<Cr>]], opts_silent)
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
    -- inlay_hint
    if client.supports_method("textDocument/inlayHint", { bufnr = bufnr }) then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      map(nx, "<leader>I", [[<Cmd>LspUI inlay_hint<Cr>]], opts_echo)
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
    map(nx, "<leader>A", require("lspimport").import, opts_silent)
    map(nx, "<leader>R", require('symbol-usage').toggle, opts_echo)
  end
})
------------------------------
-- winbar
------------------------------
require("winbar").setup({
  enabled = true,
  show_file_path = true,
  show_symbols = true,
  colors = {
    path = "", -- You can customize colors like #c946fd
    file_name = "",
    symbols = "",
  },
  icons = {
    file_icon_default = "",
    seperator = ">",
    editor_state = "●",
    lock_icon = "",
  },
  exclude_filetype = {
    "help",
    "startify",
    "dashboard",
    "neogitstatus",
    "netrw",
    "floaterm",
    "terminal",
    "flog",
    "fzf",
    "fugitive",
    "vim-plug",
    "qf",
  },
})
autocmd("FileType", {
  pattern = {
    "fzf",
    "leaderf",
    "fern",
    "vista",
    "vista_kind",
    "vista_toc",
    "netrw",
    "vim-plug",
    "nofile",
    "floaterm",
    "coctree",
    "fzf-funky",
  },
  callback = function()
    vim.wo.winbar = ""
  end,
})
autocmd({ "BufEnter", "BufRead", "BufReadPost", "BufCreate" }, {
  callback = function()
    if vim.bo.buftype == "" or vim.bo.buftype == "terminal" then
      vim.wo.winbar = ""
    end
  end,
})
------------------
-- others
------------------
-- border
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "single",
})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = "single",
  close_events = { "BufHidden", "InsertLeave" },
})
return M
