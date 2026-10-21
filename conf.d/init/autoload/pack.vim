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
                \ 'nvim-treesitter-refactor',
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
    return get(get(g:, 'pack_loaded', {}), a:name, 0)
endfunction

function! pack#load_raw(plugins) abort
    let plugins = type(a:plugins) == v:t_list ? a:plugins : [a:plugins]
    let unloaded = filter(copy(plugins), '!pack#loaded(v:val)')
    if empty(unloaded)
        return 1
    endif
    let result = call('plug#load', unloaded)
    if result
        for plugin in unloaded
            let g:pack_loaded[plugin] = 1
        endfor
    endif
    return result
endfunction

function! pack#load(plugins) abort
    let plugins = type(a:plugins) == v:t_list ? a:plugins : [a:plugins]
    if has('nvim') && exists('*luaeval')
        let g:pack_load_request = plugins
        try
            return luaeval("require('pack').load_request(vim.g.pack_load_request)")
        finally
            unlet! g:pack_load_request
        endtry
    endif
    return call('plug#load', plugins)
endfunction

" -------------------------------------------------
" PackAdd extension registry and `on` patterns
" -------------------------------------------------
let s:on_patterns = []
let s:on_sentinel = {}
let s:opt_plugs = {}
let s:for_patterns = []
let s:for_loaded = {}
let s:pending_fts = []

function! pack#begin(plugin_home) abort
    let g:pack_specs = {}
    let g:pack_order = []
    let g:pack_lazy = {}
    let g:pack_loaded = {}
    let s:on_patterns = []
    let s:on_sentinel = {}
    let s:opt_plugs = {}
    let s:for_patterns = []
    let s:for_loaded = {}
    let s:pending_fts = []
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
    augroup PackOnRegex
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
        if has_key(a:extras, 'init')
            throw printf('PackAdd: duplicate init binding for %s', a:name)
        endif
        if has_key(a:extras, 'cfg')
            throw printf('PackAdd: duplicate cfg binding for %s', a:name)
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
    let exact = []
    let has_native_regex = 0
    for value in values
        if type(value) != v:t_string || empty(value)
            throw printf('PackAdd: on for %s must be a string or string list', a:plugin)
        endif
        let is_map = stridx(value, '<Plug>') == 0
        let is_regex = s:is_on_regex(value, is_map)
        if is_regex
            call s:validate_on_regex(value, a:plugin)
        endif
        if has('nvim') && !is_map
            call add(s:on_patterns, {
                        \ 'plugin': a:plugin,
                        \ 'pattern': is_regex ? value : substitute(value, '!$', '', ''),
                        \ 'map': 0,
                        \ 'exact': !is_regex,
                        \ 'managed': 1,
                        \ })
        elseif is_regex
            call add(s:on_patterns, {
                        \ 'plugin': a:plugin,
                        \ 'pattern': value,
                        \ 'map': is_map,
                        \ 'exact': 0,
                        \ 'managed': 0,
                        \ })
            let has_native_regex = 1
        else
            call add(exact, value)
        endif
    endfor
    if has_native_regex
        let sentinel = 'PackRegex' . (len(s:on_sentinel) + 1)
        let s:on_sentinel[a:plugin] = sentinel
        call add(exact, sentinel)
    endif
    return exact
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
            if !item.map || get(item, 'managed', 0) || !has_key(g:plugs, item.plugin)
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
            if item.map && !get(item, 'managed', 0)
                throw 'PackAdd: <Plug> on regex requires maplist()'
            endif
        endfor
    endif
    augroup PackOnRegex
        autocmd!
        autocmd CmdUndefined * call pack#on_cmd(expand('<amatch>'))
        if has('nvim') && !empty(s:for_patterns)
            autocmd FileType * call pack#on_ft(expand('<amatch>'))
        endif
    augroup END
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
            for pattern in [
                        \ 'ftdetect/**/*.vim',
                        \ 'ftdetect/**/*.lua',
                        \ 'after/ftdetect/**/*.vim',
                        \ 'after/ftdetect/**/*.lua',
                        \ ]
                for file in globpath(root, pattern, 0, 1)
                    execute 'silent source ' . fnameescape(file)
                endfor
            endfor
        endfor
    augroup END
    " Managed for plugins lose their native proxies; load their plugin/
    " scripts so PlugLOD stays a no-op while FileType stays with pack.lua.
    let targets = []
    for item in s:for_patterns
        if has_key(g:plugs, item.plugin) && !get(s:for_loaded, item.plugin, 0)
            call add(targets, item.plugin)
        endif
    endfor
    if !empty(targets)
        call pack#load_raw(targets)
    endif
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
    if has('nvim') && !luaeval("require('pack').is_finished()")
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
    for plugin in plugins
        let s:for_loaded[plugin] = 1
    endfor
    if !pack#load(plugins)
        return
    endif
    for plugin in plugins
        call s:source_for(plugin, a:filetype)
    endfor
    silent! doautocmd <nomodeline> filetypeplugin FileType
    silent! doautocmd <nomodeline> filetypeindent FileType
endfunction

function! pack#end() abort
    call s:prepare_on()
    call plug#end()
    call s:prepare_for()
    if has('nvim')
        lua require('pack').finish()
        for filetype in s:pending_fts
            call pack#on_ft(filetype)
        endfor
        let s:pending_fts = []
    endif
endfunction

function! pack#on_cmd(command) abort
    let plugins = []
    for item in s:on_patterns
        if !item.map && (get(item, 'managed', 0) || !has('nvim'))
                    \ && ((get(item, 'exact', 0) && a:command ==# item.pattern)
                    \ || (!get(item, 'exact', 0) && a:command =~# item.pattern))
                    \ && index(plugins, item.plugin) < 0
            call add(plugins, item.plugin)
        endif
    endfor
    if !empty(plugins)
        call pack#load(plugins)
    endif
endfunction
