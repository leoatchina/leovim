if Installed('vimspector')
    let g:debug_tool = "vimspector"
    let g:vimspector_enable_mappings = 'HUMAN'
    "  breakpoint
    nmap <silent> ,b     <Plug>VimspectorToggleBreakpoint
    nmap <silent> ,B     :call vimspector#ListBreakpoints()<Cr>
    nmap <silent> <M-B>  :call vimspector#ClearBreakpoints()<Cr>
    nmap <silent> <M-u>b <Plug>VimspectorToggleConditionalBreakpoint
    nmap <silent> <M-u>f <Plug>VimspectorAddFunctionBreakpoint
    "  run
    nmap <silent> ,d <Plug>VimspectorContinue
    nmap <silent> ,D <Plug>VimspectorRunToCursor
    nmap <silent> ,r :call vimspector#Restart()<Cr>
    nmap <silent> ,o <Plug>VimspectorStepOver
    nmap <silent> ,n <Plug>VimspectorStepInto
    nmap <silent> ,u <Plug>VimspectorStepOut
    nnoremap <M-u>e :VimspectorEval
    nnoremap <M-u>w :VimspectorWatch
    "  jump to windows in vimspector
    nnoremap <M-b>o :call GoToVimspectorWindow('output')<Cr>
    nnoremap <M-b>e :call GoToVimspectorWindow('stderr')<Cr>
    nnoremap <M-b>s :call GoToVimspectorWindow('server')<Cr>
    nnoremap <M-b>c :call GoToVimspectorWindow('Console')<Cr>
    nnoremap <M-b>t :call GoToVimspectorWindow('Telemetry')<Cr>
    nnoremap <M-b>v :call GoToVimspectorWindow('Vimspector')<Cr>
    nnoremap <M-b>1 :call GoToVimspectorWindow('variables')<Cr>
    nnoremap <M-b>2 :call GoToVimspectorWindow('watches')<Cr>
    nnoremap <M-b>3 :call GoToVimspectorWindow('stacktrace')<Cr>
    nnoremap <M-b>4 :call GoToVimspectorWindow('code')<Cr>
    nnoremap <M-b>5 :call GoToVimspectorWindow('terminal')<Cr>
    "  others
    nnoremap <M-u>; :Vimspector
    nnoremap <M-u>, :call vimspector#
    nnoremap <M-u>p :call vimspector#Pause()<Cr>
    nnoremap <M-u>q :call vimspector#Stop()<Cr>
    nnoremap <M-u>r :call vimspector#Reset()<Cr>
    nnoremap <M-u>l :call vimspector#Launch()<Cr>
    nnoremap <M-u>u :VimspectorUpdate<Cr>
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
