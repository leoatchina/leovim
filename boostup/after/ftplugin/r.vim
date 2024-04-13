setlocal commentstring=#\ %s
if Installed('nvim-r')
    let R_assign_map     = '<M-->'
    let R_rmdchunk       = '``'
    let R_objbr_place    = 'RIGHT'
    let R_objbr_opendf   = 0
    let R_objbr_openlist = 0
    " console size
    let R_rconsole_height = 14
    let R_objrb_w         = 50
    let R_rconsole_width  = 0
    let R_min_editor_width  = 18
    augroup Rresize
        au VimResized * let R_objrb_w = 50
        au VimResized * let R_rconsole_height = 14
        au VimResized * let R_rconsole_width = winwidth(0) - R_objrb_w
    augroup END
    if !exists("*ToggleEnvLib")
        function! ToggleEnvLib() abort
            if string(g:SendCmdToR) == "function('SendCmdToR_fake')"
                call RWarningMsg("The Object Browser can be opened only if R is running.")
                return
            elseif string(g:SendCmdToR) == "function('SendCmdToR_NotYet')"
                call RWarningMsg("R is not ready yet")
                return
            endif
            " NOTE: functions could be found in https://github.com/jalvesaq/Nvim-R/blob/master/ftplugin/rbrowser.vim
            if get(t:, 'robjrb_status', 0) == 0
                call RObjBrowser()
                let t:robjrb_status = 1
                execute "wincmd p"
            else
                call UpdateOB('both')
                if g:rplugin.curview == "libraries"
                    let g:rplugin.curview = "GlobalEnv"
                    call JobStdin(g:rplugin.jobs["ClientServer"], "31\n")
                    let t:robjrb_status = 1
                elseif g:rplugin.curview == "GlobalEnv"
                    let g:rplugin.curview = "libraries"
                    call JobStdin(g:rplugin.jobs["ClientServer"], "321\n")
                    let t:robjrb_status = 2
                endif
            endif
        endfunction
        function! ToggleRObjBrowser() abort
            if get(t:, 'robjrb_status', 0) == 0
                call RObjBrowser()
                let t:robjrb_status = 1
                execute "wincmd p"
            else
                call RObjBrowser()
                let t:robjrb_status = 0
            endif
        endfunction
    endif
    nnoremap <buffer><silent><M-R> :call ToggleRObjBrowser()<Cr>
    nnoremap <buffer><silent><M-F> :call ToggleEnvLib()<Cr>
    " view variable
    nnoremap <buffer><silent>J :call RAction('print')<CR>
    nnoremap <buffer><silent>= :call RAction('viewobj')<CR>
    " send
    nnoremap <buffer><silent>+ :call SendLineToRAndInsertOutput()<CR>^
    nnoremap <buffer><silent>- viB:call SendLineToR("down")<CR>
    nnoremap <buffer><silent>,B :call SendAboveLinesToR()<CR>
    nnoremap <buffer><silent>,E VG:call SendLineToR('down')<CR>
    nnoremap <buffer><silent>,S ggVG:call SendLineToR('down')<CR>
    nnoremap <buffer><silent><M-e>f :call SendFunctionToR('echo', "down")<CR>
    nnoremap <buffer><silent><M-e>h :call SendLineToR("stay")<CR>
    nnoremap <buffer><silent><M-e>j :call SendLineToR("down")<CR>
    " clear
    nnoremap <buffer>_ :call RClearConsole()<Cr>
    nnoremap <buffer><M-_> :call RClearAll()<Cr>
    " run
    nnoremap <buffer><M-B> :call StartR('R')<Cr>
    nnoremap <buffer><M-X> :call RQuit('nosave')<Cr>
    nnoremap <buffer><Tab>q :call RQuit('save')<Cr>
endif
inoremap <buffer><< <-
inoremap <buffer>>> ->
inoremap <buffer>?? %>%
inoremap <buffer>!! !=
inoremap <buffer><M-e> # %%
inoremap <buffer><M-d> # STEP
inoremap <buffer><M-m> # In[]<Left>
