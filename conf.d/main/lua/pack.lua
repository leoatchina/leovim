-- Neovim scheduler for PackAdd deps/init/cfg extensions.
-- pack.vim owns declarations, lazy state, installation state, and plug#load().

local M = {}

local state = {
  finished = false,
  specs = {}, -- snapshot of vim.g.pack_specs
  order = {}, -- snapshot of vim.g.pack_order
  lazy = {}, -- snapshot of vim.g.pack_lazy
  groups = nil, -- cfg -> { members = { name, ... }, order = number }
  group_order = nil,
  init_state = {}, -- plugin -> pending | running | done | failed
  cfg_called = {}, -- cfg -> true once require was attempted
  group_state = {}, -- cfg -> pending | running | done | failed
  init_done = {}, -- plugin -> true once scripts + init/cfg are complete
}

local function err(fmt, ...)
  error(('pack.lua: ' .. string.format(fmt, ...)), 0)
end

local function get_spec(name)
  return state.specs[name]
end

local compiled_inits = {}

function M.reset()
  state.finished = false
  state.specs = {}
  state.order = {}
  state.lazy = {}
  state.groups = nil
  state.group_order = nil
  state.init_state = {}
  state.cfg_called = {}
  state.group_state = {}
  state.init_done = {}
  compiled_inits = {}
end

local function as_list(value)
  if value == nil then
    return {}
  end
  if type(value) == 'string' then
    return { value }
  end
  if type(value) == 'table' then
    return value
  end
  return nil
end

local function deps_of(name)
  local entry = get_spec(name)
  if not entry then
    return {}
  end
  local deps = as_list(entry.deps)
  if not deps then
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
    compiled_inits[name] = chunk
  end
  if entry.cfg ~= nil and (
      type(entry.cfg) ~= 'string'
      or not entry.cfg:match('^[%w_][%w_.%-]*$')
      or entry.cfg:sub(-1) == '.'
      or entry.cfg:find('..', 1, true)
    ) then
    err('invalid cfg for %s: single Lua module name required', name)
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
    if entry.cfg then
      local group = groups[entry.cfg]
      if not group then
        group = { members = {}, order = #declaration_order + 1 }
        groups[entry.cfg] = group
        declaration_order[#declaration_order + 1] = entry.cfg
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
        if dependency_entry and dependency_entry.cfg and dependency_entry.cfg ~= cfg then
          edges[cfg][dependency_entry.cfg] = true
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

  local sorted, emitted = {}, {}
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
    sorted[#sorted + 1] = cfg
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
        if dep_entry and dep_entry.cfg == cfg then
          intra_deps[member][dep] = true
        end
      end
    end
    table.sort(group.members, function(a, b)
      if intra_deps[a] and intra_deps[a][b] then
        return false
      elseif intra_deps[b] and intra_deps[b][a] then
        return true
      end
      local sa, sb = get_spec(a), get_spec(b)
      return (sa and sa.order or 0) < (sb and sb.order or 0)
    end)
  end
  state.groups = groups
  state.group_order = sorted
end

local function load_plugin(name)
  local ok, result = pcall(vim.fn['pack#load_raw'], name)
  return ok and result == 1
end

local run_group

local function execute_init(name, entry)
  if not entry.init or state.init_state[name] == 'done' then
    return true
  end
  -- finish() validates and compiles every init before requests are accepted.
  local ok, execution_error = pcall(compiled_inits[name])
  state.init_state[name] = ok and 'done' or 'failed'
  if not ok then
    vim.notify(('pack.lua: init for %s failed: %s'):format(name, tostring(execution_error)), vim.log.levels.ERROR)
  end
  return ok
end

local function ensure_node(name, current_cfg)
  if state.init_done[name] then
    return true
  end
  local entry = get_spec(name)
  local has_no_cfg = entry == nil or entry.cfg == nil
  -- A cfg-bound member only counts as done inside its own group run.
  if state.init_state[name] == 'done' and (has_no_cfg or entry.cfg == current_cfg) then
    return true
  end
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
  for _, dependency in ipairs(deps_of(name)) do
    if not ensure_node(dependency, current_cfg) then
      state.init_state[name] = 'pending'
      return false
    end
  end
  if not load_plugin(name) then
    state.init_state[name] = 'pending'
    return false
  end
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
  local ok, execution_error = pcall(require, cfg)
  state.group_state[cfg] = ok and 'done' or 'failed'
  if not ok then
    vim.notify(('pack.lua: cfg %s failed: %s'):format(cfg, tostring(execution_error)), vim.log.levels.ERROR)
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
  for _, name in ipairs(names) do
    request_one(name)
  end
  return true
end

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
      if not entry or not entry.cfg then
        request_one(name)
      end
    end
  end
end

function M.finish()
  if state.finished then
    return
  end
  state.specs = vim.g.pack_specs or {}
  state.order = vim.g.pack_order or {}
  state.lazy = vim.g.pack_lazy or {}
  validate()
  build_groups()
  state.finished = true
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
  }
end

return M
