local gitsigns = require("gitsigns")

local function set_buffer_map(buffer, mode, lhs, rhs)
  vim.keymap.set(mode, lhs, rhs, { buffer = buffer, silent = true })
end

local function visual_range()
  local first, last = vim.fn.line("v"), vim.fn.line(".")
  vim.cmd("normal! " .. string.char(27))
  return { math.min(first, last), math.max(first, last) }
end

local function reset_hunk(range)
  if vim.fn.confirm("Discard working-tree changes? This cannot be undone by Git.",
      "&Discard\n&Cancel", 2) == 1 then
    gitsigns.reset_hunk(range)
  end
end

gitsigns.setup({
  current_line_blame = false,
  current_line_blame_opts = {
    delay = 500,
    ignore_whitespace = true,
    virt_text = true,
    virt_text_pos = "eol",
  },
  on_attach = function(buffer)
    set_buffer_map(buffer, "n", ";g", function()
      if vim.wo.diff then
        vim.cmd("normal! ]c")
      else
        gitsigns.nav_hunk("next")
      end
    end)
    set_buffer_map(buffer, "n", ",g", function()
      if vim.wo.diff then
        vim.cmd("normal! [c")
      else
        gitsigns.nav_hunk("prev")
      end
    end)
    set_buffer_map(buffer, "n", "\\<CR>", gitsigns.refresh)
    set_buffer_map(buffer, "n", "\\<Tab>", gitsigns.toggle_signs)
    set_buffer_map(buffer, "n", "\\<Space>", gitsigns.preview_hunk)
    set_buffer_map(buffer, "n", "ghs", gitsigns.stage_hunk)
    set_buffer_map(buffer, "x", "ghs", function()
      gitsigns.stage_hunk(visual_range())
    end)
    set_buffer_map(buffer, "n", "ghp", gitsigns.preview_hunk_inline)
    set_buffer_map(buffer, "n", "ghb", gitsigns.blame_line)
    set_buffer_map(buffer, "n", "ghr", function()
      reset_hunk()
    end)
    set_buffer_map(buffer, "x", "ghr", function()
      reset_hunk(visual_range())
    end)
    set_buffer_map(buffer, { "o", "x" }, "ig", gitsigns.select_hunk)
    set_buffer_map(buffer, { "o", "x" }, "ag", gitsigns.select_hunk)
    set_buffer_map(buffer, "n", "<leader>vg", gitsigns.select_hunk)
    set_buffer_map(buffer, "n", "<leader>vG", gitsigns.select_hunk)
  end,
})
