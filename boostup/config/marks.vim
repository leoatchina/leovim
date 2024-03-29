if Installed('vim-signature')
    let g:SignatureMap = {
                \ 'Leader'           : "m",
                \ 'ToggleMarkAtLine' : "m<Cr>",
                \ 'PlaceNextMark'    : "m;",
                \ 'PurgeMarksAtLine' : "m,",
                \ 'PurgeMarks'       : "m.",
                \ 'PurgeMarkers'     : "m<Bs>",
                \ 'DeleteMark'       : "dm",
                \ 'ListBufferMarks'   : "m/",
                \ 'ListBufferMarkers' : "m?",
                \ 'GotoNextLineAlpha' : "']",
                \ 'GotoPrevLineAlpha' : "'[",
                \ 'GotoNextSpotAlpha' : "`]",
                \ 'GotoPrevSpotAlpha' : "`[",
                \ 'GotoNextLineByPos' : "]'",
                \ 'GotoPrevLineByPos' : "['",
                \ 'GotoNextSpotByPos' : "]`",
                \ 'GotoPrevSpotByPos' : "[`",
                \ 'GotoNextMarker'    : "]-",
                \ 'GotoPrevMarker'    : "[-",
                \ 'GotoNextMarkerAny' : "]=",
                \ 'GotoPrevMarkerAny' : "[=",
                \ }
endif
if InstalledFzf()
    nnoremap <silent><C-f>m :FzfMarks<CR>
else
    nnoremap <silent><C-f>m :marks<Cr>
endif
" vim-signify
if has('nvim') || has('patch-8.0.902')
    let g:signify_disable_by_default = 0
    nnoremap \<Space> :SignifyDiff<Cr>
    nnoremap \<Tab> :SignifyToggle<Cr>
    nmap ]h <plug>(signify-next-hunk)
    nmap [h <plug>(signify-prev-hunk)
    omap im <plug>(signify-motion-inner-pending)
    xmap im <plug>(signify-motion-inner-visual)
    omap am <plug>(signify-motion-outer-pending)
    xmap am <plug>(signify-motion-outer-visual)
    nmap <leader>vm vim
    nmap <leader>vM vam
    PlugAddOpt 'vim-signify'
    " commands
    command! SignifyCommands call FzfCallCommands('SignifyCommands', 'Signify')
    nnoremap \<Cr> :SignifyCommands<Cr>
endif
