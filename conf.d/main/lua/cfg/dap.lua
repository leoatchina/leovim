---------------------
-- dap
---------------------
local vscode = require("dap.ext.vscode")
local dapui  = require("dapui")
local dap    = require("dap")
local utils  = require('utils')
local keymap = vim.keymap
local api    = vim.api
local fn     = vim.fn
dap.defaults.fallback.exception_breakpoints = { 'default' }
dap.defaults.python.exception_breakpoints = { 'uncaught' }
fn.sign_define('DapBreakpoint', { text = '🛑', texthl = '', linehl = '', numhl = '' })
-------------------------------------
-- mason
-------------------------------------
require("mason-nvim-dap").setup({
  ensure_installed = { "bash" },
  handlers = {
    function(config)
      require('mason-nvim-dap').default_setup(config)
    end
  }
})
------------------------------------------------------------
-- 配置调试适配
------------------------------------------------------------
local mason_dir = fn.expand("~/.leovim.d/mason")
local cmp_dir = mason_dir .. "/cmp"
local blink_dir = mason_dir .. "/blink"
if fn.isdirectory(cmp_dir) == 1 then
  mason_dir = cmp_dir
elseif fn.isdirectory(blink_dir) == 1 then
  mason_dir = blink_dir
end
-- bash
local bash_debug_adapter = mason_dir .. "/bin/bash-debug-adapter"
local bashdb_dir = mason_dir .. "/packages/bash-debug-adapter/extension/bashdb_dir"
dap.adapters.bashdb = {
  type = "executable";
  command = bash_debug_adapter;
  name = "bashdb";
}
dap.configurations.sh = {
  {
    type = "bashdb",
    name = "Launch Bash debugger",
    request = "launch",
    showDebugOutput = true,
    trace = true,
    pathBashdb = bashdb_dir .. "/bashdb",
    pathBashdbLib = bashdb_dir,
    pathBash = "bash",
    pathCat = "cat",
    pathMkfifo = "mkfifo",
    pathPkill = "pkill",
    file = "${file}",
    program = "${file}",
    cwd = "${workspaceFolder}",
    argsString = '',
    args = {},
    env = {},
    console = "integratedTerminal",
    terminalKind = "integrated",
  }
}
-- python
dap.adapters.python = {
  type = 'executable';
  command = vim.g.python_prog;
  args = { '-m', 'debugpy.adapter' };
}
vim.g.dap_adapters = dap.adapters
------------------------------------------------------------
-- load dap_json, modified from dap.ext.vscode.lauchjs
------------------------------------------------------------
local function load_json(dap_json)
  local cur_filetype = vim.bo.filetype
  local type_to_filetypes = vscode.type_to_filetypes

  -- 保存当前文件类型的默认配置
  local default_config = dap.configurations[cur_filetype]

  -- 尝试读取 JSON 配置
  local ok, configurations = pcall(vscode.getconfigs, dap_json)
  if not ok or not configurations then
    -- 读取失败或没有配置，使用默认配置
    vim.notify("Failed to load dap.json, using default config", vim.log.levels.WARN)
    return
  end

  -- 使用表来跟踪已初始化的文件类型
  local dap_configed = {}

  for _, config in ipairs(configurations) do
    if not config.name or not config.type then
      goto continue
    end

    local filetypes = type_to_filetypes[config.type] or { cur_filetype, }
    for _, filetype in pairs(filetypes) do
      if not dap_configed[filetype] then
        -- do not use default config
        dap.configurations[filetype] = {}
        dap_configed[filetype] = true
      end
      -- remove old value, 只用新的配置
      for i, dap_config in pairs(dap.configurations[filetype] ) do
        if dap_config.name == config.name then
          table.remove(dap.configurations[filetype] , i)
        end
      end
      table.insert(dap.configurations[filetype], config)
    end
    ::continue::
  end
  -- 如果 JSON 中没有当前文件类型的配置，恢复默认配置
  if not dap.configurations[cur_filetype] and default_config then
    dap.configurations[cur_filetype] = default_config
  end
