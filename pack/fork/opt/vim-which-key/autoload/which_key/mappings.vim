let s:TYPE = g:which_key#TYPE

function! s:string_to_keys(input) abort
  let input = a:input
  " Avoid special case: <>
  if match(input, '<.\+>') != -1
    let retlist = []
    let si = 0
    let go = 1
    while si < len(input)
      if go
        call add(retlist, input[si])
      else
        let retlist[-1] .= input[si]
      endif
      if input[si] ==? '<'
        let go = 0
      elseif input[si] ==? '>'
        let go = 1
      end
      let si += 1
    endwhile
    return retlist
  else
    return split(input, '\zs')
  endif
endfunction " }}}

function! s:execute(cmd)
  if exists("*execute")
    return execute(a:cmd)
  else
    redir => l:output
    silent! execute a:cmd
    redir END
    return l:output
  endif
endfunction

function! s:get_raw_map_info(key) abort
  return split(s:execute('map '.a:key), "\n")
endfunction

function! s:strip_prefix(lhs, prefix) abort
  if a:lhs[0 : strlen(a:prefix) - 1] ==# a:prefix
    return a:lhs[strlen(a:prefix) :]
  endif
  return a:lhs
endfunction

" Parse key-mappings gathered by `:map` and feed them into dict
function! which_key#mappings#parse(key, dict, visual) " {{{
  let key = a:key ==? ' ' ? '<Space>' : (a:key ==? '<C-I>' ? '<Tab>' : a:key)
  let dk = a:key ==? '<Space>' ? ' ' : (a:key ==? '<C-I>' ? '<Tab>' : a:key)
  if !has_key(a:dict, dk)
    let a:dict[dk] = {}
  endif
  let visual = a:visual ==# 'v'

  let lines = s:get_raw_map_info(key)
  if key ==# '<Tab>'
    call extend(lines, s:get_raw_map_info('<C-I>'))
  endif
  " In vim older than vim8.2.0815, Alt key as `<M->` togethr with English alphabet raise mapd.lhs
  " only contain eval() value, not '<M->'
  if !has('nvim') && key[0:2] ==# '<M-' && !has('patch-8.2.0815')
    let key = eval('"\' . key . '"')
  endif
  for line in lines
    let raw_sp = split(line[3:])
    let mapd = maparg(raw_sp[0], line[0], 0, 1)
    if empty(mapd) || mapd.lhs =~? '<Plug>.*' || mapd.lhs =~? '<SNR>.*'
      continue
    endif

    if has_key(mapd, 'desc')
      let mapd.display = copy(mapd.desc)
      unlet mapd.desc
    endif

    " NOTE: newer nvim may expose `callback` as a Funcref directly.
    " Keep that for execution. For older versions, try best-effort rhs rebuild.
    if has_key(mapd, 'callback') && type(mapd.callback) != s:TYPE.funcref
      unlet mapd.callback
      try
        let sp = split(split(maparg(raw_sp[0], line[0])[:-2])[-1], ':')
        " `fl` is nvim runtime script
        let fl = expand(sp[0])
        " `ln` is the line where the lua function layed,
        let ln = str2nr(sp[-1]) - 1
        let rhs = trim(readfile(fl)[ln])
        let rhs = split(rhs, 'M.')[1]
        " create api from file name
        let api = split(substitute(fl, "\\", "/", 'g'), 'runtime/lua/')[1]
        let api = substitute(api, 'lua$', '', 'g')
        let api = substitute(api, '/', '.', 'g')
        let mapd.rhs = '<Cmd>lua ' . api . rhs . '<Cr>'
      catch /.*/
        let mapd.rhs = '<Cmd>echo "lua function not show"<Cr>'
        if !has_key(mapd, 'display')
          let mapd.display = 'lua function not show'
        endif
      endtry
    endif

    if has_key(mapd, 'rhs')
      let mapd.rhs = substitute(mapd.rhs, '<SID>', '<SNR>'.mapd['sid'].'_', 'g')

      " eval the expression as the final {rhs}
      " Ref #60
      if mapd.expr && (!has_key(mapd, 'callback') || type(mapd.callback) != s:TYPE.funcref)
        try
          let mapd.rhs = eval(mapd.rhs)
        catch /.*/
          continue
        endtry
      endif
    endif

    if !has_key(mapd, 'display')
      if has_key(mapd, 'rhs')
        let mapd.display = call(g:WhichKeyFormatFunc, [mapd.rhs])
      elseif has_key(mapd, 'callback') && type(mapd.callback) == s:TYPE.funcref
        let mapd.display = 'lua callback'
      else
        continue
      endif
    endif

    let mapd.lhs = s:strip_prefix(mapd.lhs, key)
    " EasyMotion workaround, <leader><leader> is default easymotion prefix
    if mapd.lhs ==? '<Space>' && mapcheck('<leader><space>', 'n') =~ 'easymotion'
      continue
    endif
    let mapd.lhs = substitute(mapd.lhs, '<Space>', ' ', 'g')
    let mapd.lhs = substitute(mapd.lhs, '<C-I>', '<Tab>', 'g')

    if mapd.lhs !=# '' && mapd.display !~# 'WhichKey.*'
      if (match(mapd.mode, visual ? '[vx ]' : '[n ]') >= 0)
        let mapd.lhs = s:string_to_keys(mapd.lhs)
        call s:add_map_to_dict(mapd, 0, a:dict[dk])
      endif
    endif
  endfor
endfunction

function! s:execute_callback_expr(callback, feedkeyargs) abort
  try
    let rhs = call(a:callback, [])
    if type(rhs) == s:TYPE.string && rhs !=# ''
      if has('nvim') && exists('*nvim_replace_termcodes')
        let rhs = nvim_replace_termcodes(rhs, v:true, v:true, v:true)
      endif
      call feedkeys(rhs, a:feedkeyargs)
    endif
  catch /.*/
    call which_key#error#report(v:exception)
  endtry
endfunction

function! s:escape(mapping) abort " {{{
  if has_key(a:mapping, 'callback') && type(a:mapping.callback) == s:TYPE.funcref
    if get(a:mapping, 'expr', 0)
      return function('s:execute_callback_expr', [a:mapping.callback, a:mapping.noremap ? 'nt' : 'mt'])
    else
      return a:mapping.callback
    endif
  elseif !has_key(a:mapping, 'rhs')
    return 'call which_key#error#missing_mapping()'
  endif
  let feedkeyargs = a:mapping.noremap ? 'nt' : 'mt'
  let rhs = substitute(a:mapping.rhs, '\', '\\\\', 'g')
  let rhs = substitute(rhs, '<\([^<>]*\)>', '\\\<\1>', 'g')
  let rhs = substitute(rhs, '"', '\\"', 'g')
  let rhs = 'call feedkeys("'.rhs.'", "'.feedkeyargs.'")'
  return rhs
endfunction " }}}

function! s:add_map_to_dict(map, level, dict) " {{{

  let Cmd = s:escape(a:map)

  if len(a:map.lhs) > a:level+1
    let curkey = a:map.lhs[a:level]
    let nlevel = a:level+1

    if !has_key(a:dict, curkey)
      let a:dict[curkey] = { 'name' : g:which_key_default_group_name }
    " mapping defined already, flatten this map
    elseif type(a:dict[curkey]) == s:TYPE.list

      if g:which_key_flatten
        let curkey = join(a:map.lhs[a:level+0:], '')
        let nlevel = a:level
        if !has_key(a:dict, curkey)
          let a:dict[curkey] = [Cmd, a:map.display]
        endif
      else
        let curkey = curkey.'m'
        if !has_key(a:dict, curkey)
          let a:dict[curkey] = { 'name' : g:which_key_default_group_name }
        endif
      endif
    endif
    " next level
    if type(a:dict[curkey]) == s:TYPE.dict
      call s:add_map_to_dict(a:map, nlevel, a:dict[curkey])
    endif

  else

    let lhs_at_level = a:map.lhs[a:level]

    if !has_key(a:dict, lhs_at_level)
      let a:dict[lhs_at_level] = [Cmd, a:map.display]
    " spot is taken already, flatten existing submaps
    elseif type(a:dict[lhs_at_level]) == s:TYPE.dict
          \ && g:which_key_flatten
      let childmap = s:flatten(a:dict[lhs_at_level], lhs_at_level)
      for it in keys(childmap)
        let a:dict[it] = childmap[it]
      endfor
      let a:dict[lhs_at_level] = [Cmd, a:map.display]
    endif

  endif
endfunction

" Flatten map
function! s:flatten(dict, str) abort
  let flat = {}
  for kv in keys(a:dict)
    let ty = type(a:dict[kv])
    if ty == s:TYPE.list
      let toret = {}
      let toret[a:str.kv] = a:dict[kv]
      return toret
    elseif ty == s:TYPE.dict
      call extend(flat, s:flatten(a:dict[kv], a:str.kv))
    endif
  endfor
  return flat
endfunction
