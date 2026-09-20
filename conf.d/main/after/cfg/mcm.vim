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
if pack#installed('vim-vsnip', 'vim-vsnip-integ')
    let g:mucomplete#chains.default = ['path', 'omni', 'vsnip', 'keyn', 'dict']
    function! MapTabCr(key) abort
        if pumvisible()
            if a:key ==? 'tab'
                return "\<C-n>"
            elseif a:key ==? 'stab'
                return "\<C-p>"
            endif
            " <Cr>: 已选中则确认并展开 snippet，未选中则同 <C-e> 结束补全
            let l:selected = exists('*complete_info') ?
                        \ complete_info(['selected']).selected >= 0 :
                        \ !empty(get(v:, 'completed_item', {}))
            return l:selected ? "\<C-y>\<Plug>(vsnip-expand-or-jump)" : "\<C-e>"
        else
            if a:key ==? 'tab'
                return "\<Tab>"
            elseif a:key ==? 'stab'
                return "\<S-Tab>"
            endif
            return "\<Cr>"
        endif
    endfunction
    imap <expr><silent><Tab> MapTabCr('tab')
    imap <expr><silent><S-Tab> MapTabCr('stab')
    imap <expr><silent><Cr> MapTabCr('cr')
    imap <expr><silent><down> mucomplete#extend_fwd("\<down>")
else
    let g:mucomplete#chains.default = ['path', 'omni', 'keyn', 'dict']
endif
let g:mucomplete#chains.markdown = ['path', 'cmd', 'keyn']
