function _G.symbol_line()
  local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
  local ok, line = pcall(vim.api.nvim_buf_get_var, bufnr, 'coc_symbol_line')
  if string.find(line, "CocSymbolLineFile") then
    return ok and "%f"
  else
    return ok and "%f%#CocSymbolLineSeparator# > " .. line or ''
  end
end
vim.api.nvim_create_autocmd(
  {'WinEnter', 'BufWinEnter', 'CursorMoved', 'CursorHold'},
  {
    pattern = "*",
    callback = function()
      if vim.b.coc_symbol_line and vim.bo.buftype == '' then
        vim.wo.winbar = '%!v:lua.symbol_line()'
      else
        vim.wo.winbar = ''
      end
    end,
  }
)
