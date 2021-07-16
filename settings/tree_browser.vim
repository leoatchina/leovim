" --------------------
" tree_browser
" --------------------
if get(g:, 'tree_browser', '') == 'coc'
    function! CocBrowser(type) abort
        if a:type == 1
            exec("CocCommand explorer --no-toggle --width 30")
        else
            exec("CocCommand explorer --toggle")
        endif
    endfunction
    command! CocBrowserOpen  call CocBrowser(1)
    command! CocBrowserClose call CocBrowser(0)
elseif Installed('fern.vim')
    let g:tree_browser = 'fern'
    let g:fern#renderer#default#leaf_symbol = ' '
    nnoremap <silent> <leader>N :Fern . -drawer -reveal=%<Cr>
    nnoremap <silent> <leader>O :Fern . -reveal=%<Cr>
else
    " --------------------------
    " netrw with vim-vinegar
    " --------------------------
    let g:tree_browser       = 'netrw'
    let g:netrw_banner       = 0
    let g:netrw_liststyle    = 3
    let g:netrw_browse_split = 4
    let g:netrw_winsize      = 16
    if !exists('g:leovim_loaded')
        set rtp+=$ADDINS_PATH/vim-vinegar
    endif
    function! CloseNetrw()
        try
            let expl_win_num = bufwinnr(t:expl_buf_num)
            if expl_win_num != -1
                let cur_win_nr = winnr()
                exec expl_win_num . 'wincmd w'
                close
                execute winbufnr(cur_win_nr) . "wincmd w"
            endif
        catch /.*/
            " PASS
        endtry
        unlet t:expl_buf_num
    endfunction
    command! CloseNetrw call CloseNetrw()
    function! OpenNetrw()
        Vexplore
        let t:expl_buf_num = bufnr("%")
        execute winnr('#') . "wincmd w"
    endfunction
    command! OpenNetrw call OpenNetrw()
    function! ToggleNetrw()
        if exists("t:expl_buf_num")
            CloseNetrw
        else
            OpenNetrw
        endif
    endfunction
    command! ToggleNetrw call ToggleNetrw()
    if !Installed('sidebar.vim')
        nnoremap <leader>n :ToggleNetrw<CR>
    endif
endif
