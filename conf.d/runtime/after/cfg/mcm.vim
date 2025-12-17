let g:no_plugin_maps = 1
let g:mucomplete#force_manual = 0
let g:mucomplete#completion_delay = 0
let g:mucomplete#enable_auto_at_startup = 1
if g:python_version == 0
    let g:jedi#popup_on_dot = 0
    autocmd WinEnter *.py :MUcompleteAutoOff
    autocmd WinLeave *.py :MUcompleteAutoOn
else
    let g:jedi#popup_on_dot = 1
endif
let g:mucomplete#chains = {}
" vsnip
if plug#installed('vim-vsnip', 'vim-vsnip-integ')
    let g:mucomplete#chains.default = ['path', 'omni', 'vsnip', 'keyn', 'dict']
    function! MapTabCr(tab) abort
        if pumvisible()
            if a:tab
                if empty(get(v:, 'completed_item', {}))
                    if vsnip#available(1)
                        return "\<Plug>(vsnip-expand-or-jump)"
                    else
                        return "\<C-n>"
                    endif
                elseif vsnip#available(1)
                    return "\<Plug>(vsnip-expand-or-jump)"
                else
                    return "\<C-y>"
                endif
            else
                return "\<C-y>"
            endif
        else
            if a:tab
                return "\<Tab>"
            else
                return "\<Cr>"
            endif
        endif
    endfunction
    imap <expr><silent><Tab> MapTabCr(1)
    imap <expr><silent><Cr> MapTabCr(0)
    imap <expr><silent><down> mucomplete#extend_fwd("\<down>")
else
    let g:mucomplete#chains.default = ['path', 'omni', 'keyn', 'dict']
endif
let g:mucomplete#chains.markdown = ['path', 'cmd', 'keyn']
" installed this complete
PlugOpt 'vim-mucomplete'