end
local function dap_load_run(json_file, run, run_to_cursor)
  local ok = false
  run = run or false
  run_to_cursor = run_to_cursor or false
  if run then
    if dap.session() ~= nil then
      if run_to_cursor then
        ok, _ = pcall(dap.run_to_cursor)
      else
        ok, _ = pcall(dap.continue)
      end
    else
      ok, _ = pcall(load_json, json_file )
      if ok then
        if run_to_cursor then
          dap.clear_breakpoints()
          dap.set_breakpoint()
        end
        ok, _ = pcall(dap.continue)
      end
    end
  else
    ok, _ = pcall(load_json, json_file)
  end
  return ok
end
local function get_json_file(json_file)
  local json_file = json_file or utils.get_root_dir() .. '/.vim/dap.json'
  if fn.filereadable(json_file) then
    return json_file
  else
    return nil
  end
end
function _G.DapRunToCusor(json_file)
  local json_file = get_json_file(json_file)
  if json_file then
    ok = dap_load_run(json_file, true, true)
  else
    ok, _ = pcall(dap.run_to_cursor)
  end
  if not ok then
    DapReset()
  end
end
function _G.DapContinue(json_file)
  local json_file = get_json_file(json_file)
  if json_file then
    ok = dap_load_run(json_file, true, false)
  else
    ok, _ = pcall(dap.continue)
  end
  if not ok then
    DapReset()
  end
end
function _G.DapLoadConfig(json_file)
  local json_file = get_json_file(json_file)
  if json_file then
    ok = dap_load_run(json_file, false, false)
  else
    ok = false
  end
  if not ok then
    DapReset()
  end
end
function _G.DapPause()
  require"dap".pause()
end
---------------------------------
-- breakpoints
---------------------------------
---@param dir "next"|"prev"
local function goto_breakpoint(dir)
	local breakpoints = require("dap.breakpoints").get()
	if #breakpoints == 0 then
		vim.notify("No breakpoints set", vim.log.levels.WARN)
		return
	end
	local points = {}
	for bufnr, buffer in pairs(breakpoints) do
		for _, point in ipairs(buffer) do
			table.insert(points, { bufnr = bufnr, line = point.line })
		end
	end
	local current = {
		bufnr = api.nvim_get_current_buf(),
		line = api.nvim_win_get_cursor(0)[1],
	}
	local nextPoint
	for i = 1, #points do
		local isAtBreakpointI = points[i].bufnr == current.bufnr and points[i].line == current.line
		if isAtBreakpointI then
			local nextIdx = dir == "next" and i + 1 or i - 1
			if nextIdx > #points then nextIdx = 1 end
			if nextIdx == 0 then nextIdx = #points end
			nextPoint = points[nextIdx]
			break
		end
	end
	if not nextPoint then nextPoint = points[1] end
	vim.cmd(("buffer +%s %s"):format(nextPoint.line, nextPoint.bufnr))
end
function _G.DapBreakpointNext()
  goto_breakpoint('next')
end
function _G.DapBreakpointPrev()
  goto_breakpoint('prev')
