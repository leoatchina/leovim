-- Neovim-side scheduler for PackAdd deps/init/cfg extensions.
-- vim-plug owns installation; this module only validates and orders loading.

local M = {}

local state = {
  registered = {}, -- name -> { init?: string, cfg?: string, deps: string[], order: number }
  count = 0,
  finished = false,
  groups = nil, -- cfg -> { members = {name,...}, order = number }
  group_order = nil, -- topo-ordered cfg names
  init_state = {}, -- plugin name -> 'done' | 'failed' | 'pending' | 'running'
  cfg_called = {}, -- cfg module -> true once require was attempted
  group_state = {}, -- cfg -> 'done' | 'failed' | 'pending' | 'running'
  init_done = {}, -- plugin name -> true once scripts + init/cfg are complete
  script_loaded = {}, -- plugin name -> true once plugin scripts are ready
}

local function err(fmt, ...)
  error(('pack.lua: ' .. string.format(fmt, ...)), 0)
end

function M.reset()
  state.registered = {}
  state.count = 0
  state.finished = false
  state.groups = nil
  state.group_order = nil
  state.init_state = {}
  state.cfg_called = {}
  state.group_state = {}
  state.init_done = {}
  state.script_loaded = {}
end

local function as_list(v)
  if v == nil then
    return {}
  end
  if type(v) == 'string' then
    return { v }
  end
  if type(v) == 'table' then
    return v
  end
  return nil
end

--- Import one PackAdd extension spec from pack.vim's registry.
local function add_spec(name, extras)
  extras = extras or {}
  local init = extras.init
  if init ~= nil then
    if type(init) ~= 'string' or init == '' then
      err('invalid init for %s: single non-empty Lua statement required', name)
    end
    local compile = loadstring or load
    local chunk, e = compile(init, 'PackAdd init: ' .. name)
    if not chunk then
      err('invalid init for %s: %s', name, tostring(e))
    end
  end
  local cfg = extras.cfg
  if cfg ~= nil and (
      type(cfg) ~= 'string'
      or not cfg:match('^[%w_][%w_.%-]*$')
      or cfg:sub(-1) == '.'
      or cfg:find('..', 1, true)
    ) then
    err('invalid cfg for %s: single Lua module name required', name)
  end
  local deps = as_list(extras.deps)
  if not deps then
    err('invalid deps for %s: string or list of strings required', name)
  end
  for _, d in ipairs(deps) do
    if type(d) ~= 'string' or d == '' then
      err('invalid deps entry for %s', name)
    end
  end
  state.count = state.count + 1
  state.registered[name] = { init = init, cfg = cfg, deps = deps, order = state.count }
end

local function import_specs()
  local specs = vim.g.pack_specs or {}
  local order = vim.g.pack_order or {}
  for _, name in ipairs(order) do
    local spec = specs[name]
    if type(spec) ~= 'table' then
      err('invalid pack.vim spec for %s', name)
    end
    add_spec(name, spec)
  end
end

local function installed(name)
  return vim.fn['pack#installed'](name) == 1
end

local function is_lazy(name)
  return vim.fn['pack#lazy'](name) == 1
end

