-- pack.lua: Neovim-side scheduler for PackAdd deps/cfg extensions.
-- Loaded from conf.d/init/autoload/pack.vim (register) and init.vim (finish,
-- right after plug#end). Does not install anything; vim-plug owns install.

local M = {}

local state = {
  registered = {}, -- name -> { cfg?: string, deps: string[], order: number }
  count = 0,
  finished = false,
  groups = nil, -- cfg -> { members = {name,...}, order = number }
  group_order = nil, -- topo-ordered cfg names
  group_state = {}, -- cfg -> 'done' | 'failed' | 'pending'
  init_done = {}, -- plugin name -> true once scripts + its cfg group are complete
}

local function err(fmt, ...)
  error(('pack.lua: ' .. string.format(fmt, ...)), 0)
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

--- Register extras extracted by pack.vim from a PackAdd call.
--- Must run before the g:plugs dedup return so duplicate-cfg conflicts error.
function M.register(name, extras)
  extras = extras or {}
  if state.finished then
    err('declaration after finish(): %s', name)
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
  local entry = state.registered[name]
  if entry then
    if cfg ~= nil then
      err('duplicate cfg binding for %s: first %s, then %s', name, tostring(entry.cfg), cfg)
    end
    return
  end
  state.count = state.count + 1
  state.registered[name] = { cfg = cfg, deps = deps, order = state.count }
end

local function spec_of(name)
  local plugs = vim.g.plugs or {}
  return plugs[name]
end

local function is_lazy(spec)
  return spec ~= nil and (spec.on ~= nil or spec['for'] ~= nil)
end

local function installed(name)
  local spec = spec_of(name)
  return spec ~= nil and type(spec.dir) == 'string' and vim.fn.isdirectory(spec.dir) == 1
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
  local ok, e = pcall(vim.fn['plug#load'], name)
  if not ok then
    err('plug#load failed for %s: %s', name, tostring(e))
  end
end

local function run_group(cfg)
  local g = state.groups[cfg]
  local cache = {}
  local pending = false
  for _, member in ipairs(g.members) do
    if not installed(member) then
      pending = true
      break
    end
    for _, q in ipairs(closure_of(member, cache)) do
      if not installed(q) then
        pending = true
        break
      end
      if state.init_done[q] ~= true then
        local entry = state.registered[q]
        if entry and entry.cfg then
          if entry.cfg ~= cfg then
            -- Its own group runs first (topo order); not done means pending/failed.
            pending = true
            break
          end
          -- A dependency in this cfg group is initialized by the same require.
        else
          -- No cfg: only its scripts are required; lazy ones load on demand.
          if is_lazy(spec_of(q)) then
            load_plugin(q)
          end
          state.init_done[q] = true
        end
      end
    end
    if pending then
      break
    end
  end
  if pending then
    state.group_state[cfg] = 'pending'
    return
  end
  -- A startup member pulls the whole group: lazy members load their scripts now.
  for _, member in ipairs(g.members) do
    if is_lazy(spec_of(member)) then
      load_plugin(member)
    end
  end
  local ok, e = pcall(require, cfg)
  state.group_state[cfg] = ok and 'done' or 'failed'
  if not ok then
    vim.notify(('pack.lua: cfg %s failed: %s'):format(cfg, tostring(e)), vim.log.levels.ERROR)
  end
  for _, member in ipairs(g.members) do
    state.init_done[member] = ok
  end
end

local function run_startup()
  for _, cfg in ipairs(state.group_order) do
    run_group(cfg)
  end
end

-- Plugins without a cfg are init-complete once installed and their scripts
-- are loaded (startup plugins are loaded by plug#end; lazy ones wait for a
-- consumer group to force-load them).
local function mark_plugin_done(name)
  local entry = state.registered[name]
  if entry and entry.cfg then
    return
  end
  if installed(name) then
    state.init_done[name] = not is_lazy(spec_of(name))
  end
end

--- Freeze the plan, then run startup cfg groups after plugin scripts load.
--- Called from init.vim right after plug#end().
function M.finish()
  if state.finished then
    return
  end
  state.finished = true
  local names = vim.tbl_keys(state.registered)
  table.sort(names, function(a, b)
    return state.registered[a].order < state.registered[b].order
  end)
  for _, name in ipairs(names) do
    mark_plugin_done(name)
  end
  validate()
  build_groups()
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
    init_done = state.init_done,
  }
end

return M