end
---------------------
-- layouts
---------------------
local layouts = {
  {
    elements = {
      { id = "scopes",  size = 0.5 },
      { id = "watches", size = 0.3 },
      { id = "stacks",  size = 0.2 },
    },
    size = 0.2,
    position = "top",
  },
  {
    elements = {
      { id = "scopes",  size = 0.5 },
      { id = "watches", size = 0.3 },
      { id = "stacks",  size = 0.2 },
    },
    size = 0.25,
    position = "left",
  },
  --  console / breakpoints on bottom
  {
    elements = {
      { id = "console",     size = 0.7 },
      { id = "breakpoints", size = 0.3 },
    },
    size = 0.2,
    position = "bottom",
  },
}
local function dapui_toggle(open)
  local ok, result = pcall(function() return open > 0 end)
  if not ok then
    open = false
  else
    open = result
  end
  local windows = require("dapui.windows")
  -- width > height
  if api.nvim_get_option("columns") > api.nvim_get_option("lines") * 3 then
    if windows.layouts[1]:is_open() or open then
      dapui.close()
      dapui.open(2)
      dapui.open(3)
    else
      dapui.toggle(2)
      dapui.toggle(3)
    end
  else
    if windows.layouts[2]:is_open() or open then
      dapui.close()
      dapui.open(1)
      dapui.open(3)
    else
      dapui.toggle(1)
      dapui.toggle(3)
    end
  end
end
keymap.set({"n", "x"}, "<M-m><M-m>",
  function()
    dapui_toggle()
  end, { noremap = true, silent = true }
)
-- 打开 dapui
function _G.DapUIOpen()
  local windows = require("dapui.windows")
  -- 根据屏幕宽高比选择合适的布局
  if api.nvim_get_option("columns") > api.nvim_get_option("lines") * 3 then
    dapui.open(2)
    dapui.open(3)
  else
    dapui.open(1)
    dapui.open(3)
  end
end
-- 关闭 dapui
function _G.DapUIClose()
  dapui.close()
end
keymap.set({"n", "x"}, "<M-m>o", [[<Cmd>lua DapUIOpen()<Cr>]],  { noremap = true, silent = true })
keymap.set({"n", "x"}, "<M-m>q", [[<Cmd>lua DapUIClose()<Cr>]], { noremap = true, silent = true })
---------------------
-- dapui
---------------------
dapui.setup({
  -- Expand lines larger than the window
  expand_lines = true,
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "<Space>" },
    open = "<Cr>",
    remove = "x",
    edit = "e",
    repl = "r",
    toggle = "t",
  },
  layouts = layouts,
  controls = {
    element = "repl",
    enabled = true,
  },
  floating = {
    mappings = {
      close = { "<Esc>", "<M-q>", "<C-c>", "q" },
    },
  },
})
---------------------------------------------------------------------------------------------
-- daptab, auto open/close/load dapui in tab
-- XXX: https://github.com/przepompownia/nvim-dap-tab/blob/master/lua/dap-tab/init.lua
---------------------------------------------------------------------------------------------
local debugWinId = nil
local function daptab_exists()
  if nil ~= debugWinId and api.nvim_win_is_valid(debugWinId) then
    api.nvim_set_current_win(debugWinId)
    return true
  end
end
local function daptab_thread()
  if daptab_exists() then
    return
  end
  vim.cmd.tabedit '%'
  vim.wo.scrolloff = 10
  debugWinId = fn.win_getid()
  dapui_toggle(1)
end
-- register event
dap.listeners.before.pause.dap_tab = daptab_thread
dap.listeners.before.launch.dap_tab = daptab_thread
dap.listeners.before.continue.dap_tab = daptab_thread
dap.listeners.before.event_stopped.dap_tab = daptab_thread
dap.listeners.before.event_invalidated.dap_tab = daptab_thread
dap.listeners.before.event_terminated.dapui_config = function()
  dap.repl.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dap.repl.close()
end
-- close tab
local function dap_reset_close(close)
  local closetab = close or false
  pcall(dap.repl.close)
  pcall(dap.disconnect)
  pcall(dap.close)
  if nil ~= debugWinId and closetab then
    pcall(dapui.close)
    local tabNr = api.nvim_tabpage_get_number(api.nvim_win_get_tabpage(debugWinId))
    vim.cmd.tabclose(tabNr)
    debugWinId = nil
    vim.notify('DapTab Closed.')
  else
    vim.notify('Dap Closed.')
  end
end
function _G.DapReset()
  dap_reset_close(true)
end
function _G.DapClose()
  dap_reset_close(false)
end
