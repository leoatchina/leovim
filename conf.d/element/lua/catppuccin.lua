require('catppuccin').setup({
  coc_nvim = vim.fn.PlannedCoc() > 0,
  integration = {
    dap = {
      enabled = true,
      enable_ui = true, -- enable nvim-dap-ui
    }
  },
  native_lsp = {
    enabled = true,
    virtual_text = {
      errors = { "italic" },
      hints = { "italic" },
      warnings = { "italic" },
      information = { "italic" },
    },
    underlines = {
      errors = { "underline" },
      hints = { "underline" },
      warnings = { "underline" },
      information = { "underline" },
    },
  }
})
