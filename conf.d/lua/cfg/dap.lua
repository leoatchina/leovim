---------------------
-- dap
---------------------
local dap = require("dap")
local dapui = require("dapui")
local api = vim.api
local fn = vim.fn
dap.defaults.fallback.exception_breakpoints = { 'default' }
dap.defaults.python.exception_breakpoints = { 'uncaught' }
fn.sign_define('DapBreakpoint', { text = '🛑', texthl = '', linehl = '', numhl = '' })
-------------------------------------
-- function get_mason_adapter
-------------------------------------
require("mason-nvim-dap").setup({
  ensure_installed = { "python" },
  automatic_installation = true,
  handlers = {
    function(config)
      require('mason-nvim-dap').default_setup(config)
    end
  }
})
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
vim.keymap.set({"n", "x"}, "<M-m><M-m>",
  function()
    dapui_toggle()
  end, { noremap = true, silent = true }
)
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
-------------------------------------
-- load dap_json, modified from dap.ext.vscode.lauchjs
-------------------------------------
local function load_json(dap_json)
  local vscode = require "dap.ext.vscode"
  local type_to_filetypes = vscode.type_to_filetypes
  local configurations = vscode.getconfigs(dap_json)
  -- init dap_configurations
  local dap_config_inited = false
  assert(configurations, "launch.json must have a 'configurations' key")
  for _, config in ipairs(configurations) do
    assert(config.type, "Configuration in launch.json must have a 'type' key")
    assert(config.name, "Configuration in launch.json must have a 'name' key")
    local filetypes = type_to_filetypes[config.type] or { config.type, }
    for _, filetype in pairs(filetypes) do
      if not dap_config_inited then
        dap.configurations[filetype] = {}
        dap_config_inited = true
      end
      -- remove old value
      for i, dap_config in pairs(dap.configurations[filetype] ) do
        if dap_config.name == config.name then
          table.remove(dap.configurations[filetype] , i)
        end
      end
      table.insert(dap.configurations[filetype], config)
    end
  end
end
local function dap_run(dap_json, run, run_to_cursor)
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
      ok, _ = pcall(load_json, dap_json)
      if ok then
        if run_to_cursor then
          dap.clear_breakpoints()
          dap.set_breakpoint()
        end
        ok, _ = pcall(dap.continue)
      end
    end
  else
    ok, _ = pcall(load_json, dap_json)
  end
  return ok
end
function _G.DapContinue(json)
  local dap_json = json and fn.filereadable(json) > 0 or (fn.GetRootDir() .. '/.vim/dap.json')
  return dap_run(dap_json, true, false)
end
function _G.DapRunToCusor(json)
  local dap_json = json and fn.filereadable(json) > 0 or (fn.GetRootDir() .. '/.vim/dap.json')
  return dap_run(dap_json, true, true)
end
function _G.DapLoadConfig(json)
  local dap_json = json and fn.filereadable(json) > 0 or (fn.GetRootDir() .. '/.vim/dap.json')
  return dap_run(dap_json, false, false)
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
		bufnr = vim.api.nvim_get_current_buf(),
		line = vim.api.nvim_win_get_cursor(0)[1],
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
---------------------------------
-- daptab, auto open/close/load dapui in tab
-- https://github.com/przepompownia/nvim-dap-tab/blob/master/lua/dap-tab/init.lua
---------------------------------
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
local function close_dap(close)
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
  close_dap(true)
end
function _G.DapClose()
  close_dap(false)
end