local function closure_of(name, cache)
  cache = cache or {}
  if cache[name] ~= nil then
    return cache[name]
  end
  cache[name] = {} -- cycle guard during traversal
  local out = {}
  local entry = state.registered[name]
  local seen = {}
  local function add_dep(d)
    if d ~= name and not seen[d] then
      seen[d] = true
      out[#out + 1] = d
      for _, dd in ipairs(closure_of(d, cache)) do
        if not seen[dd] then
          seen[dd] = true
          out[#out + 1] = dd
        end
      end
    end
  end
  if entry then
    for _, d in ipairs(entry.deps) do
      add_dep(d)
    end
  end
  cache[name] = out
  return out
end

local function validate()
  local plugs = vim.g.plugs or {}
  -- missing declarations and self deps
  for name, entry in pairs(state.registered) do
    if plugs[name] == nil then
      err('plugin declaration was not accepted by vim-plug: %s', name)
    end
    for _, d in ipairs(entry.deps) do
      if d == name then
        err('self dependency: %s', name)
      end
      if plugs[d] == nil and state.registered[d] == nil then
        err('missing dependency declaration: %s -> %s', name, d)
      end
    end
  end
  -- plugin-level dependency cycles
  local visiting, done = {}, {}
  local visit
  visit = function(name, path)
    if done[name] then
      return
    end
    if visiting[name] then
      err('dependency cycle: %s -> %s', table.concat(path, ' -> '), name)
    end
    visiting[name] = true
    path[#path + 1] = name
    local entry = state.registered[name]
    if entry then
      for _, d in ipairs(entry.deps) do
        visit(d, path)
      end
    end
    path[#path] = nil
    visiting[name] = nil
    done[name] = true
  end
  local names = vim.tbl_keys(state.registered)
  table.sort(names, function(a, b)
    return state.registered[a].order < state.registered[b].order
  end)
  for _, name in ipairs(names) do
    visit(name, {})
  end
end

local function build_groups()
  local groups = {}
  local order = {}
  for _, name in ipairs((function()
    local ns = vim.tbl_keys(state.registered)
    table.sort(ns, function(a, b)
      return state.registered[a].order < state.registered[b].order
    end)
    return ns
  end)()) do
    local entry = state.registered[name]
    if entry.cfg then
      local g = groups[entry.cfg]
      if not g then
        g = { members = {}, order = entry.order }
        groups[entry.cfg] = g
        order[#order + 1] = entry.cfg
      end
      g.members[#g.members + 1] = name
    end
  end
  -- group edges: group(cfg) waits for groups of cfgs in the transitive deps
  -- of its members, excluding its own group.
  local edges = {} -- cfg -> { dep_cfg = true }
  for cfg, g in pairs(groups) do
    edges[cfg] = {}
    local cache = {}
    for _, member in ipairs(g.members) do
      for _, q in ipairs(closure_of(member, cache)) do
        local qcfg = state.registered[q] and state.registered[q].cfg
        if qcfg and qcfg ~= cfg then
          edges[cfg][qcfg] = true
        end
      end
    end
  end
  -- cross-group init cycles
  local visiting, done = {}, {}
  local visit
  visit = function(cfg, path)
    if done[cfg] then
      return
    end
    if visiting[cfg] then
      err('cross-cfg init cycle: %s -> %s', table.concat(path, ' -> '), cfg)
    end
    visiting[cfg] = true
    path[#path + 1] = cfg
    for dep_cfg in pairs(edges[cfg]) do
      visit(dep_cfg, path)
    end
    path[#path] = nil
    visiting[cfg] = nil
    done[cfg] = true
  end
  table.sort(order)
  for _, cfg in ipairs(order) do
    visit(cfg, {})
  end
  -- topo sort, declaration order as tiebreak
  local sorted, emitted = {}, {}
  local emit
  emit = function(cfg)
    if emitted[cfg] then
      return
    end
    emitted[cfg] = true
    local deps = vim.tbl_keys(edges[cfg])
    table.sort(deps, function(a, b)
      return (groups[a] and groups[a].order or 0) < (groups[b] and groups[b].order or 0)
    end)
    for _, dep_cfg in ipairs(deps) do
      emit(dep_cfg)
    end
    sorted[#sorted + 1] = cfg
  end
  table.sort(order, function(a, b)
    return groups[a].order < groups[b].order
  end)
  for _, cfg in ipairs(order) do
    emit(cfg)
  end
  state.groups = groups
  state.group_order = sorted
end

local function load_plugin(name)
  if state.script_loaded[name] then
    return true
  end
  local ok, e = pcall(vim.fn['pack#load_raw'], name)
  if not ok then
    err('pack#load failed for %s: %s', name, tostring(e))
  end
  state.script_loaded[name] = true
  return true
end

local run_group

local function execute_init(name, entry)
  if not entry.init or state.init_state[name] == 'done' then
    return true
  end
  local compile = loadstring or load
  local chunk, compile_error = compile(entry.init, 'PackAdd init: ' .. name)
  if not chunk then
    state.init_state[name] = 'failed'
    vim.notify(('pack.lua: init for %s failed: %s'):format(name, tostring(compile_error)), vim.log.levels.ERROR)
    return false
  end
  local ok, e = pcall(chunk)
  state.init_state[name] = ok and 'done' or 'failed'
  if not ok then
    vim.notify(('pack.lua: init for %s failed: %s'):format(name, tostring(e)), vim.log.levels.ERROR)
  end
  return ok
end

local function ensure_node(name, current_cfg)
  if state.init_done[name] or state.init_state[name] == 'done' then
    return true
  end
  local entry = state.registered[name]
  if state.init_state[name] == 'failed' then
    return false
  end
  if state.init_state[name] == 'running' then
    err('initialization re-entry: %s', name)
  end
  if not installed(name) then
    state.init_state[name] = 'pending'
    return false
  end
  if entry and entry.cfg and entry.cfg ~= current_cfg then
    run_group(entry.cfg)
    return state.init_done[name] == true
  end
  state.init_state[name] = 'running'
  if entry then
    for _, dependency in ipairs(entry.deps) do
      if not ensure_node(dependency, current_cfg) then
        state.init_state[name] = 'pending'
        return false
      end
    end
  end
  load_plugin(name)
  if entry and not execute_init(name, entry) then
    return false
  end
  state.init_state[name] = 'done'
  if not entry or not entry.cfg then
    state.init_done[name] = true
  end
  return true
end

run_group = function(cfg)
  if state.cfg_called[cfg] then
    return state.group_state[cfg] == 'done'
  end
  if state.group_state[cfg] == 'failed' then
    return false
  end
  if state.group_state[cfg] == 'running' then
    err('cfg re-entry: %s', cfg)
  end
  local group = state.groups[cfg]
  if not group then
    err('unknown cfg group: %s', cfg)
  end
  state.group_state[cfg] = 'running'
  for _, member in ipairs(group.members) do
    if not ensure_node(member, cfg) then
      state.group_state[cfg] = state.init_state[member] == 'failed' and 'failed' or 'pending'
      return false
    end
  end
  state.cfg_called[cfg] = true
  local ok, e = pcall(require, cfg)
  state.group_state[cfg] = ok and 'done' or 'failed'
  if not ok then
    vim.notify(('pack.lua: cfg %s failed: %s'):format(cfg, tostring(e)), vim.log.levels.ERROR)
  end
  for _, member in ipairs(group.members) do
    state.init_done[member] = ok
    state.init_state[member] = ok and 'done' or 'failed'
  end
  return ok
end

local function request_one(name)
  if not vim.g.plugs or vim.g.plugs[name] == nil then
    err('unknown plugin request: %s', name)
  end
  return ensure_node(name, nil)
end

function M.load_request(names)
  if not state.finished then
    err('load request before pack plan is finished')
  end
  if type(names) == 'string' then
    names = { names }
  end
  if type(names) ~= 'table' then
    err('load request must be a plugin name or list')
  end
  local ok, e = pcall(function()
    for _, name in ipairs(names) do
      if not request_one(name) then
        err('plugin is not ready: %s', name)
      end
    end
  end)
  if not ok then
    vim.notify(tostring(e), vim.log.levels.ERROR)
    return false
  end
  return true
end

local function run_startup()
  local names = vim.tbl_keys(state.registered)
  table.sort(names, function(a, b)
    return state.registered[a].order < state.registered[b].order
  end)
  for _, name in ipairs(names) do
    if not is_lazy(name) then
      request_one(name)
    end
  end
end

-- Startup plugins are already loaded by plug#end. Lazy roots wait for a
-- command, FileType, explicit request, or a non-lazy dependency.
local function mark_plugin_scripts(name)
  if installed(name) and not is_lazy(name) then
    state.script_loaded[name] = true
  end
end

--- Freeze the plan, then run only startup roots after plugin scripts load.
--- Called from init.vim right after plug#end().
function M.finish()
  if state.finished then
    return
  end
  state.finished = true
  import_specs()
  local names = vim.tbl_keys(state.registered)
  table.sort(names, function(a, b)
    return state.registered[a].order < state.registered[b].order
  end)
  validate()
  build_groups()
  for _, name in ipairs(names) do
    mark_plugin_scripts(name)
  end
  if vim.v.vim_did_enter == 1 then
    run_startup()
  else
    vim.api.nvim_create_autocmd('VimEnter', {
      once = true,
      callback = run_startup,
    })
  end
end

function M.status()
  return {
    finished = state.finished,
    groups = state.groups,
    group_order = state.group_order,
    group_state = state.group_state,
    cfg_called = state.cfg_called,
    init_state = state.init_state,
    init_done = state.init_done,
    script_loaded = state.script_loaded,
  }
end


return M
