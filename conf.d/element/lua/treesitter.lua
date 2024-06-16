local map = vim.keymap.set
require("hlargs").setup({
  hl_priority = 1024 * 16
})
require("nvim-treesitter.install").prefer_git = true
require("nvim-treesitter.configs").setup({
  ensure_installed = vim.g.highlight_filetypes,
  sync_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = true,
    disable = function(client, bufnr)
      -- disable if semanticTokensProvider or > maxsize
      local caps = client.server_capabilities
      if caps and caps.semanticTokensProvider and caps.semanticTokensProvider.full then
        return true
      end
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
      if ok and stats and stats.size > 1024 * 1024 then
        return true
      end
    end,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<C-s>',
      scope_incremental = '<C-s>',
      node_incremental = '<TAB>',
      node_decremental = '<S-TAB>',
    },
  },
  matchup = {
    enable = true,
  },
  fold = {
    enable = false,
  },
  indent = {
    enable = false,
  },
})
map("n", "<M-l>t", ":TSUpdate ", { noremap = true, silent = false })
map("n", "<M-l>I", ":TSInstall ", { noremap = true, silent = false })
map({ 'n', 'x', 'o' }, 'sv', function() require("flash").treesitter() end, { noremap = true, silent = true })
map({ 'x', 'o' }, 'm', function() require("flash").treesitter_search() end, { noremap = true, silent = true })
-------------------------
-- treesitter-textobj
-------------------------
if Installed("nvim-treesitter-textobjects") then
  require("nvim-treesitter.configs").setup({
    textobjects = {
      select = {
        enable = true,
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          -- You can optionally set descriptions to the mappings (used in the desc parameter of
          -- nvim_buf_set_keymap) which plugins like which-key display
          ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
          -- You can also use captures from other query groups like `locals.scm`
          ['al'] = '@loop.outer',
          ['il'] = '@loop.inner',
        },
        selection_modes = {
          ["@parameter.outer"] = "v", -- charwise
          ["@function.outer"] = "V",  -- linewise
          ["@class.outer"] = "<c-v>", -- blockwise
        },
        include_surrounding_whitespace = true,
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["}}"] = "@function.outer",
          ["]]"] = "@class.outer",
          ["]l"] = "@loop.*",
          ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
        },
        -- TODO:  sm to jump up, need to custom queries
        -- https://tree-sitter.github.io/tree-sitter/using-parsers#pattern-matching-with-queries
        goto_previous_start = {
          ["sm"] = { query = { "@block.outer", "@function.outer", "@class.outer" } },
          ["{{"] = "@function.outer",
          ["[["] = "@class.outer",
          ["[l"] = "@loop.*",
          ["[z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
        },
        goto_next_end = {
          ["}]"] = "@function.outer",
          ["]}"] = "@class.outer",
        },
        goto_previous_end = {
          ["{["] = "@function.outer",
          ["[{"] = "@class.outer",
        },
        -- Below will go to either the start or the end, whichever is closer.
        -- Use if you want more granular movements
        -- Make it even more gradual by adding multiple queries and regex.
        goto_next = {
          ["]w"] = "@conditional.outer",
        },
        goto_previous = {
          ["[w"] = "@conditional.outer",
        },
      },
    },
  })
end
-------------------------
-- treesitter-refactor
-------------------------
if Installed("nvim-treesitter-refactor") then
  require 'nvim-treesitter.configs'.setup {
    refactor = {
      highlight_definitions = {
        enable = true,
        clear_on_cursor_move = true,
      },
      highlight_current_scope = { enable = false },
      smart_rename = { enable = false },
      navigation = {
        enable = true,
        keymaps = {
          goto_definition = "sh",
          list_definitions = false,
          list_definitions_toc = false,
          goto_next_usage = "sn",
          goto_previous_usage = "sp",
        },
      },
    },
  }
end
