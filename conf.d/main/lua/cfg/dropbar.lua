local dropbar = require('dropbar')
local sources = require('dropbar.sources')
local utils = require('dropbar.utils')
vim.api.nvim_set_hl(0, 'DropBarFileName', { fg = '#FFFFFF', italic = true })
local custom_path = {
  get_symbols = function(buff, win, cursor)
    local symbols = sources.path.get_symbols(buff, win, cursor)
    symbols[#symbols].name_hl = 'DropBarFileName'
    if vim.bo[buff].modified then
      symbols[#symbols].name = symbols[#symbols].name .. ' [+]'
      symbols[#symbols].name_hl = 'DiffAdded'
    end
    return symbols
  end,
}
dropbar.setup({
  bar = {
    sources = function(buf, _)
      if vim.bo[buf].ft == 'markdown' then
        return {
          custom_path,
          sources.markdown,
        }
      end
      if vim.bo[buf].buftype == 'terminal' then
        return {
          sources.terminal,
        }
      end
      return {
        custom_path,
        utils.source.fallback {
          sources.lsp,
          sources.treesitter,
        },
      }
    end,
    enable = function(buf, win, _)
      buf = vim._resolve_bufnr(buf)
      if
        not vim.api.nvim_buf_is_valid(buf)
        or not vim.api.nvim_win_is_valid(win)
      then
        return false
      end

      if
        not vim.api.nvim_buf_is_valid(buf)
        or not vim.api.nvim_win_is_valid(win)
        or vim.fn.win_gettype(win) ~= ''
        or vim.wo[win].winbar ~= ''
        or vim.bo[buf].ft == 'help'
      then
        return false
      end

      local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
      if stat and stat.size > 1024 * 1024 then
        return false
      end

      return vim.bo[buf].bt == 'terminal'
        or vim.bo[buf].ft == 'markdown'
        or pcall(vim.treesitter.get_parser, buf)
        or not vim.tbl_isempty(vim.lsp.get_clients({
          bufnr = buf,
          method = 'textDocument/documentSymbol',
        }))
    end,
  },
  sources = {
    path = {
      relative_to = function(buf, win)
        -- Show full path in oil or fugitive buffers
        local bufname = vim.api.nvim_buf_get_name(buf)
        if
          vim.startswith(bufname, 'oil://')
          or vim.startswith(bufname, 'fugitive://')
        then
          local root = bufname:gsub('^%S+://', '', 1)
          while root and root ~= vim.fs.dirname(root) do
            root = vim.fs.dirname(root)
          end
          return root
        end

        local ok, cwd = pcall(vim.fn.getcwd, win)
        return ok and cwd or vim.fn.getcwd()
      end,
    },
  },
  menu = {
    keymaps = {
      ['<C-c>'] = '<C-w>q'
    }
  }
})
-- map
local nx = { "n", "x" }
local map = vim.keymap.set
map(nx, 'ss', require('dropbar.api').pick, { noremap = true, silent = false, nowait= true })
map(nx, ',s', require('dropbar.api').goto_context_start, { noremap = true, silent = false, nowait= true })
map(nx, ';s', require('dropbar.api').select_next_context, { noremap = true, silent = false, nowait= true })
vim.ui.select = require('dropbar.utils.menu').select
