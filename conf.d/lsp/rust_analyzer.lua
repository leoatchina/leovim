filetypes = { "rust" }
cmd = { "rust-analyzer" }
workspace_required = true

root_dir = function(buf, cb)
  local root = vim.fs.root(buf, { "Cargo.toml", "rust-project.json" })
  local out = vim.system({ "cargo", "metadata", "--no-deps", "--format-version", "1" }, { cwd = root }):wait()
  if out.code ~= 0 then
    return cb(root)
  end

  local ok, result = pcall(vim.json.decode, out.stdout)
  if ok and result.workspace_root then
    return cb(result.workspace_root)
  end
  return cb(root)
end

settings = {
  autoformat = false,
  ["rust-analyzer"] = {
    check = {
      command = "clippy",
    },
  },
}

