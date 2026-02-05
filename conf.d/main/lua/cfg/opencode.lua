vim.g.opencode_opts = {
  provider = {
    name = 'floaterm_enhance',
    toggle = function(self)
      local opencode_bufnr = vim.g.opencode_bufnr
      if opencode_bufnr and opencode_bufnr > 0 and vim.tbl_contains(vim.fn["floaterm#buflist#gather"](), opencode_bufnr) then
        self:stop()
      else
        self:start()
      end
    end,
    start = function(self)
      local opencode_bufnr = vim.g.opencode_bufnr
      if opencode_bufnr and opencode_bufnr > 0 and vim.tbl_contains(vim.fn["floaterm#buflist#gather"](), opencode_bufnr) then
        vim.fn["floaterm#terminal#open_existing"](opencode_bufnr)
      else
        local opts = vim.g.opencode_nvim_opts or '--wintype=vsplit --position=right --width=0.3'
        vim.fn["floaterm#enhance#cmd_run"]("opencode --port", opts, "AI", 1)
        vim.g.opencode_bufnr = vim.fn["floaterm#buflist#curr"]()
      end
    end,
    stop = function(self)
      local opencode_bufnr = vim.g.opencode_bufnr
      if opencode_bufnr and opencode_bufnr > 0 and vim.tbl_contains(vim.fn["floaterm#buflist#gather"](), opencode_bufnr) then
        vim.fn["floaterm#terminal#kill"](opencode_bufnr)
      end
      vim.g.opencode_bufnr = nil
    end,
  }
}
-- XXX
vim.keymap.set({ "n", "x" }, '+', function() return require("opencode").operator("@this ") end, { desc = "Add range to opencode", expr = true })
vim.keymap.set({ "n", "t" }, "<M-a>o", function() require("opencode").toggle() end, { desc = "Toggle opencode" })
vim.keymap.set({ "n", "x" }, "<M-a>g", function() require("opencode").ask("@diff: ", { submit = true }) end, { desc = "Ask opencode gdiff" })
vim.keymap.set({ "n", "x" }, "<Tab>oo", function() require("opencode").select() end, { desc = "Execute opencode action…" })
vim.keymap.set({ "n", "x" }, "<Tab>ol", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode this" })
vim.keymap.set({ "n", "x" }, "<Tab>of", function() require("opencode").ask("@buffer: ", { submit = true }) end, { desc = "Ask opencode buffer" })
-- <tab>o as prefix
vim.keymap.set({ "n", "x" }, "<Tab>od", function() require("opencode").ask("@diagnositcs: ", { submit = true }) end, { desc = "Ask opencode diagnositcs" })
vim.keymap.set({ "n", "x" }, "<Tab>ov", function() require("opencode").ask("@visible: ", { submit = true }) end, { desc = "Ask opencode visible" })
vim.keymap.set({ "n", "x" }, "<Tab>ob", function() require("opencode").ask("@buffers: ", { submit = true }) end, { desc = "Ask opencode buffers" })
vim.keymap.set({ "n", "x" }, "<Tab>oq", function() require("opencode").ask("@quickfix: ", { submit = true }) end, { desc = "Ask opencode quickfix" })
vim.keymap.set({ "n", "x" }, "<Tab>om", function() require("opencode").ask("@marks: ", { submit = true }) end, { desc = "Ask opencode marks" })
