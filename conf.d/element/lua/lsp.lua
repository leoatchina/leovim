local unpack = unpack or table.unpack
local map = vim.keymap.set
local autocmd = vim.api.nvim_create_autocmd
-----------------
-- neoconf
-----------------
require("neoconf").setup({
  -- name of the local settings files
  local_settings = ".vim/neoconf.json",
  import = {
    vscode = true,
    coc = true,
    nlsp = false,
  }
})
local opts_neoconf = { noremap = true, silent = true }
map("n", "<M-l>n", [[<Cmd>Neoconf local<Cr>]], opts_neoconf)
map("n", "<M-l>g", [[<Cmd>Neoconf glocal<Cr>]], opts_neoconf)
map("n", "<M-l>s", [[<Cmd>Neoconf show<Cr>]], opts_neoconf)
map("n", "<M-l>l", [[<Cmd>Neoconf lsp<Cr>]], opts_neoconf)
-----------------
-- lspconfig
-----------------
local lspconfig = require("lspconfig")
-- capabilities
local capabilities
if Installed('nvim-cmp') then
  capabilities = require('cmp_nvim_lsp').default_capabilities()
else
  capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion = {
    completionItem = {
      snippetSupport = true,
      resolveSupport = {
        properties = { 'edit', 'documentation', 'detail', 'additionalTextEdits' },
      },
    },
    completionList = {
      itemDefaults = {
        'editRange',
        'insertTextFormat',
        'insertTextMode',
        'data',
      },
    },
  }
end
if capabilities then
  capabilities = require("lsp-selection-range").update_capabilities(capabilities)
end
-----------------------
-- fzf_lsp
-----------------------
vim.lsp.handlers["textDocument/codeAction"] = require 'fzf_lsp'.code_action_handler
vim.lsp.handlers["textDocument/definition"] = require 'fzf_lsp'.definition_handler
vim.lsp.handlers["textDocument/declaration"] = require 'fzf_lsp'.declaration_handler
vim.lsp.handlers["textDocument/typeDefinition"] = require 'fzf_lsp'.type_definition_handler
vim.lsp.handlers["textDocument/implementation"] = require 'fzf_lsp'.implementation_handler
vim.lsp.handlers["textDocument/references"] = require 'fzf_lsp'.references_handler
vim.lsp.handlers["textDocument/documentSymbol"] = require 'fzf_lsp'.document_symbol_handler
vim.lsp.handlers["callHierarchy/incomingCalls"] = require 'fzf_lsp'.incoming_calls_handler
vim.lsp.handlers["callHierarchy/outgoingCalls"] = require 'fzf_lsp'.outgoing_calls_handler
vim.lsp.handlers["workspace/symbol"] = require 'fzf_lsp'.workspace_symbol_handler
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
-----------------
-- attach
-----------------
local lsp_zero = require('lsp-zero')
lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({
    buffer = bufnr,
    preserve_mappings = false,
    exclude = { 'K', 'gd', 'gi', 'go', 'gr', 'gl', '<F3>', '<F4>' }
  })
  local opts_silent = { noremap = true, silent = true, buffer = bufnr }
  local opts_nosilent = { noremap = true, silent = false, buffer = bufnr }
  if capabilities.completionProvider then
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
  end
  if capabilities.definitionProvider then
    vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
  end
  -- signatureHelp
  map("i", "<C-x><C-x>", vim.lsp.buf.signature_help, opts_silent)
  -- format
  map({ "n", "x" }, "<C-q>", vim.lsp.buf.format, opts_silent)
  -- fzf-lsp
  map("n", "<leader>s", [[<Cmd>Vista finder<Cr>]], opts_silent)
  map("n", "<leader>S", [[<Cmd>WorkspaceSymbols<Cr>]], opts_silent)
  map("n", "gl", [[<Cmd>OutgoingCalls<Cr>]], opts_silent)
  map("n", "gh", [[<Cmd>IncomingCalls<Cr>]], opts_silent)
  -- list workspace folder && omnifunc
  map("n", "cdL", [[<Cmd>lua vim.print(vim.lsp.buf.list_workspace_folders())<Cr>]], opts_silent)
  -- lsp info/restart
  map("n", "<M-l>i", [[<Cmd>LspInfo<Cr>]], opts_silent)
  map("n", "<M-l>r", [[<Cmd>LspRestart<Cr>]], opts_silent)
  -- diagnostic error
  map('n', '[d', [[<Cmd>lua vim.diagnostic.goto_prev()<CR>]], opts_silent)
  map('n', ']d', [[<Cmd>lua vim.diagnostic.goto_next()<CR>]], opts_silent)
  map('n', '[e', [[<Cmd>lua vim.diagnostic.goto_prev({severity=vim.diagnostic.severity.ERROR})<CR>]], opts_silent)
  map('n', ']e', [[<Cmd>lua vim.diagnostic.goto_next({severity=vim.diagnostic.severity.ERROR})<CR>]], opts_silent)
  -- codeaction && codelens
  map({ "n", "x" }, "<M-a>", require("actions-preview").code_actions, opts_silent)
  map({ "n", "x" }, "<leader>A", require("lspimport").import, opts_silent)
  map({ "n", "x" }, "<leader>R", require('symbol-usage').refresh, opts_nosilent)
  map({ "n", "x" }, "<leader>C", require('symbol-usage').toggle, opts_nosilent)
  -- inlayhints
  if vim.fn.has('nvim-0.10') > 0 then
    map({ "n", "x" }, "<leader>I", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
    end, opts_nosilent)
  end
  -- select range
  local ok, _ = pcall(function()
    vim.treesitter.get_range(vim.treesitter.get_node(), bufnr)
  end, bufnr)
  if not ok then
    map("n", "<C-s>", require('lsp-selection-range').trigger, opts_silent)
    map("x", "<C-s>", require('lsp-selection-range').expand, opts_silent)
  end
  -- semantic token highlight
  if capabilities.semanticTokensProvider and capabilities.semanticTokensProvider.full then
    local augroup = vim.api.nvim_create_augroup("SemanticTokens", {})
    autocmd("TextChanged", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        vim.lsp.semantic_tokens.force_refresh(bufnr)
      end,
    })
    -- fire it first time on load as well
    vim.lsp.semantic_tokens.start(bufnr, client)
  end
