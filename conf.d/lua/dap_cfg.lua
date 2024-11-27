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
      { id = "repl",    size = 0.05 },
      { id = "scopes",  size = 0.45 },
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
    size = 0.25,
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
---------------------
-- dap-virtual-text
---------------------
if Installed('nvim-dap-virtual-text') then
  require("nvim-dap-virtual-text").setup({
    virt_lines = true,
    commented = true
  })
  vim.keymap.set("n", "<F1>",
    [[<Cmd>DapVirtualTextToggle<Cr>]],
    { noremap = true, silent = false }
  )
end
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
-------------------------------------
-- load launchjs
-------------------------------------
local function load_json(dap_json)
  local ok, _ = pcall(require "dap.ext.vscode".load_launchjs, dap_json)
  return ok
end
local function load_json_run(dap_json, run)
  local ok = false
  run = run or false
  if run then
    if nil == dap.session() then
      ok = load_json(dap_json)
      if ok then
        vim.notify(dap_json .. ' loaded.')
        ok, _ = pcall(dap.continue)
      else
        vim.notify(dap_json .. ' not loaded.')
      end
    else
      ok, _ = pcall(dap.continue)
    end
  else
    ok = load_json(dap_json)
    if not ok then
      vim.notify(dap_json .. ' not loaded.')
    end
  end
  return ok
end
function _G.DapContinue(json)
  local dap_json = json and fn.filereadable(json) > 0 or (fn.GetRootDir() .. '/.vim/dap.json')
  return load_json_run(dap_json, true)
end
function _G.DapLoad(json)
  local dap_json = json and fn.filereadable(json) > 0 or (fn.GetRootDir() .. '/.vim/dap.json')
  return load_json_run(dap_json, false)
end
---------------------------------
-- jump between break point
---------------------------------
---@param dir "next"|"prev"
local function gotoBreakpoint(dir)
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
  gotoBreakpoint('next')
end
function _G.DapBreakpointPrev()
  gotoBreakpoint('prev')
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
