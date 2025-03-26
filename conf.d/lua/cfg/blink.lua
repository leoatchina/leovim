require('blink.cmp').setup({
  keymap = { preset = 'super-tab' },
  appearance = {
    nerd_font_variant = 'mono'
  },
  fuzzy = { implementation = "prefer_rust_with_warning" },
  signature = { enabled = true },
  completion = {
    ghost_text = {
      enabled = false,
      -- Show the ghost text when an item has been selected
      show_with_selection = true,
      -- Show the ghost text when no item has been selected, defaulting to the first item
      show_without_selection = false,
      -- Show the ghost text when the menu is open
      show_with_menu = true,
      -- Show the ghost text when the menu is closed
      show_without_menu = true,
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 500,
    }
  },
  snippets = {
    expand = function(snippet) vim.snippet.expand(snippet) end,
    active = function(filter) return vim.snippet.active(filter) end,
    jump = function(direction) vim.snippet.jump(direction) end,
  },
  sources = {
    default = { 'path', 'snippets', 'buffer', 'lsp' },
    providers = {
      lsp = {
        name = 'LSP',
        module = 'blink.cmp.sources.lsp',
        opts = {},
        enabled = true, -- Whether or not to enable the provider
        async = false, -- Whether we should wait for the provider to return before showing the completions
        timeout_ms = 2000, -- How long to wait for the provider to return before showing completions and treating it as asynchronous
        transform_items = nil, -- Function to transform the items before they're returned
        should_show_items = true, -- Whether or not to show the items
        max_items = nil, -- Maximum number of items to display in the menu
        min_keyword_length = 0, -- Minimum number of characters in the keyword to trigger the provider
        -- If this provider returns 0 items, it will fallback to these providers.
        -- If multiple providers fallback to the same provider, all of the providers must return 0 items for it to fallback
        fallbacks = {},
        score_offset = 0, -- Boost/penalize the score of the items
        override = nil, -- Override the source's functions
      }
    }
  }
})
