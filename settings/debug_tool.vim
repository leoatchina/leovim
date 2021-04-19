if Installed('vimspector')
    let g:debug_tool = "vimspector"
    let g:vimspector_enable_mappings = 'HUMAN'
    "  breakpoint
    nmap <silent> ,b     <Plug>VimspectorToggleBreakpoint
    nmap <silent> ,B     :call vimspector#ListBreakpoints()<Cr>
    nmap <silent> <M-B>  :call vimspector#ClearBreakpoints()<Cr>
    nmap <silent> <M-b>b <Plug>VimspectorToggleConditionalBreakpoint
    nmap <silent> <M-b>f <Plug>VimspectorAddFunctionBreakpoint
    " ==================== run
    nmap <silent> ,d <Plug>VimspectorContinue
    nmap <silent> ,D <Plug>VimspectorRunToCursor
    nmap <silent> ,r :call vimspector#Restart()<Cr>
    nmap <silent> ,o <Plug>VimspectorStepOver
    nmap <silent> ,n <Plug>VimspectorStepInto
    nmap <silent> ,u <Plug>VimspectorStepOut
    nnoremap <M-b>e :VimspectorEval
    nnoremap <M-b>w :VimspectorWatch
    " ========== jump to windows in vimspector
    nnoremap <M-b>o :call GoToVimspectorWindow('output')<Cr>
    nnoremap <M-b>d :call GoToVimspectorWindow('stderr')<Cr>
    nnoremap <M-b>s :call GoToVimspectorWindow('server')<Cr>
    nnoremap <M-b>c :call GoToVimspectorWindow('Console')<Cr>
    nnoremap <M-b>t :call GoToVimspectorWindow('Telemetry')<Cr>
    nnoremap <M-b>v :call GoToVimspectorWindow('Vimspector')<Cr>
    nnoremap ,1 :call GoToVimspectorWindow('variables')<Cr>
    nnoremap ,2 :call GoToVimspectorWindow('watches')<Cr>
    nnoremap ,3 :call GoToVimspectorWindow('stacktrace')<Cr>
    nnoremap ,4 :call GoToVimspectorWindow('code')<Cr>
    nnoremap ,5 :call GoToVimspectorWindow('terminal')<Cr>
    " ========== others
    nnoremap <M-b>; :Vimspector
    nnoremap <M-b>, :call vimspector#
    nnoremap <M-b>p :call vimspector#Pause()<Cr>
    nnoremap <M-b>q :call vimspector#Stop()<Cr>
    nnoremap <M-b>r :call vimspector#Reset()<Cr>
    nnoremap <M-b>l :call vimspector#Launch()<Cr>
    nnoremap <M-b>u :VimspectorUpdate<Cr>
    function! GoToVimspectorWindow(name) abort
        let windowNr = 0
        let name = a:name
        try
            if name ==# 'variables'
                let windowNr = bufwinnr('vimspector.Variables')
            elseif name ==# 'watches'
                let windowNr = bufwinnr('vimspector.Watches')
            elseif name ==# 'stacktrace'
                let windowNr = bufwinnr('vimspector.StackTrace')
            elseif name ==# 'terminal' || name ==# 'code'
                let windowNr = bufwinnr(winbufnr(g:vimspector_session_windows[name]))
            else
                call vimspector#ShowOutput(name)
            endif
        catch
            " pass
        endtry
        if windowNr > 0
            execute windowNr . 'wincmd w'
        endif
    endfunction
endif
if Installed("vim-projectionist")
    nnoremap <leader>me :A<Cr>
    nnoremap <leader>ma :A<Space>
    nnoremap <leader>ms :AS<Space>
    nnoremap <leader>mv :AV<Space>
    nnoremap <leader>mt :AT<Space>
    nnoremap <leader>md :AD<Space>
    nnoremap <leader>mc :Pcd<Space>
    nnoremap <leader>ml :Plcd<Space>
    nnoremap <leader>mp :ProjectDo<Space>
endif