end)
-----------------
-- mason lspconfig
-----------------
require("mason-lspconfig").setup({
  ensure_installed = vim.g.ensure_installed,
  handlers = {
    lsp_zero.default_setup,
    jdtls = lsp_zero.noop,
    lua_ls = function()
      lspconfig.lua_ls.setup({
        filetypes = { "lua" },
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
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
            gofumpt = true,
          },
        },
      })
    end,
    rust_analyzer = lsp_zero.noop,
  }
})
vim.g.rustaceanvim = {
  server = {
    capabilities = lsp_zero.get_capabilities()
  },
}
if vim.g.java_jdtls and vim.g.java_jdtls > 0 then
  local jdtls_config = {}
end
-----------------
-- glance
-----------------
local glance = require("glance")
local actions = glance.actions
glance.setup({
  height = 40,
  mappings = {
    list = {
      ["<C-b>"] = actions.preview_scroll_win(5),
      ["<C-f>"] = actions.preview_scroll_win(-5),
      ["<C-]>"] = actions.jump_vsplit,
      ["<C-x>"] = actions.jump_split,
      ["<C-t>"] = actions.jump_tab,
      ["<M-L>"] = actions.enter_win("preview"),
      ["q"] = actions.close,
      ["Q"] = actions.close,
      ["<M-q>"] = actions.close,
      ["<leader>q"] = actions.close,
      -- action disable
      ["<leader>l"] = false,
      ["<C-u>"] = false,
      ["<C-d>"] = false,
      ["v"] = false,
      ["s"] = false,
      ["t"] = false,
      ["o"] = false,
    },
    preview = {
      ["<M-q>"] = actions.close,
      ["<leader>q"] = actions.close,
      ["<Tab>"] = actions.next_location,
      ["<S-Tab>"] = actions.previous_location,
      ["q"] = actions.enter_win("list"),
      ["Q"] = actions.enter_win("list"),
      ["<M-H>"] = actions.enter_win("list"),
      -- action disable
      ["<leader>l"] = false,
    },
  },
  list = {
    position = "left",
    width = 0.3,
  },
  -- Configure preview window options
  preview_win_opts = {
    cursorline = true,
    number = true,
    wrap = false,
  },
  border = {
    enable = true,
  },
  theme = {
    enable = true,
    mode = "auto",
  },
  winbar = {
    enable = false,
  },
})
-- border
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "single",
})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = "single",
  close_events = { "BufHidden", "InsertLeave" },
})
-- winbar
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
-- lint
autocmd({ "BufWritePost" }, {
  callback = function()
    require("lint").try_lint()
  end,
})
