return {
  filetypes = { "java", "javac", "jar" },
  root_markers = function ()
    local lst = vim.g.root_patterns
    table.insert(lst, 'mvnw')
    table.insert(lst, 'gradlew')
    return lst
  end
}
