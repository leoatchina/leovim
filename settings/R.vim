if Installed("Nvim-R")
    let R_assign_map     = '<M-->'
    let R_objbr_place    = 'RIGHT'
    let R_objbr_opendf   = 0
    let R_objbr_openlist = 0
    " console size
    let R_rconsole_height = 14
    let R_objrb_w         = 50
    let R_rconsole_width  = 0
    let R_min_editor_width  = 18
    au VimResized * let R_objrb_w = 50
    au VimResized * let R_rconsole_height = 14
    au VimResized * let R_rconsole_width = winwidth(0) - R_objrb_w
    " toggle between GlobalEnv or Libraries
    function! ToggleEnvLib()
        if string(g:SendCmdToR) == "function('SendCmdToR_fake')"
            call RWarningMsg("The Object Browser can be opened only if R is running.")
            return
        endif
        if get(t:, 'robjrb_status', 0) == 0
            let s:filetype = &filetype
            let g:rplugin.curview = "GlobalEnv"
            call RObjBrowser()
            call UpdateOB('both')
            call SendToNvimcom("\004G RBrowserDoubleClick")
            let t:robjrb_status = 1
            if s:filetype != 'rbrowser'
                execute "wincmd h"
                if &buftype[0:3] == 'term'
                    execute "wincmd k"
                endif
            endif
            redraw
        elseif t:robjrb_status == 1
            call UpdateOB('both')
            if g:rplugin.curview == "libraries"
                let g:rplugin.curview = "GlobalEnv"
                call SendToNvimcom("\004G RBrowserDoubleClick")
            else
                let g:rplugin.curview = "libraries"
                call SendToNvimcom("\004L RBrowserDoubleClick")
            endif
        endif
    endfunction
    " nvimR map
    command! ToggleEnvLib call ToggleEnvLib()
    command! ToggleObjBrw call RObjBrowser()
    let g:sidebars.robjb = {
                \ 'position': 'right',
                \ 'check_win': {nr -> getwinvar(nr, '&filetype') ==# 'rbrowser'},
                \ 'open': 'ToggleObjBrw',
                \ 'close': 'ToggleObjBrw'
                \ }
    au FileType r nnoremap <silent> <M-T> :call sidebar#toggle('robjb')<CR>
    au FileType r nnoremap <M-A>  :ToggleEnvLib<Cr>
    au FileType r nnoremap <M-d>  :call SendFunctionToR('echo', "down")<CR>
    au FileType r nnoremap <M-e>  :call SendLineToR("down")<CR>
    au FileType r xnoremap <M-e>  :call SendLineToR("down")<CR>
    au FileType r nnoremap <M-y>s :call RClearConsole()<Cr>
    au FileType r nnoremap <M-y>S :call RClearAll()<Cr>
    " start nvimr
    au FileType r nnoremap <leader>R :call StartR('R')<Cr>
    au FileType r nnoremap ,R        :call StartR('custom')<Cr>
    au FileType r nnoremap <leader>S :RStop<Cr>
    " run r script
    if get(g:, 'terminal_plus', '') =~ 'floaterm'
        au FileType r nnoremap <M-R> :AsyncRun! -mode=term -pos=floaterm Rscript %
    elseif g:has_terminal > 0
        au FileType r nnoremap <M-R> :AsyncRun! -mode=term -pos=tab -focus=1 Rscript %
    else
        au FileType r nnoremap <M-R> :AsyncRun! Rscript %
    endif
    if g:has_terminal > 0
        au FileType r nnoremap <leader>rt :AsyncRun! -mode=term -pos=tab -focus=1 Rscript %
    endif
    if get(g:, 'terminal_plus', '') =~ 'floaterm'
        au FileType r nnoremap <leader>rf :AsyncRun! -mode=term -pos=floaterm Rscript %
    endif
    au FileType r nnoremap <leader>rr :AsyncRun! Rscript %
    au FileType r nnoremap <leader>rb :call SendAboveLinesToR()<CR>
    au FileType r nnoremap <leader>re VG:call SendLineToR('down')<CR>
    au FileType r nnoremap <leader>ri :call SendLineToRAndInsertOutput()<CR>0
    au FileType r nnoremap <leader>rt :call RAction('viewobj')<CR>
    au FileType r nnoremap <leader>rc :call MovePosRCodeComment('normal')<CR>
    if $TMUX != '' && get(g:, '', '') == ''
        let R_in_buffer     = 0
        let R_externam_term = 'tilix -a session-add-down -e'
        let R_source        = '~/.leovim.conf/addins/tmux_split.vim'
    elseif get(g:, 'R_externam_term', '') != ''
        let R_in_buffer = 0
    else
        let R_in_buffer = 1
    endif
endif
