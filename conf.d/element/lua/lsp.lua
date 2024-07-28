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
-- lsp attach
-----------------
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(args)
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
    -- signatureHelp
    map('i', "<C-x><C-x>", vim.lsp.buf.signature_help, opts_silent)
    -- format
    map({ 'n', 'x' }, "<C-q>", vim.lsp.buf.format, opts_silent)
    -- Rename
    map({ 'n', 'x' }, "<F2>", vim.lsp.buf.rename, opts_echo)
    -- lsp
    map('n', "<leader>t", [[<Cmd>Vista finder nvim_lsp<Cr>]], opts_silent)
    -- native lsp
    map('n', "<leader>S", vim.lsp.buf.workspace_symbol, opts_silent)
    map('n', "gl", vim.lsp.buf.outgoing_calls, opts_silent)
    map('n', "gh", vim.lsp.buf.incoming_calls, opts_silent)
    -- list workspace folder && omnifunc
    map('n', "cdL", [[<Cmd>lua vim.print(vim.lsp.buf.list_workspace_folders())<Cr>]], opts_silent)
    -- lsp info/restart
    map('n', "<M-l>i", [[<Cmd>LspInfo<Cr>]], opts_silent)
    map('n', "<M-l>r", [[<Cmd>LspRestart<Cr>]], opts_silent)
    -- diagnostic error
    map('n', '[d', vim.diagnostic.goto_prev, opts_silent)
    map('n', ']d', vim.diagnostic.goto_next, opts_silent)
    map('n', '[e', [[<Cmd>lua vim.diagnostic.goto_prev({severity=vim.diagnostic.severity.ERROR})<CR>]], opts_silent)
    map('n', ']e', [[<Cmd>lua vim.diagnostic.goto_next({severity=vim.diagnostic.severity.ERROR})<CR>]], opts_silent)
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
    -- inlay_hint
    if client.supports_method("textDocument/inlayHint", { bufnr = bufnr }) then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      map({ 'n', 'x' }, "<leader>I", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
      end, opts_echo)
    end
    -- codelens
    if client.supports_method("textDocument/codeLens", { bufnr = bufnr }) then
      vim.lsp.codelens.refresh({ bufnr = bufnr })
    end
    -- codeaction && symbols
    map({ 'n', 'x' }, "<M-a>", require("actions-preview").code_actions, opts_silent)
    map({ 'n', 'x' }, "<leader>A", require("lspimport").import, opts_silent)
    map({ 'n', 'x' }, "<leader>R", require('symbol-usage').refresh, opts_echo)
    map({ 'n', 'x' }, "<leader>C", require('symbol-usage').toggle, opts_echo)
  end
})
-----------------
-- lsp ui call
-----------------
if Installed('lspui.nvim') then
  require('LspUI').setup({
    pos_keybind = {
      main = {
        back = "L",
        hide_secondary = "H",
      },
      secondary = {
        jump = "o",
        jump_split = "<C-]>",
        jump_vsplit = "<C-v>",
        jump_tab = "<C-t>",
        quit = "q",
        hide_main = "H",
        fold_all = "X",
        expand_all = "O",
        enter = "L",
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
elseif Installed('glance.nvim') then
  function M.CheckHandler(handler)
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
end
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
