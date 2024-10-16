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
if Installed('vim-vsnip', 'vim-vsnip-integ')
    let g:mucomplete#chains.default = ['path', 'omni', 'vsnip', 'keyn', 'dict']
else
    let g:mucomplete#chains.default = ['path', 'omni', 'keyn', 'dict']
endif
" other
let g:mucomplete#chains.markdown = ['path', 'cmd', 'keyn']
PlugAddOpt 'vim-mucomplete'
