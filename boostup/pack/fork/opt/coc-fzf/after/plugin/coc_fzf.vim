" test other plugins availability
augroup CocFzfLocation
    autocmd!
    let g:coc_enable_locationlist = 0
    if g:coc_fzf_location_delay > 0
        " To avoid weird race conditions.
        autocmd User CocLocationsChange nested call timer_start(g:coc_fzf_location_delay, 'CocFzfLocationsVimRun')
        function! CocFzfLocationsVimRun(id)
            call coc_fzf#location#fzf_run()
        endfunction
    else
        autocmd User CocLocationsChange nested call coc_fzf#location#fzf_run()
    endif
augroup END
