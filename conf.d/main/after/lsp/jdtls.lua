local root_files = { "pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle" }

return {
  filetypes = { "java" },
  root_markers = {
    "pom.xml",
    "build.gradle",
    "build.gradle.kts",
    "settings.gradle",
    ".git",
  },
  root_dir = function(buf, cb)
    local fname = type(buf) == "number" and vim.api.nvim_buf_get_name(buf) or tostring(buf)
    local root = vim.fs.root(fname, root_files) or vim.fs.root(fname, { ".git" })
    if root and cb then
      return cb(root)
    end
    return root
  end,
}
