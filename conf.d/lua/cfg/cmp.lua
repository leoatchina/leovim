-- basic setup
local MAX_LABEL_WIDTH = 32
local ELLIPSIS_CHAR = '...'
local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end
local get_ws = function(max, len)
  return (" "):rep(max - len)
end
-----------------
-- cmp config
-----------------
local unpack = table.unpack or unpack
local fn = vim.fn
local cmp = require('cmp')
local compare = cmp.config.compare
local keymap = require('cmp.utils.keymap')
local lspkind = require('lspkind')
local sources = {
  { name = 'nvim_lua', priority = 32 },
  { name = 'dictionary', priority = 16 },
  { name = 'vsnip', priority = 8 },
  { name = 'nvim_lsp', priority = 4 },
  { name = 'buffer', priority = 2 },
  { name = 'async-path', priority = 1 },
}
if Installed('jupynium.nvim') then
  table.insert(sources, 1, { name = 'jupynium', priority = 64})
end
-----------------
-- setup
-----------------
cmp.setup({
  sources = sources,
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end
  },
  sorting = {
    priority_weight = 1.0,
    comparators = {
      compare.score,
      compare.recently_used,
      compare.locality,
      compare.kind,
      compare.order,
      compare.offset,
      compare.exact,
      compare.sort_text,
      compare.length,
    }
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping({
    -- cmdline only mapping
    ['<C-j>'] = {
      c = function(fallback)
        if cmp.visible() then
          cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
        else
          fallback()
        end
      end,
    },
    ['<C-k>'] = {
      c = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
        else
          fallback()
        end
      end,
    },
    -- insert mapping
    ['<C-n>'] = {
      i = function(fallback)
        if cmp.visible() then
          cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
        else
          fallback()
        end
      end,
    },
    ['<C-p>'] = {
      i = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
        else
          fallback()
        end
      end,
    },
    -- Up down in inseat/cmdline
    ['<Down>'] = {
      i = function(fallback)
        if cmp.visible() then
          cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
        else
          fallback()
        end
      end,
      c = function(fallback)
        if cmp.visible() then
          cmp.close()
        else
          fallback()
        end
      end,
    },
    ['<Up>'] = {
      i = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
        else
          fallback()
        end
      end,
      c = function(fallback)
        if cmp.visible() then
          cmp.abort()
        else
          fallback()
        end
      end,
    },
    -- others
    ['<C-e>'] = {
      i = function()
        if cmp.visible() then
          cmp.abort()
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-o>A', true, false, true), 'i', true)
        end
      end,
      c = cmp.mapping.abort(),
    },
    ['<C-y>'] = {
      i = function()
        if cmp.visible() then
          cmp.close()
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-y>"', true, false, true), 'i', true)
        end
      end,
      c = cmp.mapping.close(),
    },
    ['<Cr>'] = {
      i = function(fallback)
        if cmp.visible() then
          cmp.close()
        else
          fallback()
        end
      end,
      c = cmp.confirm()
    },
    ['<S-Tab>'] = {
      i = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
        else
          fallback()
        end
      end,
      c = function()
        if cmp.visible() then
          cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
        else
          cmp.complete()
        end
      end,
    },
    ['<Tab>'] = {
      i = function(fallback)
        if cmp.visible() then
          if cmp.get_selected_entry() then
            cmp.confirm()
          else
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
          end
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end,
      c = function(fallback)
        if cmp.visible() then
          cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
        elseif has_words_before() then
          cmp.complete()
        elseif vim.fn.pumvisible() == 0 then
          vim.api.nvim_feedkeys(keymap.t('<C-z>'), 'in', true)
        else
          fallback()
        end
      end,
      s = function(fallback)
        if Installed('vim-vsnip') then
          vim.fn['vsnip#expand']()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end,
    }
  }),
  -- 使用lspkind-nvim显示类型图标
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol',
      max = {
        -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
        -- can also be a function to dynamically calculate max width such as
        -- menu = function() return math.floor(0.45 * vim.o.columns) end,
        menu = MAX_LABEL_WIDTH, -- leading text (labelDetails)
        abbr = MAX_LABEL_WIDTH, -- actual suggestion item
      },
      ellipsis_char = ELLIPSIS_CHAR,
      show_labelDetails = true,
      before = function(entry, vim_item)
        -- colorful-menu
        local highlights_info = require("colorful-menu").cmp_highlights(entry)
        -- if highlight_info==nil, which means missing ts parser, let's fallback to use default `vim_item.abbr`.
        -- What this plugin offers is two fields: `vim_item.abbr_hl_group` and `vim_item.abbr`.
        local content
        if highlights_info ~= nil then
          vim_item.abbr_hl_group = highlights_info.highlights
          content = highlights_info.text
        else
          content = vim_item.abbr
        end
        -- Source 显示提示来源
        if #content > MAX_LABEL_WIDTH then
          vim_item.abbr = fn.strcharpart(content, 0, MAX_LABEL_WIDTH) .. ELLIPSIS_CHAR
        else
          vim_item.abbr = content .. get_ws(MAX_LABEL_WIDTH, #content)
        end
        vim_item.menu = "[" .. string.upper(entry.source.name) .. "]"
        return vim_item
      end
    })
  }
})
----------------------------------
-- cmdline
----------------------------------
cmp.setup.cmdline({'/', '?'}, {
  sources = {
    { name = "buffer" },
  },
})
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})
----------------------------------
-- gitcommit
----------------------------------
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'git' },
  }, {
    { name = 'buffer' },
  })
})
---------------------------
-- autopairs
---------------------------
if Installed('nvim-autopairs') then
  local autopairs = require("nvim-autopairs")
  autopairs.setup({
    disable_filetype = {},
  })
  local cmp_autopairs = require('nvim-autopairs.completion.cmp')
  cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
  )
end
