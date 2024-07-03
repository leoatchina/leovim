-- toggle diagnostic
vim.g.diagnostics_enable = true
function _G.toggle_diagnostics()
  if vim.g.diagnostics_enable then
    print("diagnostics off")
    vim.g.diagnostics_enable = false
    vim.diagnostic.disable()
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
vim.diagnostic.config({
  virtual_text = false,
  underline = false,
  float = {border = "single"}
})
-- maps
local opts = { noremap = true, silent = true }
local map = vim.keymap.set
map('n', '<leader>o', '<cmd>lua toggle_diagnostics()<CR>', opts)
map('n', '<leader>O', '<cmd>lua toggle_diagnostics_highlight()<CR>', opts)
map('n', '<leader>d', '<cmd>lua vim.diagnostic.setloclist({open=true})<CR>', opts)
map('n', '<leader>D', '<cmd>lua vim.diagnostic.setloclist({open=true, workspace=true})<CR>', opts)
