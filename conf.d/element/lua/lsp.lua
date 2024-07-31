local M = {}
local unpack = unpack or table.unpack
local map = vim.keymap.set
local autocmd = vim.api.nvim_create_autocmd
local lsp_capabilities = require("lsp-selection-range").update_capabilities({})
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
    capabilities = lsp_capabilities,
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
            staticcheck = vim.g.go_exe_version > 1.1913,
            gofumpt = vim.g.go_exe_version > 1.1913,
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
      jump = "<Cr>",
      jump_split = "<C-x>",
      jump_vsplit = "<C-]>",
      jump_tab = "<C-t>",
      toggle_fold = "o",
      quit = "q",
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
    map(nx, "<F2>", [[<Cmd>LspUI rename<Cr>]], opts_echo)
    map(nx, "<M-a>", [[<Cmd>LspUI code_action<Cr>]], opts_silent)
    map(nx, "<leader>I", [[<Cmd>LspUI inlay_hint<Cr>]], opts_echo)
    -- lsp info/restart
    map(nx, "<M-l>i", [[<Cmd>LspInfo<Cr>]], opts_silent)
    map(nx, "<M-l>r", [[<Cmd>LspRestart<Cr>]], opts_silent)
    -- vista
    map(nx, "<leader>t", [[<Cmd>Vista finder nvim_lsp<Cr>]], opts_silent)
    -- diagnostic error
    map(nx, '[d', vim.diagnostic.goto_prev, opts_silent)
    map(nx, ']d', vim.diagnostic.goto_next, opts_silent)
    map(nx, '[e', [[<Cmd>lua vim.diagnostic.goto_prev({severity=vim.diagnostic.severity.ERROR})<CR>]], opts_silent)
    map(nx, ']e', [[<Cmd>lua vim.diagnostic.goto_next({severity=vim.diagnostic.severity.ERROR})<CR>]], opts_silent)
    -- native lsp
    map('i', "<C-x><C-x>", vim.lsp.buf.signature_help, opts_silent)
    map(nx, "gl", vim.lsp.buf.outgoing_calls, opts_silent)
    map(nx, "gh", vim.lsp.buf.incoming_calls, opts_silent)
    map(nx, "<C-q>", vim.lsp.buf.format, opts_silent)
    map(nx, "<leader>S", vim.lsp.buf.workspace_symbol, opts_silent)
    map(nx, "cdL", [[<Cmd>lua vim.print(vim.lsp.buf.list_workspace_folders())<Cr>]], opts_silent)
    -- codelens
    if client.supports_method("textDocument/codeLens", { bufnr = bufnr }) then
      vim.lsp.codelens.refresh({ bufnr = bufnr })
    end
    map(nx, "<leader>A", require("lspimport").import, opts_silent)
    map(nx, "<leader>R", require('symbol-usage').refresh, opts_echo)
    map(nx, "<leader>C", require('symbol-usage').toggle, opts_echo)
    -- select range
    local ok
    ok, _ = pcall(function()
      vim.treesitter.get_range(vim.treesitter.get_node(), bufnr)
    end, bufnr)
    if not ok then
      map('n', "<C-s>", require('lsp-selection-range').trigger, opts_silent)
      map('x', "<C-s>", require('lsp-selection-range').expand, opts_silent)
    end
    ok, _ = pcall(function()
      vim.treesitter.get_parser(bufnr)
    end, bufnr)
    -- semantic token highlight
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
