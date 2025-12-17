local utils = require('utils')
local config = {}
if utils.is_unix() then
  config = {
    keys = {
      {
        ">",
        function()
          require("quicker").expand({ before = 2, after = 4, add_to_existing = true })
        end,
        desc = "Expand quickfix context",
      },
      {
        "<",
        function()
          require("quicker").collapse()
        end,
        desc = "Collapse quickfix context",
      }
    }
  }
end
require("quicker").setup(config)
