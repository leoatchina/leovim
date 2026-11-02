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
    imap <expr><silent><Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
    imap <expr><silent><S-Tab> pumvisible() ? "\<C-p>" : "\<C-h>"
    " NOTE: 必须用 imap（递归），<expr> 返回 <Plug> 才会被再次映射；
    " inoremap 的返回值不再走映射，会把 <Plug>(...) 字面插入 buffer
    imap <expr><silent><Cr> vsnip#expandable() ? "\<Plug>(vsnip-expand)"
                \ : vsnip#jumpable(1) ? "\<Plug>(vsnip-jump-next)"
                \ : pumvisible() && complete_info().selected >= 0 ? "\<C-y>"
                \ : "\<Cr>"
    smap <expr><silent><Tab> vsnip#jumpable(1) ? "\<Plug>(vsnip-jump-next)" : "\<Tab>"
    imap <expr><silent><down> mucomplete#extend_fwd("\<down>")
else
    let g:mucomplete#chains.default = ['path', 'omni', 'keyn', 'dict']
endif
let g:mucomplete#chains.markdown = ['path', 'cmd', 'keyn']
