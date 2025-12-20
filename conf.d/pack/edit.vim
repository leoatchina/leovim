" ------------------------------
" vim-header
" ------------------------------
if get(g:, 'header_field_author', '') != ''
    let g:header_auto_add_header = 0
    let g:header_auto_update_header = 0
    let g:header_field_timestamp_format = '%Y.%m.%d'
    PlugAdd 'vim-header'
    nnoremap <M-k>a :AddHeader<Cr>
endif
" --------------------------
" easyalign
" --------------------------
let g:easy_align_delimiters = {}
let g:easy_align_delimiters['#'] = {'pattern': '#', 'ignore_groups': ['String']}
let g:easy_align_delimiters['*'] = {'pattern': '*', 'ignore_groups': ['String']}
PlugAdd 'vim-easy-align'
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
xmap g, ga*,
xmap g= ga*=
xmap g: ga*:
xmap g<Space> ga*<Space>
" ----------------------------
" pairs
" ----------------------------
if pack#planned_lsp()
    PlugAdd 'windwp/nvim-autopairs'
else
    if g:python_version > 3 && has('nvim') && utils#is_unix()
        function! UpdateRemotePlugins(...)
            let &rtp=&rtp
            UpdateRemotePlugins
        endfunction
        Plug 'gelguy/wilder.nvim', { 'do': function('UpdateRemotePlugins') }
    elseif !has('nvim') && v:version >= 801 || has('nvim') && !utils#is_win()
        PlugAdd 'gelguy/wilder.nvim'
    endif
    if v:version >= 800
        PlugAdd 'tmsvg/pear-tree'
    elseif has('patch-7.4.849')
        PlugAdd 'jiangmiao/auto-pairs'
    endif
endif
" ------------------------------
" undo
" ------------------------------
if has('nvim') && utils#is_unix()
    PlugAdd 'kevinhwang91/nvim-fundo'
endif
PlugAdd 'undotree'
" ----------------------------
" indentLine plugins
" ----------------------------
if has('nvim')
    PlugAdd 'lukas-reineke/indent-blankline.nvim'
elseif has('conceal')
    PlugAdd 'Yggdroot/indentLine'
endif
" ------------------------------
" marks
" ------------------------------
PlugAdd 'kshenoy/vim-signature'
" ------------------------------
" translate
" ------------------------------
if pack#get('translate') && v:version >= 800 && g:python_version >= 3.06
    PlugAdd 'voldikss/vim-translator'
endif
