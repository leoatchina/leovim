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
let g:mucomplete#chains.vim = ['path', 'cmd', 'keyn']
PlugAddOpt 'vim-mucomplete'
function! MapTabCr(istab) abort
    let istab = a:istab
    if pumvisible()
        if istab
            if empty(get(v:, 'completed_item', {}))
                return "\<C-n>"
            elseif Installed('vim-vsnip', 'vim-vsnip-integ') && vsnip#available(1)
                return "\<Plug>(vsnip-expand-or-jump)"
            else
                return "\<C-y>"
            endif
        else
            return "\<C-y>"
        endif
    else
        if istab
            return "\<Tab>"
        else
            return "\<Cr>"
        endif
    endif
endfunction
au WinEnter,BufEnter * imap <silent><Tab> <C-R>=MapTabCr(1)<Cr>
au WinEnter,BufEnter * imap <silent><Cr>  <C-R>=MapTabCr(0)<Cr>
au WinEnter,BufEnter * imap <expr><down>  mucomplete#extend_fwd("\<down>")
au WinEnter,BufEnter * imap <expr><C-e>   pumvisible()? "\<C-e>" : "\<C-O>A"
" vsnip
if Installed('vim-vsnip', 'vim-vsnip-integ')
    let g:mucomplete#chains.default = ['path', 'omni', 'keyn', 'vsnip', 'dict']
else
    let g:mucomplete#chains.default = ['path', 'omni', 'keyn', 'dict']
endif
