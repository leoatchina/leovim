" -------------------
" vim-preview
" -------------------
let g:preview#preview_position = "rightbottom"
let g:preview#preview_size = get(g:, 'asyncrun_open', 8)
nnoremap <silent><C-w><Space> <C-w>z:call preview#cmdmsg('close preview', 0)<Cr>
PlugAdd 'vim-preview'
" -------------------
" vim-quickui
" -------------------
if v:version >= 802 || has('nvim')
    let g:quickui_preview_h = 24
    PlugAdd 'vim-quickui'
endif
if get(g:, 'leovim_whichkey', 1)
    let g:which_key_group_dicts = ''
    let g:which_key_use_floating_win = g:has_popup_floating
    PlugAdd 'vim-which-key'
endif
PlugAdd 'vim-startify'
if has('nvim') || has('patch-8.0.902')
    PlugAdd 'vim-signify'
endif
" ----------------
" fzf
" ----------------
if pack#planned_fzf()
    PlugAdd 'fzf-registers'
    PlugAdd 'fzf-tabs'
    nnoremap <silent>gt :FzfTabs<Cr>
endif
" --------------------------------
" tags
" --------------------------------
PlugAdd 'vim-funky'
if g:has_popup_floating
    let g:matchup_matchparen_offscreen = {'methed': 'popup'}
else
    let g:matchup_matchparen_offscreen = {'methed': 'status_manual'}
endif
PlugAdd 'vim-matchup'
" --------------------------------
" lightline
" --------------------------------
PlugAdd 'lightline.vim'
PlugAdd 'lightline-bufferline'
if !has("nvim")
    let g:lightline#asyncrun#indicator_none = ''
    let g:lightline.component_expand.asyncrun_status = 'lightline#asyncrun#status'
    let g:lightline.active.right += [['asyncrun_status']]
    PlugAdd 'lightline-asyncrun'
endif
" --------------------------------
" run and terminal
" --------------------------------
if has('nvim') || has('timers') && has('channel') && has('job')
    PlugAdd 'asyncrun.vim'
endif
if has('nvim') || v:version >= 801
    PlugAdd 'asynctasks.vim'
endif
if g:has_terminal
    PlugAdd 'vim-floaterm'
    PlugAdd 'vim-floaterm-enhance'
endif
if utils#is_unix() && utils#has_gui() == 0 && executable('tmux') && v:version >= 800
    PlugAdd 'vim-tmux-navigator'
    PlugAdd 'vim-tmux-clipboard'
endif
" ------------------------------
" vim-complete
" ------------------------------
if g:complete_engine == 'mcm'
    PlugAdd 'vim-dict'
endif
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
" --------------------------
" easyalign
" --------------------------
if !pack#planned_leaderf() && !pack#planned_fzf()
    source $CFG_DIR/ctrlp.vim
    PlugAdd 'ctrlp.vim'
endif
" --------------------------
" sidebar
" --------------------------
PlugAdd 'vim-sidebar-manager'
if v:version >= 801 || has('nvim')
    let g:fern_disable_startup_warnings = 1
    let g:fern#renderer = "nerdfont"
    PlugAdd 'vim-fern'
    PlugAdd 'vim-nerdfont'
    PlugAdd 'vim-glyph-palette'
    PlugAdd 'vim-fern-git-status'
    PlugAdd 'vim-fern-hijack'
    PlugAdd 'vim-fern-renderer-nerdfont'
    augroup my-glyph-palette
        autocmd!
        autocmd FileType fern,startify call glyph_palette#apply()
    augroup END
else
    PlugAdd 'vim-vinegar'
endif
