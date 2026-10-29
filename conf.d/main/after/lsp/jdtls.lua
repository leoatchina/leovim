return {
  filetypes = { "java", "javac", "jar" },
  root_markers = vim.list_extend({ 'mvnw', 'gradlew' }, vim.g.root_patterns or { '.git' }),
}
