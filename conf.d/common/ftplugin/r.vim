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
    function! ToggleEnvLib() abort
        if string(g:SendCmdToR) == "function('SendCmdToR_fake')"
            call RWarningMsg("The Object Browser can be opened only if R is running. Press <M-B> to StartR.")
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
            if t:robjrb_status == 2
                let g:rplugin.curview = "GlobalEnv"
                call JobStdin(g:rplugin.jobs["Server"], "31\n")
                let t:robjrb_status = 1
            elseif t:robjrb_status == 1
                let g:rplugin.curview = "libraries"
                call JobStdin(g:rplugin.jobs["Server"], "321\n")
                let t:robjrb_status = 2
            endif
        endif
    endfunction
    function! ToggleRObjBrowser() abort
        if string(g:SendCmdToR) == "function('SendCmdToR_fake')"
            call RWarningMsg("The Object Browser can be opened only if R is running. Press <M-B> to StartR.")
            return
        elseif string(g:SendCmdToR) == "function('SendCmdToR_NotYet')"
            call RWarningMsg("R is not ready yet")
            return
        endif
        if get(t:, 'robjrb_status', 0) == 0
            call RObjBrowser()
            let t:robjrb_status = 1
            execute "wincmd p"
        else
            call RObjBrowser()
            let t:robjrb_status = 0
        endif
    endfunction
    nnoremap <buffer><silent><M-B> :call ToggleRObjBrowser()<Cr>
    nnoremap <buffer><silent><M-M> :call ToggleEnvLib()<Cr>
    au FileType rbrowser nnoremap <silent><M-B> :call ToggleRObjBrowser()<Cr>
    au FileType rbrowser nnoremap <silent><M-M> :call ToggleEnvLib()<Cr>
    " view variable
    nnoremap <buffer><silent>J :call RAction('print')<CR>
    nnoremap <buffer><silent>- :call RAction('viewobj')<CR>
    " send
    nnoremap <buffer><silent>\B :call SendAboveLinesToR()<CR>
    nnoremap <buffer><silent>\E VG:call SendLineToR('down')<CR>
    nnoremap <buffer><silent>\A ggVG:call SendLineToR('down')<CR>
    nnoremap <buffer><silent><M-e>i :call SendLineToRAndInsertOutput()<CR>^
    nnoremap <buffer><silent><M-e>f :call SendFunctionToR('echo', "down")<CR>
    nnoremap <buffer><silent><M-e>h :call SendLineToR("stay")<CR>
    nnoremap <buffer><silent><M-e>j :call SendLineToR("down")<CR>
    nnoremap <buffer><silent><M-e>J viB:call SendLineToR("down")<CR>
    " clear
    nnoremap <buffer><M-e>c :call RClearConsole()<Cr>
    nnoremap <buffer><M-e>C :call RClearAll()<Cr>
    " run
    nnoremap <buffer><M-R>  :call StartR('R')<Cr>
    nnoremap <buffer><Tab>q :call RQuit('nosave')<Cr>
    nnoremap <buffer><Tab>Q :call RQuit('save')<Cr>
elseif !exists('g:vscode')
    nnoremap <buffer><M-R> :echo "Please install Nvim-R to run StartR()."<Cr>
    nnoremap <buffer><M-B> :echo "Please install Nvim-R to browser Envs."<Cr>
    nnoremap <buffer><M-M> :echo "Please install Nvim-R to toggle Envs."<Cr>
endif
inoremap <buffer><< <-
inoremap <buffer>>> ->
inoremap <buffer>?? %>%
inoremap <buffer>!! !=
inoremap <buffer><M-e> # %%
inoremap <buffer><M-d> # STEP
inoremap <buffer><M-m> # In[]<Left>
