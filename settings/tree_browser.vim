" --------------------
" tree_browser
" --------------------
if Installed('fern.vim')
    let g:tree_browser = 'fern'
    let g:fern#renderer#default#leaf_symbol = ' '
    function! s:init_fern() abort
        " Use 'select' instead of 'edit' for default 'open' action
        set nonu
        nmap <buffer> <Plug>(fern-action-open) <Plug>(fern-action-open:select)
        nmap <buffer> v <Plug>(fern-action-open:vsplit)
        nmap <buffer> x <Plug>(fern-action-open:split)
        nmap <buffer> t <Plug>(fern-action-open:tabedit)
        nmap <buffer> V <Plug>(fern-action-open:edit/vsplit)
        nmap <buffer> X <Plug>(fern-action-open:edit/split)
        nmap <buffer> T <Plug>(fern-action-open:edit/tabedit)
        nmap <buffer> r <Plug>(fern-action-rename)
    endfunction
    augroup init_fern
        autocmd! *
        autocmd FileType fern call s:init_fern()
    augroup END
    nnoremap <silent> <leader>N :Fern . -drawer -reveal=%<Cr>
    nnoremap <silent> <leader>O :Fern . -reveal=%<Cr>
    nnoremap <tab>n :Fern -drawer -stay -toggle<Space>
    nnoremap <tab>o :Fern<Space>
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
    au FileType netrw nmap <buffer> <C-l> <Nop>
    au FileType netrw nmap <buffer> <M-r> <Plug>NetrwFresh
    if !Installed('sidebar.vim')
        nnoremap <leader>n :ToggleNetrw<CR>
    endif
endif
