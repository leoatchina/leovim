" ----------------------------------------
" Package Management Functions
" ----------------------------------------
function! pack#get(pack) abort
    return index(g:packs, a:pack) >= 0
endfunction

function! pack#add(...) abort
    if a:0 == 0
        return
    endif
    for require in a:000
        if index(g:packs, require) < 0
            call add(g:packs, require)
        endif
    endfor
endfunction

function! pack#planned(...) abort
    if a:0 <= 1
        return a:0 == 1 && has_key(g:plugs, a:1)
    endif
    return empty(filter(copy(a:000), '!has_key(g:plugs, v:val)'))
endfunction

function! pack#installed(...) abort
    if a:0 <= 1
        return a:0 == 1 && has_key(g:plugs, a:1) && isdirectory(get(g:plugs[a:1], 'dir', ''))
    endif
    return empty(filter(copy(a:000),
                \ '!has_key(g:plugs, v:val) || !isdirectory(get(g:plugs[v:val], "dir", ""))'))
endfunction

" Cached scheduler queries; pack#installed() remains a live directory check.
let s:installed_cache = {}

" Positive-only cache: missing plugins stay retryable after a later install.
function! pack#installed_cached(name) abort
    if !get(s:installed_cache, a:name, 0) && pack#installed(a:name)
        let s:installed_cache[a:name] = 1
    endif
    return get(s:installed_cache, a:name, 0)
endfunction
" -------------------------------------------
" Extended Check Functions (from check.vim)
" -------------------------------------------
function! pack#planned_fzf() abort
    return pack#planned('fzf', 'fzf.vim')
endfunction

function! pack#planned_leaderf() abort
    return pack#planned('LeaderF')
endfunction

function! pack#planned_coc() abort
    return pack#get('coc') && g:node_version >= 24 && has('patch-9.0.0438')
endfunction

function! pack#planned_cmp() abort
    return pack#get('cmp') && has('nvim')
endfunction

function! pack#planned_blink() abort
    return (pack#get('blink') || pack#get('blink.lua')) && has('nvim')
endfunction

function! pack#planned_lsp() abort
    return (pack#get('cmp') || pack#get('blink') || pack#get('blink.lua')) && has('nvim')
endfunction

function! pack#planned_adv_comp_eng() abort
    return pack#planned_coc() || pack#planned_lsp()
endfunction

function! pack#planned_treesitter() abort
    return pack#planned('nvim-treesitter')
endfunction

function! pack#planned_dap() abort
    return pack#planned('nvim-dap')
endfunction

function! pack#planned_mason() abort
    return pack#planned('mason.nvim')
endfunction

function! pack#pref_fzf() abort
    return pack#planned_fzf() && (get(g:, 'prefer_fzf', utils#is_unix()) || !pack#planned_leaderf())
endfunction

function! pack#installed_fzf() abort
    return pack#installed('fzf', 'fzf.vim')
endfunction

function! pack#installed_leaderf()
    return pack#installed('LeaderF')
endfunction

function! pack#installed_snacks() abort
    return has('nvim') && pack#installed('snacks.nvim')
endfunction

function! pack#installed_lsp() abort
    return pack#installed(
                \ 'nvim-lspconfig',
                \ 'mason-lspconfig.nvim',
                \ 'call-graph.nvim',
                \ 'symbol-usage.nvim',
                \ 'nvim-lsp-selection-range',
                \ 'aerial.nvim',
                \ )
endfunction

function! pack#installed_coc() abort
    return pack#installed('coc.nvim', 'coc-fzf', 'friendly-snippets') && pack#planned_fzf()
endfunction

function! pack#installed_blink() abort
    return pack#installed('blink.cmp', 'friendly-snippets', 'nvim-autopairs')
endfunction

function! pack#installed_cmp() abort
    return pack#installed(
                \ 'nvim-cmp',
                \ 'cmp-nvim-lsp',
                \ 'cmp-nvim-lua',
                \ 'cmp-buffer',
                \ 'cmp-cmdline',
                \ 'cmp-vsnip',
                \ 'cmp-nvim-lsp-signature-help',
                \ 'cmp-async-path',
                \ 'lspkind-nvim',
                \ 'colorful-menu.nvim',
                \ 'friendly-snippets',
                \ 'nvim-autopairs',
                \ )
