local ls_path
if WINDOWS() then
  ls_path = vim.fn.Expand('~/.leovim.windows/jars')
else
  ls_path = vim.fn.Expand('~/.leovim.unix/jars')
end
require('spring_boot').setup({
  ls_path = ls_path,
  jdtls_name = "jdtls",
  log_file = nil,
})
