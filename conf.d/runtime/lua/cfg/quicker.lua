local config = {}
if is_unix() then
  config = {
    keys = {
      {
        ">",
        function()
          is_require("quicker").expand({ before = 2, after = 4, add_to_existing = true })
        end,
        desc = "Expand quickfix context",
      },
      {
        "<",
        function()
          is_require("quicker").collapse()
        end,
        desc = "Collapse quickfix context",
      }
    }
  }
end
require("quicker").setup(config)
