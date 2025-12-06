local ls_path
if is_windows() then
  ls_path = vim.fn['utils#expand']('~/.leovim.windows/jars')
else
  ls_path = vim.fn['utils#expand']('~/.leovim.unix/jars')
end
require('spring_boot').setup({
  ls_path = ls_path,
  jdtls_name = "jdtls",
  log_file = nil,
})
