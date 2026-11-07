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
if pack#planned_lsp()
    call s:add_symbol('nvimlsp')
    call s:add_symbol('aerial')
    call s:add_symbol('vista')
elseif pack#planned_coc()
    call s:add_symbol('coc')
    call s:add_symbol('vista')
elseif v:version >= 800 && get(g:, 'ctags_type', '') =~ 'Universal'
    call s:add_symbol('vista')
elseif get(g:, 'ctags_type', '') != ''
    call s:add_symbol('tagbar')
endif
" ------------------------------
" tags
" ------------------------------
if get(g:, 'ctags_type', '') != ''
    " tags reader: single choice, keep priority in sync with main/plugin/tags.vim
    let g:tags_tool = ''
    if pack#installed_fuzzbox()
        let g:tags_tool = 'fuzzboxtags'
    elseif pack#installed_leaderf()
        let g:tags_tool = 'leaderftags'
    elseif pack#installed_fzf()
        let g:tags_tool = 'fzftags'
    endif
    if v:version >= 800
        call s:add_symbol("gutentags")
        if get(g:, 'gtags_version', 0) > 6.0606 && exists('$GTAGSCONF') && filereadable($GTAGSCONF)
                    \ && executable('global') && executable('gtags-cscope')
            call s:add_symbol('plus')
        endif
    endif
endif
PackAdd 'vim-funky'
if g:has_popup_floating
    let g:matchup_matchparen_offscreen = {'method': 'popup'}
else
    let g:matchup_matchparen_offscreen = {'method': 'status_manual'}
endif
PackAdd 'vim-matchup'
" ------------------------------
" install
" ------------------------------
if s:planned_symbol('gutentags')
    PackAdd 'skywind3000/vim-gutentags', {'vim': 'gutentags'}
endif
if s:planned_symbol('plus')
    PackAdd 'skywind3000/gutentags_plus'
endif
if s:planned_symbol('aerial')
    PackAdd 'stevearc/aerial.nvim', {'lua': 'cfg.aerial', 'on': '^Aerial.*'}
endif
if s:planned_symbol('vista')
    PackAdd 'vista.vim', {'vim': 'vista'}
elseif s:planned_symbol('tagbar')
    PackAdd 'tagbar', {'vim': 'tagbar'}
endif