endfunction

function! pack#installed_treesitter() abort
    return pack#installed(
                \ 'nvim-treesitter',
                \ 'hlargs.nvim',
                \ 'nvim-treesitter-textobjects',
                \ 'nvim-treesitter-context',
                \ )
endfunction

function! pack#installed_dap() abort
    return pack#installed(
                \ 'nvim-dap',
                \ 'nvim-dap-ui',
                \ 'nvim-nio',
                \ 'mason.nvim',
                \ 'mason-nvim-dap.nvim',
                \ )
endfunction

function! pack#installed_mason() abort
    return pack#installed('mason.nvim')
endfunction

function! pack#installed_adv() abort
    return pack#installed('coc.nvim') || pack#installed_lsp()
endfunction

function! pack#lazy(name) abort
    if get(get(g:, 'pack_lazy', {}), a:name, 0)
        return 1
    endif
    if !has_key(g:plugs, a:name)
        return 0
    endif
    let spec = g:plugs[a:name]
    return has_key(spec, 'on') || has_key(spec, 'for')
endfunction

function! pack#loaded(name) abort
    if get(get(g:, 'pack_loaded', {}), a:name, 0)
        return 1
    endif
    " Non-lazy plugins that were missing at pack#end() never got sourced;
    " they stay retryable through plug#load instead of being pre-marked.
    if !pack#lazy(a:name) && !get(get(g:, 'pack_pending', {}), a:name, 0)
                \ && pack#installed_cached(a:name)
        let g:pack_loaded[a:name] = 1
        return 1
    endif
    return 0
endfunction

let s:finished = 0

function! pack#load_raw(plugins) abort
    let plugins = type(a:plugins) == v:t_list ? a:plugins : [a:plugins]
    let unloaded = filter(copy(plugins), '!pack#loaded(v:val)')
    if empty(unloaded)
        return 1
    endif
    let missing = filter(copy(unloaded), '!pack#installed_cached(v:val)')
    if !empty(missing)
        return 0
    endif
    call call('plug#load', unloaded)
    for plugin in unloaded
        if has_key(g:pack_pending, plugin)
            call remove(g:pack_pending, plugin)
        endif
        let g:pack_loaded[plugin] = 1
    endfor
    return 1
endfunction

function! pack#load(plugins) abort
    if has('nvim')
        return luaeval("require('pack').load_request(_A)", a:plugins)
    endif
    return pack#load_raw(a:plugins)
endfunction

" -------------------------------------------------
" PackAdd extension registry and `on` patterns
" -------------------------------------------------
let s:on_patterns = []
let s:cmd_proxies = {}
let s:map_plugins = {}
let s:opt_plugs = {}
let s:for_patterns = []
let s:for_loaded = {}
let s:pending_fts = []

