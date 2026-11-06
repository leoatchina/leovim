-- Lua owns declaration validation, dependency/config ordering, init and startup.
-- pack.vim remains the source of truth for installation and script loading.
--
-- pack#end() calls prepare() before Vim preloads/plug#end(), then finish().
-- prepare() validates snapshots and listens only for managed `for` User events;
-- it never runs user init/config. finish() drains queued events and schedules startup.
-- `ready` means scripts/init succeeded but the shared Lua group is still pending.
-- Missing plugins/dependencies can retry; failed init/require are session-terminal.
-- reset() clears PackLua callbacks and execution state, not Lua's require cache.

local M = {}

-- State and declaration snapshots.
local function new_state()
  return {
    prepared = false,
    finished = false,
    specs = {}, -- declaration snapshots, not script/installation truth
    order = {},
    lazy = {},
    groups = nil, -- cfg -> { members = { name, ... }, order = number }
    group_order = nil,
    compiled_inits = {},
    node_state = {}, -- plugin -> pending | running | ready | done | failed
    group_state = {}, -- cfg -> pending | running | done | failed
    native_pending = {}, -- ordered User events received before finish()
    native_seen = {}, -- deduplicate only the pending event queue
  }
end

local state = new_state()

local function err(fmt, ...)
  error(('pack.lua: ' .. string.format(fmt, ...)), 0)
end

local function get_spec(name)
  return state.specs[name]
end

local function deps_of(name)
  local entry = get_spec(name)
  if not entry or entry.deps == nil then
    return {}
  end
  local deps = entry.deps
  if type(deps) ~= 'table' then
    err('invalid deps for %s: string or list of strings required', name)
  end
  return deps
end

local function installed(name)
  return vim.fn['pack#installed_cached'](name) == 1
end

local function lazy(name)
  return state.lazy[name] == 1
end

-- Declaration validation.
local function validate_entry(name, entry, plugs)
  if type(entry) ~= 'table' then
    err('invalid pack.vim spec for %s', name)
  end
  if plugs[name] == nil then
    err('plugin declaration was not accepted by vim-plug: %s', name)
  end
  if entry.init ~= nil then
    if type(entry.init) ~= 'string' or entry.init == '' then
      err('invalid init for %s: single non-empty Lua statement required', name)
    end
    local compile = loadstring or load
    local chunk, compile_error = compile(entry.init, 'PackAdd init: ' .. name)
    if not chunk then
      err('invalid init for %s: %s', name, tostring(compile_error))
    end
    state.compiled_inits[name] = chunk
  end
  if entry.lua ~= nil and (
      type(entry.lua) ~= 'string'
      or not entry.lua:match('^[%w_][%w_.%-]*$')
      or entry.lua:sub(-1) == '.'
      or entry.lua:find('..', 1, true)
    ) then
    err('invalid lua for %s: single Lua module name required', name)
  end
  local deps = deps_of(name)
  for _, dependency in ipairs(deps) do
    if type(dependency) ~= 'string' or dependency == '' then
      err('invalid deps entry for %s', name)
    end
    if dependency == name then
      err('self dependency: %s', name)
    end
    if plugs[dependency] == nil and get_spec(dependency) == nil then
      err('missing dependency declaration: %s -> %s', name, dependency)
    end
  end
end

