return {
  filetypes = { "java", "javac", "jar" },
  root_markers = function ()
    local lst = vim.g.root_parterns
    table.insert(lst, 'mvnm')
    table.insert(lst, 'gradlew')
    return lst
  end
}
