local map = vim.keymap.set
-------------------------
-- nvim-treesitter (main branch, incompatible rewrite)
-- master 的 configs.setup 模块系统已删除；高亮/折叠/缩进/增量选区
-- 分别由 FileType 自动命令、vim.treesitter 核心接口与本地实现接管
-------------------------
local install_dir = vim.fn.expand("~/.leovim.d/treesitter")
require("nvim-treesitter").setup({
  install_dir = install_dir,
})
vim.opt.runtimepath:prepend(install_dir)
-- main branch install() no-ops when parser/<lang>.so already exists, which
-- leaves setups migrated from master without query files (and therefore
-- without highlighting: vim.treesitter.start() disables regex syntax).
-- Force-install any language whose parser OR query dir is missing.
local missing = vim.tbl_filter(function(lang)
  return vim.fn.filereadable(install_dir .. '/parser/' .. lang .. '.so') == 0
      or vim.uv.fs_stat(install_dir .. '/queries/' .. lang) == nil
end, {
  'python', 'vimdoc', 'markdown', 'markdown_inline',
  'java', 'javadoc', 'r', 'c', 'cpp', 'rust', 'typescript', 'javascript',
})
if #missing > 0 then
  require("nvim-treesitter").install(missing, { force = true })
end
-- highlight + fold + indent, skip files > 1MB
-- vim.treesitter.start() disables regex syntax highlighting by default;
-- re-enable it after start to keep the old additional_vim_regex_highlighting
-- layering (TS captures + $VIMRUNTIME syntax on top)
vim.api.nvim_create_autocmd("FileType", {
  desc = "treesitter highlight/fold/indent",
  callback = function(args)
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
    if ok and stats and stats.size > 1024 * 1024 then
      return
    end
    if not pcall(vim.treesitter.start, args.buf) then
      return
    end
    vim.bo[args.buf].syntax = 'ON'
    vim.wo[0][0].foldmethod = 'expr'
    vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
map("n", "<M-l>U", ":TSUpdate ", { noremap = true, silent = false })
map("n", "<M-l>I", ":TSInstall ", { noremap = true, silent = true })
-------------------------
-- incremental selection (replaces removed master module)
-- <M-s> start(normal)/expand(visual), <Tab> expand, <M-S> shrink
-- TSNode userdata cannot be stored in vim.b (not convertible to Vim types),
-- keep per-buffer stacks in a script-local table instead
local sel_stacks = {}
vim.api.nvim_create_autocmd('BufWipeout', {
  callback = function(args)
    sel_stacks[args.buf] = nil
  end,
})
local function select_node(node)
  local sr, sc, er, ec = node:range()
  vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
  vim.cmd('normal! v')
  vim.api.nvim_win_set_cursor(0, { er + 1, math.max(ec - 1, sc) })
end
local function init_selection()
  local node = vim.treesitter.get_node({ ignore_injections = false })
  if not node then
    return
  end
  sel_stacks[vim.api.nvim_get_current_buf()] = { node }
  select_node(node)
end
local function node_incremental()
  local buf = vim.api.nvim_get_current_buf()
  local stack = sel_stacks[buf] or {}
  local node = stack[#stack] or vim.treesitter.get_node({ ignore_injections = false })
  if not node then
    return
  end
  node = node:parent()
  if not node then
    return
  end
  stack[#stack + 1] = node
  sel_stacks[buf] = stack
  select_node(node)
end
local function node_decremental()
  local buf = vim.api.nvim_get_current_buf()
  local stack = sel_stacks[buf] or {}
  if #stack <= 1 then
    sel_stacks[buf] = nil
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
    return
  end
  table.remove(stack)
  sel_stacks[buf] = stack
  select_node(stack[#stack])
end
map('n', '<M-s>', init_selection, { silent = true })
map('x', '<M-s>', node_incremental, { silent = true })
map('x', '<Tab>', node_incremental, { silent = true })
map('x', '<M-S>', node_decremental, { silent = true })
-------------------------
-- treesitter-textobjects (main branch: setup carries options only,
-- keymaps are plain vim.keymap.set calls into select/move modules)
-- ;f ;c ;z ;F ;C ;o  ,f ,c ,z ,F ,C ,o  su  af/if/ac/ic/aL/iL
-- (;l ,l 循环跳转按约定不再迁移)
-------------------------
require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
    selection_modes = {
      ["@parameter.outer"] = "v",
      ["@function.outer"] = "V",
      ["@class.outer"] = "<c-v>",
    },
    include_surrounding_whitespace = true,
  },
  move = {
    set_jumps = true,
  },
})
local ts_select = require("nvim-treesitter-textobjects.select")
local ts_move = require("nvim-treesitter-textobjects.move")
local function sel(key, query, desc)
  map({ "x", "o" }, key, function()
    ts_select.select_textobject(query, "textobjects")
  end, { silent = true, desc = desc })
end
local function mv(key, fn, query, opts)
  opts = opts or {}
  map({ "n", "x", "o" }, key, function()
    ts_move[fn](query, opts.group or "textobjects")
  end, { silent = true, desc = opts.desc })
end
sel("af", "@function.outer", "Select around function")
sel("if", "@function.inner", "Select inside function")
sel("ac", "@class.outer", "Select around class")
sel("ic", "@class.inner", "Select inside class")
sel("aL", "@loop.outer", "Select around loop")
sel("iL", "@loop.inner", "Select inside loop")
mv(";z", "goto_next_start", "@fold", { group = "folds", desc = "Next fold start" })
mv(",z", "goto_previous_start", "@fold", { group = "folds", desc = "Prev fold start" })
mv(";f", "goto_next_start", "@function.outer", { desc = "Next function start" })
mv(",f", "goto_previous_start", "@function.outer", { desc = "Prev function start" })
mv(";F", "goto_next_end", "@function.outer", { desc = "Next function end" })
mv(",F", "goto_previous_end", "@function.outer", { desc = "Prev function end" })
mv(";c", "goto_next_start", "@class.outer", { desc = "Next class start" })
mv(",c", "goto_previous_start", "@class.outer", { desc = "Prev class start" })
mv(";C", "goto_next_end", "@class.outer", { desc = "Next class end" })
mv(",C", "goto_previous_end", "@class.outer", { desc = "Prev class end" })
mv(";o", "goto_previous", "@conditional.outer", { desc = "Prev conditional" })
mv(",o", "goto_next", "@conditional.outer", { desc = "Next conditional" })
map({ "n", "x", "o" }, "su", function()
  ts_move.goto_previous_start({ "@block.outer", "@function.outer", "@class.outer" }, "textobjects")
end, { silent = true, desc = "Prev block/function/class start" })
-------------------------
-- hlargs
-------------------------
require("hlargs").setup({
  hl_priority = 1024 * 16
})
-------------------------
-- flash treesitter
-------------------------
map({ 'n', 'x', 'o' }, 'sv', function() require("flash").treesitter() end, { noremap = true, silent = true })
map({ 'x', 'o' }, 'm', function() require("flash").treesitter_search() end, { noremap = true, silent = true })
-------------------------
-- treesitter-context
-------------------------
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"toml", "json", "yaml"},
  callback = function()
    require'treesitter-context'.setup({})
  end,
  once = true,
})
