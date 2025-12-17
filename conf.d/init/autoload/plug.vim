" ----------------------------------------
" Package Management Functions
" ----------------------------------------
function! plug#require(pack) abort
    return count(g:requires, a:pack) > 0
endfunction

function! plug#add(...) abort
    if a:0 == 0
        return
    endif
    for require in a:000
        if !plug#require(require)
            call add(g:requires, require)
        endif
    endfor
endfunction

function! plug#planned(...) abort
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

function! plug#installed(...) abort
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
function! plug#planned_fzf() abort
    return plug#planned('fzf', 'fzf.vim')
endfunction

function! plug#planned_coc() abort
    return plug#require('coc') && g:node_version >= 16.18 && (has('nvim') || has('patch-9.0.0438'))
endfunction

function! plug#planned_lsp() abort
    return (plug#require('cmp') || plug#require('blink') || plug#require('blink.lua')) && has('nvim-0.11')
endfunction

function! plug#planned_adv_comp_eng() abort
    return plug#planned_coc() || plug#planned_lsp()
endfunction

function! plug#planned_leaderf() abort
    return plug#planned('leaderf')
endfunction

function! plug#pref_fzf() abort
    return plug#planned_fzf() && (get(g:, 'prefer_fzf', utils#is_unix()) || !plug#planned_leaderf())
endfunction

function! plug#installed_lsp() abort
    return plug#installed(
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

function! plug#installed_coc() abort
    return plug#installed('coc.nvim', 'coc-fzf', 'friendly-snippets') && plug#planned_fzf()
endfunction

function! plug#installed_blink() abort
    return plug#installed('blink.cmp', 'friendly-snippets', 'nvim-autopairs')
endfunction

function! plug#installed_cmp() abort
    return plug#installed(
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

function! plug#installed_adv() abort
    return plug#installed('coc.nvim') || plug#installed_lsp()
endfunction

