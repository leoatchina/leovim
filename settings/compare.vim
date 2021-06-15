" conflict-marker
if Installed('conflict-marker.vim')
    let g:conflict_marker_enable_mappings = 0
    nnoremap <leader>ct :ConflictMarkerThemselves<Cr>
    nnoremap <leader>co :ConflictMarkerOurselves<Cr>
    nnoremap <leader>ce :ConflictMarkerNone<Cr>
    nnoremap <leader>cb :ConflictMarkerBoth<Cr>
    nnoremap <leader>cn :ConflictMarkerNextHunk<Cr>
    nnoremap <leader>cp :ConflictMarkerPrevHunk<Cr>
endif
" signify
if Installed('vim-signify')
    let g:signify_disable_by_default = 1
    nnoremap \<Cr>    :SignifyDiff<Cr>
    nnoremap \<Tab>   :SignifyToggle<Cr>
    nnoremap \<Space> :Signify<Tab>
    nmap ]c <plug>(signify-next-hunk)
    nmap [c <plug>(signify-prev-hunk)
    omap ic <plug>(signify-motion-inner-pending)
    xmap ic <plug>(signify-motion-inner-visual)
    omap ac <plug>(signify-motion-outer-pending)
    xmap ac <plug>(signify-motion-outer-visual)
    nmap <leader>vc vic
    nmap ,vc        vac
endif
