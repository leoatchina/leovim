" ----------------------------------------
" Package Management Functions
" ----------------------------------------
function! pack#get(pack) abort
    return count(g:packs, a:pack) > 0
endfunction

function! pack#add(...) abort
    if a:0 == 0
        return
    endif
    for require in a:000
        if !pack#get(require)
            call add(g:packs, require)
        endif
    endfor
endfunction

function! pack#planned(...) abort
    if empty(a:000)
        return 0
    endif
    for pack in a:000
        let pack = tolower(pack)
        if !has_key(g:leovim_installed, pack)
            return 0
        endif
    endfor
    return 1
endfunction

function! pack#installed(...) abort
    if empty(a:000)
        return 0
    endif
    for pack in a:000
        let pack = tolower(pack)
        if !has_key(g:leovim_installed, pack) || get(g:leovim_installed, pack, 0) == 0
            return 0
        endif
    endfor
    return 1
endfunction

" ----------------------------------------
" Extended Check Functions (from check.vim)
" ----------------------------------------
function! pack#planned_fzf() abort
    return pack#planned('fzf', 'fzf.vim')
endfunction

function! pack#planned_coc() abort
    return pack#get('coc') && g:node_version >= 16.18 && (has('nvim') || has('patch-9.0.0438'))
endfunction

function! pack#planned_lsp() abort
    return (pack#get('cmp') || pack#get('blink') || pack#get('blink.lua')) && has('nvim-0.11')
endfunction

function! pack#planned_adv_comp_eng() abort
    return pack#planned_coc() || pack#planned_lsp()
endfunction

function! pack#planned_leaderf() abort
    return pack#planned('leaderf')
endfunction

function! pack#pref_fzf() abort
    return pack#planned_fzf() && (get(g:, 'prefer_fzf', utils#is_unix()) || !pack#planned_leaderf())
endfunction

function! pack#installed_lsp() abort
    return pack#installed(
                \ 'nvim-lspconfig',
                \ 'mason-lspconfig.nvim',
                \ 'call-graph.nvim',
                \ 'symbol-usage.nvim',
                \ 'nvim-lsp-selection-range',
                \ 'formatter.nvim',
                \ 'dropbar.nvim',
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

function! pack#installed_adv() abort
    return pack#installed('coc.nvim') || pack#installed_lsp()
endfunction

