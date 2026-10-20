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
    return pack#get('cmp') && has('nvim-0.11')
endfunction

function! pack#planned_blink() abort
    return (pack#get('blink') || pack#get('blink.lua')) && has('nvim-0.11')
endfunction

function! pack#planned_lsp() abort
    return (pack#get('cmp') || pack#get('blink') || pack#get('blink.lua')) && has('nvim-0.11')
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
    return has('nvim-0.9.4') && pack#installed('snacks.nvim')
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

" -------------------------------------------------
" Extended vim-plug `on` patterns
" -------------------------------------------------
let s:on_patterns = []
let s:on_sentinel = {}

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
    let has_regex = 0
    for value in values
        if type(value) != v:t_string || empty(value)
            throw printf('PackAdd: on for %s must be a string or string list', a:plugin)
        endif
        let is_map = stridx(value, '<Plug>') == 0
        if s:is_on_regex(value, is_map)
            call s:validate_on_regex(value, a:plugin)
            call add(s:on_patterns, {
                        \ 'plugin': a:plugin,
                        \ 'pattern': value,
                        \ 'map': is_map,
                        \ })
            let has_regex = 1
        else
            call add(exact, value)
        endif
    endfor
    if has_regex
        let sentinel = 'PackRegex' . (len(s:on_sentinel) + 1)
        let s:on_sentinel[a:plugin] = sentinel
        call add(exact, sentinel)
    endif
    return exact
endfunction

function! s:add_on_value(plugin, value) abort
    let current = get(g:plugs[a:plugin], 'on', [])
    let current = type(current) == v:t_list ? current : [current]
    if index(current, a:value) < 0
        call add(current, a:value)
    endif
    let g:plugs[a:plugin].on = current
endfunction

function! pack#prepare_on() abort
    if empty(s:on_patterns)
        return
    endif
    if !exists('*maplist')
        for item in s:on_patterns
            if item.map
                throw 'PackAdd: <Plug> on regex requires maplist()'
            endif
        endfor
    else
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
    endif
    augroup PackOnRegex
        autocmd!
        autocmd CmdUndefined * call pack#on_cmd(expand('<amatch>'))
    augroup END
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
        call call('plug#load', plugins)
    endif
endfunction
