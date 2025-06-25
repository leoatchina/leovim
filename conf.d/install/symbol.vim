" ------------------------------
"  symbol_tool
" ------------------------------
let g:symbol_tool = []
function! s:planned_symbol(symbol) abort
    return count(g:symbol_tool, a:symbol)
endfunction
function! s:add_symbol(symbol) abort
    if s:planned_symbol(a:symbol) <= 0
        call add(g:symbol_tool, a:symbol)
    endif
endfunction
" ------------------------------
" lsp or vista or tagbar
" ------------------------------
if PlannedLsp()
    call s:add_symbol('nvimlsp')
    call s:add_symbol('vista')
elseif g:complete_engine == 'coc'
    call s:add_symbol('coc')
    call s:add_symbol('vista')
elseif g:complete_engine == 'mcm'
    if v:version >= 800 && get(g:, 'ctags_type', '') =~ 'Universal'
        call s:add_symbol('vista')
    elseif get(g:, 'ctags_type', '') != ''
        call s:add_symbol('tagbar')
    endif
endif
" ------------------------------
" tags
" ------------------------------
if get(g:, 'ctags_type', '') != ''
    if Planned('leaderf')
        call s:add_symbol("leaderftags")
    elseif Planned('fzf.vim')
        call s:add_symbol("fzftags")
        if has('nvim') || v:version >= 802
            call s:add_symbol('quickui')
        endif
    else
        call s:add_symbol("ctrlptags")
    endif
    if v:version >= 800 && g:complete_engine != 'apm'
        call s:add_symbol("gutentags")
        if get(g:, 'gtags_version', 0) > 6.0606
            if executable('gtags-cscope') && exists('$GTAGSCONF') && filereadable($GTAGSCONF)
                call s:add_symbol('plus')
            endif
        endif
    endif
endif
" ------------------------------
" install
" ------------------------------
if s:planned_symbol('gutentags')
    PlugAdd 'skywind3000/vim-gutentags'
endif
if s:planned_symbol('plus')
    PlugAdd 'skywind3000/gutentags_plus'
endif
if s:planned_symbol('vista')
    PlugAddOpt 'vista.vim'
elseif s:planned_symbol('tagbar')
    PlugAddOpt 'tagbar'
endif