local function validate()
  local plugs = vim.g.plugs or {}
  for _, name in ipairs(state.order) do
    validate_entry(name, get_spec(name), plugs)
  end

  local visiting, done = {}, {}
  local function visit(name, path)
    if done[name] then
      return
    end
    if visiting[name] then
      err('dependency cycle: %s -> %s', table.concat(path, ' -> '), name)
    end
    visiting[name] = true
    path[#path + 1] = name
    for _, dependency in ipairs(deps_of(name)) do
      visit(dependency, path)
    end
    path[#path] = nil
    visiting[name] = nil
    done[name] = true
  end
  for _, name in ipairs(state.order) do
    visit(name, {})
  end
end

-- Stable dependency and configuration-group ordering.
local function dependency_closure(name, cache)
  cache = cache or {}
  if cache[name] then
    return cache[name]
  end
  local result, seen = {}, {}
  local function append(dependency)
    if seen[dependency] then
      return
    end
    seen[dependency] = true
    result[#result + 1] = dependency
    for _, nested in ipairs(dependency_closure(dependency, cache)) do
      if not seen[nested] then
        seen[nested] = true
        result[#result + 1] = nested
      end
    end
  end
  for _, dependency in ipairs(deps_of(name)) do
    append(dependency)
  end
  cache[name] = result
  return result
end

local function build_groups()
  local groups, declaration_order = {}, {}
  for _, name in ipairs(state.order) do
    local entry = get_spec(name)
    if entry.lua then
      local group = groups[entry.lua]
      if not group then
        group = { members = {}, order = #declaration_order + 1 }
        groups[entry.lua] = group
        declaration_order[#declaration_order + 1] = entry.lua
      end
      group.members[#group.members + 1] = name
    end
  end

  local edges = {}
  for cfg, group in pairs(groups) do
    edges[cfg] = {}
    local cache = {}
    for _, member in ipairs(group.members) do
      for _, dependency in ipairs(dependency_closure(member, cache)) do
        local dependency_entry = get_spec(dependency)
        if dependency_entry and dependency_entry.lua and dependency_entry.lua ~= cfg then
          edges[cfg][dependency_entry.lua] = true
        end
      end
    end
  end

  local visiting, done = {}, {}
  local function visit(cfg, path)
    if done[cfg] then
      return
    end
    if visiting[cfg] then
      err('cross-cfg init cycle: %s -> %s', table.concat(path, ' -> '), cfg)
    end
    visiting[cfg] = true
    path[#path + 1] = cfg
    for dependency_cfg in pairs(edges[cfg]) do
      visit(dependency_cfg, path)
    end
    path[#path] = nil
    visiting[cfg] = nil
    done[cfg] = true
  end
  for _, cfg in ipairs(declaration_order) do
    visit(cfg, {})
  end

  local ordered_groups, emitted = {}, {}
  local function emit(cfg)
    if emitted[cfg] then
      return
    end
    emitted[cfg] = true
    local dependencies = vim.tbl_keys(edges[cfg])
    table.sort(dependencies, function(a, b)
      return groups[a].order < groups[b].order
    end)
    for _, dependency_cfg in ipairs(dependencies) do
      emit(dependency_cfg)
    end
    ordered_groups[#ordered_groups + 1] = cfg
  end
  table.sort(declaration_order, function(a, b)
    return groups[a].order < groups[b].order
  end)
  for _, cfg in ipairs(declaration_order) do
    emit(cfg)
  end
  for cfg, group in pairs(groups) do
    local intra_deps = {}
    for _, member in ipairs(group.members) do
      intra_deps[member] = {}
      for _, dep in ipairs(deps_of(member)) do
        local dep_entry = get_spec(dep)
        if dep_entry and dep_entry.lua == cfg then
          intra_deps[member][dep] = true
        end
      end
    end
    table.sort(group.members, function(a, b)
      local sa, sb = get_spec(a), get_spec(b)
      return (sa and sa.order or 0) < (sb and sb.order or 0)
    end)
    -- Intra-group dependency order via DFS topological sort (stable by
    -- declaration order); validate() already rejects dependency cycles.
    local sorted_members, emitted = {}, {}
    local function emit(member)
      if emitted[member] then
        return
      end
      emitted[member] = true
      local deps = vim.tbl_keys(intra_deps[member])
      table.sort(deps, function(x, y)
        return get_spec(x).order < get_spec(y).order
      end)
      for _, dep in ipairs(deps) do
        emit(dep)
      end
      sorted_members[#sorted_members + 1] = member
    end
    for _, member in ipairs(group.members) do
      emit(member)
    end
    group.members = sorted_members
  end
  state.groups = groups
  state.group_order = ordered_groups
end

-- Node and configuration-group execution.
local function load_plugin(name)
  local ok, result = pcall(vim.fn['pack#load_raw'], name)
  return ok and result == 1
end

local run_group

local function execute_init(name, entry)
  if not entry.init then
    return true
  end
  -- prepare() validates and compiles every init before execution.
  local ok, execution_error = pcall(state.compiled_inits[name])
  if not ok then
    vim.notify(('pack.lua: init for %s failed: %s'):format(name, tostring(execution_error)), vim.log.levels.ERROR)
  end
  return ok
end

local function ensure_node(name, current_cfg)
  local node_state = state.node_state[name]
  if node_state == 'done' then
    return true
  end
  if node_state == 'failed' then
    return false
  end
  if node_state == 'running' then
    err('initialization re-entry: %s', name)
  end
  local entry = get_spec(name)
  if node_state == 'ready' and entry.lua == current_cfg then
    return true
  end
  if not installed(name) then
    state.node_state[name] = 'pending'
    return false
  end
  if entry and entry.lua and entry.lua ~= current_cfg then
    return run_group(entry.lua)
  end

  state.node_state[name] = 'running'
  for _, dependency in ipairs(deps_of(name)) do
    if not ensure_node(dependency, current_cfg) then
      state.node_state[name] = 'pending'
      return false
    end
  end
  if not load_plugin(name) then
    state.node_state[name] = 'pending'
    return false
  end
  if entry and not execute_init(name, entry) then
    state.node_state[name] = 'failed'
    return false
  end
  state.node_state[name] = entry and entry.lua and 'ready' or 'done'
  return true
end

run_group = function(cfg)
  if state.group_state[cfg] == 'done' then
    return true
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
      state.group_state[cfg] = state.node_state[member] == 'failed' and 'failed' or 'pending'
      return false
    end
  end

  local ok, execution_error = pcall(require, cfg)
  state.group_state[cfg] = ok and 'done' or 'failed'
  if not ok then
    vim.notify(('pack.lua: cfg %s failed: %s'):format(cfg, tostring(execution_error)), vim.log.levels.ERROR)
  end
  for _, member in ipairs(group.members) do
    state.node_state[member] = ok and 'done' or 'failed'
  end
  return ok
end

-- Explicit requests and native vim-plug User notifications.
local function request_one(name)
  if not vim.g.plugs or vim.g.plugs[name] == nil then
    err('unknown plugin request: %s', name)
  end
  return ensure_node(name, nil)
end

local function on_native_load(args)
  local name = args.match
  local node_state = state.node_state[name]
  -- Scheduler -> plug#load -> User is already being handled by ensure_node().
  if node_state == 'running' or node_state == 'done' or node_state == 'failed' then
    return
  end
  if not state.finished then
    if not state.native_seen[name] then
      state.native_seen[name] = true
      state.native_pending[#state.native_pending + 1] = name
    end
    return
  end
  request_one(name)
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
  local success = true
  for _, name in ipairs(names) do
    if not request_one(name) then
      success = false
    end
  end
  return success
end

-- Lifecycle and status queries.
local function run_startup()
  for _, cfg in ipairs(state.group_order or {}) do
    local group = state.groups[cfg]
    if group then
      local has_startup = false
      for _, member in ipairs(group.members) do
        if not lazy(member) then
          has_startup = true
          break
        end
      end
      if has_startup then
        run_group(cfg)
      end
    end
  end
  for _, name in ipairs(state.order) do
    if not lazy(name) then
      local entry = get_spec(name)
      if not entry or not entry.lua then
        request_one(name)
      end
    end
  end
end

function M.reset()
  vim.api.nvim_create_augroup('PackLua', { clear = true })
  state = new_state()
end

function M.prepare()
  if state.prepared then
    return
  end
  state.specs = vim.g.pack_specs or {}
  state.order = vim.g.pack_order or {}
  state.lazy = vim.g.pack_lazy or {}
  validate()
  build_groups()
  local group = vim.api.nvim_create_augroup('PackLua', { clear = true })
  local plugs, native_names = vim.g.plugs or {}, {}
  for _, name in ipairs(state.order) do
    if plugs[name] and plugs[name]['for'] ~= nil then
      native_names[#native_names + 1] = name
    end
  end
  if #native_names > 0 then
    vim.api.nvim_create_autocmd('User', {
      group = group,
      pattern = native_names,
      callback = on_native_load,
    })
  end
  state.prepared = true
end

function M.finish()
  if not state.prepared then
    err('finish before prepare')
  end
  if state.finished then
    return
  end
  state.finished = true
  local pending = state.native_pending
  state.native_pending = {}
  state.native_seen = {}
  for _, name in ipairs(pending) do
    request_one(name)
  end
  if vim.v.vim_did_enter == 1 then
    run_startup()
  else
    vim.api.nvim_create_autocmd('VimEnter', {
      group = 'PackLua',
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
    node_state = state.node_state,
  }
end

return M
