local gitsigns = require("gitsigns")

local function set_buffer_map(buffer, mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = buffer, silent = true, desc = desc })
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
    end, "Next Git hunk")
    set_buffer_map(buffer, "n", ",g", function()
      if vim.wo.diff then
        vim.cmd("normal! [c")
      else
        gitsigns.nav_hunk("prev")
      end
    end, "Previous Git hunk")
    set_buffer_map(buffer, "n", "\\<CR>", gitsigns.refresh, "Refresh Git signs")
    set_buffer_map(buffer, "n", "\\<Tab>", gitsigns.toggle_signs, "Toggle Git signs")
    set_buffer_map(buffer, "n", "\\<Space>", gitsigns.preview_hunk, "Preview Git hunk")
    set_buffer_map(buffer, "n", "<M-g>s", gitsigns.stage_hunk, "Stage Git hunk")
    set_buffer_map(buffer, "x", "<M-g>s", function()
      gitsigns.stage_hunk(visual_range())
    end, "Stage selected Git lines")
    set_buffer_map(buffer, "n", "<M-g>p", gitsigns.preview_hunk_inline, "Preview Git hunk inline")
    set_buffer_map(buffer, "n", "<M-g>b", gitsigns.blame_line, "Blame current line")
    set_buffer_map(buffer, "n", "<M-g>r", function()
      reset_hunk()
    end, "Reset Git hunk (confirm)")
    set_buffer_map(buffer, "x", "<M-g>r", function()
      reset_hunk(visual_range())
    end, "Reset selected Git lines (confirm)")
    set_buffer_map(buffer, { "o", "x" }, "ig", gitsigns.select_hunk, "Select Git hunk")
    set_buffer_map(buffer, { "o", "x" }, "ag", gitsigns.select_hunk, "Select Git hunk")
    set_buffer_map(buffer, "n", "<leader>vg", gitsigns.select_hunk, "Select Git hunk")
    set_buffer_map(buffer, "n", "<leader>vG", gitsigns.select_hunk, "Select Git hunk")
  end,
})