function! pack#begin(plugin_home) abort
    let g:pack_specs = {}
    let g:pack_order = []
    let g:pack_lazy = {}
    let g:pack_loaded = {}
    let g:pack_pending = {}
    let s:on_patterns = []
    let s:cmd_proxies = {}
    let s:map_plugins = {}
    let s:opt_plugs = {}
    let s:for_patterns = []
    let s:for_loaded = {}
    let s:pending_fts = []
    let s:finished = 0
    let s:installed_cache = {}
    for opt_dir in [$LEO_OPT_DIR, $FORK_OPT_DIR, $CLONE_OPT_DIR]
        for plug_dir in globpath(opt_dir, '*', 0, 1)
            if isdirectory(plug_dir)
                let abs_dir = substitute(fnamemodify(plug_dir, ':p'), '[\\/]$', '', '')
                let s:opt_plugs[fnamemodify(abs_dir, ':t')] = abs_dir
            endif
        endfor
    endfor
    let g:plugs = {}
    let g:plug_threads = get(g:, 'plug_threads', 16)
    augroup PackHooks
        autocmd!
    augroup END
    execute 'set rtp^=' . fnameescape($MAIN_DIR)
    if has('nvim')
        lua require('pack').reset()
    endif
    call plug#begin(a:plugin_home)
    command! -nargs=+ PackAdd call pack#declare(<args>)
    command! PackUpdate call pack#update()
    nnoremap <silent><Tab>u :PackUpdate<Cr>
    nnoremap <silent><Tab>i :PlugInstall<Cr>
    command! PackCommands call FzfCallCommands('PackCommands', 'Pack', 'Plug')
    nnoremap <silent><Tab>: :PackCommands<Cr>
    if filereadable(utils#expand("~/.leovim.d/pack.vim"))
        source ~/.leovim.d/pack.vim
    endif
endfunction

function! pack#declare(plugin, ...) abort
    let plugin = substitute(a:plugin, '[\/]\+$', '', 'g')
    let opts = a:0 > 0 ? copy(a:1) : {}
    if has_key(opts, 'as') && !empty(opts.as)
        let key_name = opts.as
    elseif plugin =~ '/'
        let key_name = split(plugin, '/')[-1]
    else
        let key_name = plugin
    endif
    let extras = {}
    for field in ['deps', 'init', 'cfg']
        if has_key(opts, field)
            let extras[field] = remove(opts, field)
        endif
    endfor
    if !has('nvim') && !empty(extras)
        echoerr 'PackAdd deps/init/cfg are Neovim-only: ' . key_name
    endif
    call pack#register(key_name, extras)
    if has_key(g:plugs, key_name)
        return
    endif
    if has_key(opts, 'on') || has_key(opts, 'for')
        let g:pack_lazy[key_name] = 1
    endif
    if has_key(opts, 'on')
        let opts.on = pack#register_on(key_name, opts.on)
    endif
    if has('nvim') && has_key(opts, 'for')
        call pack#register_for(key_name, opts.for)
        call remove(opts, 'for')
        if !has_key(opts, 'on')
            let opts.on = []
        endif
    endif
    if plugin =~ '/'
        call plug#(plugin, opts)
    elseif has_key(s:opt_plugs, plugin)
        call plug#(s:opt_plugs[plugin], opts)
    else
        echoe plugin . ' not exists'
    endif
endfunction

function! pack#update() abort
    let vimrc_opt = utils#expand('~/.vimrc.opt')
    if filereadable(vimrc_opt)
        execute 'source ' . vimrc_opt
    endif
    PlugUpdate
endfunction

function! pack#register(name, extras) abort
    if has_key(g:pack_specs, a:name)
        let existing = g:pack_specs[a:name]
        if has_key(a:extras, 'init')
            throw printf('PackAdd: duplicate init binding for %s', a:name)
        endif
        if has_key(a:extras, 'cfg')
            throw printf('PackAdd: duplicate cfg binding for %s', a:name)
        endif
        if has_key(a:extras, 'deps')
            let new_deps = type(a:extras.deps) == v:t_list ? a:extras.deps : [a:extras.deps]
            let cur_deps = has_key(existing, 'deps') ?
                        \ (type(existing.deps) == v:t_list ? existing.deps : [existing.deps]) : []
            for dep in new_deps
                if index(cur_deps, dep) < 0
                    call add(cur_deps, dep)
                endif
            endfor
            let existing.deps = cur_deps
        endif
        return
    endif
    let spec = copy(a:extras)
    let spec.order = len(g:pack_order) + 1
    let g:pack_specs[a:name] = spec
    call add(g:pack_order, a:name)
endfunction

function! s:is_on_regex(value, is_map) abort
    if a:is_map
        return a:value =~# '[.*\[~^$\\]'
    endif
    return a:value !~# '^[A-Z][A-Za-z0-9]*!\?$'
endfunction

function! s:validate_on_regex(pattern, plugin) abort
    try
        call match('', a:pattern)
    catch /^Vim\%((\a\+)\)\=:E/
        throw printf('PackAdd: invalid on regex for %s: %s', a:plugin, a:pattern)
    endtry
endfunction

function! pack#register_on(plugin, value) abort
    let values = type(a:value) == v:t_list ? copy(a:value) : [a:value]
    let plug_exact = []
    for value in values
        if type(value) != v:t_string || empty(value)
            throw printf('PackAdd: on for %s must be a string or string list', a:plugin)
        endif
        let is_map = stridx(value, '<Plug>') == 0
        let is_regex = s:is_on_regex(value, is_map)
        if is_regex
            call s:validate_on_regex(value, a:plugin)
        endif
        if is_map
            let s:map_plugins[a:plugin] = 1
        endif
        if is_regex
            call add(s:on_patterns, {
                        \ 'plugin': a:plugin,
                        \ 'pattern': value,
                        \ 'map': is_map,
                        \ })
        elseif is_map || !has('nvim')
            call add(plug_exact, value)
        else
            let cmd_name = substitute(value, '!$', '', '')
            if !has_key(s:cmd_proxies, cmd_name)
                let s:cmd_proxies[cmd_name] = []
            endif
            if index(s:cmd_proxies[cmd_name], a:plugin) < 0
                call add(s:cmd_proxies[cmd_name], a:plugin)
            endif
        endif
    endfor
    return plug_exact
endfunction

function! pack#lod_cmd(cmd, bang, l1, l2, args, mods, names) abort
    execute 'silent! delc ' . a:cmd
    if !pack#load(a:names)
        return
    endif
    let range = (a:l1 == a:l2 ? '' : (a:l1 . ',' . a:l2))
    execute printf('%s %s%s%s %s', a:mods, range, a:cmd, a:bang, a:args)
endfunction

function! pack#register_for(plugin, value) abort
    let values = type(a:value) == v:t_list ? copy(a:value) : [a:value]
    if empty(values)
        throw printf('PackAdd: for for %s must not be empty', a:plugin)
    endif
    for value in values
        if type(value) != v:t_string || empty(value)
            throw printf('PackAdd: for for %s must be a string or string list', a:plugin)
        endif
    endfor
    call add(s:for_patterns, {'plugin': a:plugin, 'filetypes': values})
endfunction

function! s:add_on_value(plugin, value) abort
    let current = get(g:plugs[a:plugin], 'on', [])
    let current = type(current) == v:t_list ? current : [current]
    if index(current, a:value) < 0
        call add(current, a:value)
    endif
    let g:plugs[a:plugin].on = current
endfunction

function! s:prepare_on() abort
    if exists('*maplist')
        let mappings = maplist()
        for item in s:on_patterns
            if !item.map || !has_key(g:plugs, item.plugin)
                continue
            endif
            for mapping in mappings
                let target = get(mapping, 'rhs', '')
                if stridx(target, '<Plug>') == 0 && target =~# item.pattern
                    call s:add_on_value(item.plugin, target)
                endif
            endfor
        endfor
    else
        for item in s:on_patterns
            if item.map
                throw 'PackAdd: <Plug> on regex requires maplist()'
            endif
        endfor
    endif
    augroup PackHooks
        autocmd!
        autocmd CmdUndefined * call pack#on_cmd(expand('<amatch>'))
        if !empty(s:for_patterns)
            autocmd FileType * call pack#on_ft(expand('<amatch>'))
        endif
    augroup END
endfunction

" Capture the editing context before loading scripts can change it.
function! pack#lod_map(target, names, with_prefix, visual) abort
    let prefix = ''
    if a:with_prefix
        let prefix = (v:count ? v:count : '') . '"' . v:register . a:visual
        if mode(1) ==# 'no'
            let prefix = (v:operator ==# 'c' ? "\<Esc>" : '') . prefix . v:operator
        endif
    endif
    if !pack#load(a:names)
        return
    endif
    " Insert replay before pending input; do not drain getchar() or lose typeahead.
    let target = substitute(a:target, '^<Plug>', "\<Plug>", '')
    call feedkeys(prefix . target, 'mi')
endfunction

function! s:prepare_maps() abort
    let targets = {}
    for name in g:pack_order
        if !has_key(s:map_plugins, name)
            continue
        endif
        for target in get(g:plugs[name], 'on', [])
            if stridx(target, '<Plug>') == 0
                if !has_key(targets, target)
                    let targets[target] = []
                endif
                if index(targets[target], name) < 0
                    call add(targets[target], name)
                endif
            endif
        endfor
    endfor
    for [target, names] in items(targets)
        for [mode, enter, visual] in [
                    \ ['i', '<C-\><C-O>', ''], ['n', '', ''],
                    \ ['v', '', 'gv'], ['o', '', '']]
            " Only replace vim-plug's proxy, never a real/user mapping.
            if maparg(target, mode) =~# '\Ccall <SNR>\d\+_lod_map('
                execute printf(
                            \ '%snoremap <silent> %s %s:<C-U>call pack#lod_map(%s, %s, %d, %s)<CR>',
                            \ mode, target, enter, string(target), string(names),
                            \ mode !=# 'i', string(visual))
            endif
        endfor
    endfor
endfunction

function! s:plugin_root(plugin) abort
    let spec = get(g:plugs, a:plugin, {})
    let root = get(spec, 'dir', '')
    if !empty(get(spec, 'rtp', ''))
        let root .= '/' . get(spec, 'rtp', '')
    endif
    return root
endfunction

function! s:prepare_for() abort
    if !has('nvim') || empty(s:for_patterns)
        return
    endif
    augroup filetypedetect
        for item in s:for_patterns
            let root = s:plugin_root(item.plugin)
            if isdirectory(root . '/ftdetect')
                for file in globpath(root, 'ftdetect/**/*.{vim,lua}', 0, 1)
                    execute 'silent source ' . fnameescape(file)
                endfor
            endif
            if isdirectory(root . '/after/ftdetect')
                for file in globpath(root, 'after/ftdetect/**/*.{vim,lua}', 0, 1)
                    execute 'silent source ' . fnameescape(file)
                endfor
            endif
        endfor
    augroup END
endfunction

function! s:source_for(plugin, filetype) abort
    let root = s:plugin_root(a:plugin)
    for file in globpath(root, 'syntax/' . a:filetype . '.vim', 0, 1)
        execute 'silent source ' . fnameescape(file)
    endfor
    for file in globpath(root . '/after', 'syntax/' . a:filetype . '.vim', 0, 1)
        if !empty(file)
            execute 'silent source ' . fnameescape(file)
        endif
    endfor
endfunction

function! pack#on_ft(filetype) abort
    if has('nvim') && !s:finished
        " FileType fired while pack#end() is still preparing (e.g. BufRead
        " inside plug#load); defer until the plan is frozen.
        if index(s:pending_fts, a:filetype) < 0
            call add(s:pending_fts, a:filetype)
        endif
        return
    endif
    let plugins = []
    for item in s:for_patterns
        if index(item.filetypes, a:filetype) >= 0
                    \ && !get(s:for_loaded, item.plugin, 0)
                    \ && index(plugins, item.plugin) < 0
            call add(plugins, item.plugin)
        endif
    endfor
    if empty(plugins)
        return
    endif
    if !pack#load(plugins)
        return
    endif
    for plugin in plugins
        let s:for_loaded[plugin] = 1
        call s:source_for(plugin, a:filetype)
    endfor
    silent! doautocmd <nomodeline> filetypeplugin FileType
    silent! doautocmd <nomodeline> filetypeindent FileType
endfunction

function! pack#end() abort
    call s:prepare_on()
    for name in g:pack_order
        if !pack#lazy(name) && !pack#installed(name)
            let g:pack_pending[name] = 1
            " Keep vim-plug from pre-marking an absent startup plugin loaded.
            let g:plugs[name].on = []
        endif
    endfor
    call plug#end()
    call s:prepare_for()
    if has('nvim')
        call s:prepare_maps()
        for [cmd, names] in items(s:cmd_proxies)
            if exists(':' . cmd) != 2
                let mods_expr = has('patch-7.4.1898') ? '<q-mods>' : '""'
                execute printf(
                \ 'command! -nargs=* -range -bang -complete=file %s call pack#lod_cmd(%s, "<bang>", <line1>, <line2>, <q-args>, %s, %s)',
                \ cmd, string(cmd), mods_expr, string(names))
            endif
        endfor
        lua require('pack').finish()
        let s:finished = 1
        for filetype in s:pending_fts
            call pack#on_ft(filetype)
        endfor
        let s:pending_fts = []
    endif
endfunction

function! pack#on_cmd(command) abort
    let plugins = []
    for item in s:on_patterns
        if !item.map && a:command =~# item.pattern
                    \ && index(plugins, item.plugin) < 0
            call add(plugins, item.plugin)
        endif
    endfor
    if !empty(plugins)
        call pack#load(plugins)
    endif
endfunction
