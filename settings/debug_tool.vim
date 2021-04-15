if Installed('vimspector')
    let g:debug_tool = "vimspector"
    let g:vimspector_enable_mappings = 'HUMAN'
    nmap <M-b> <Plug>VimspectorContinue
    nmap <M-B> <Plug>VimspectorRunToCursor
    nmap <silent> ,b <Plug>VimspectorToggleBreakpoint
    nmap <silent> ,B :call vimspector#ListBreakpoints()<Cr>
    nmap <silent> ,d :call vimspector#ClearLineBreakpoint(expand('%:p'), line('.'))<Cr>
    nmap <silent> ,D :call vimspector#ClearBreakpoints()<Cr>
    nmap <silent> ,r :call vimspector#Restart()<Cr>
    nmap <silent> ,o <Plug>VimspectorStepOver
    nmap <silent> ,n <Plug>VimspectorStepInto
    nmap <silent> ,u <Plug>VimspectorStepOut
    nmap <silent> <M-u>b <Plug>VimspectorToggleConditionalBreakpoint
    nmap <silent> <M-u>f <Plug>VimspectorAddFunctionBreakpoint
    nmap <silent> <M-u>u :VimspectorUpdate<Cr>
    " ========== jump to windows in vimspector
    nnoremap <M-u>o :call GoToVimspectorWindow('output')<Cr>
    nnoremap <M-u>s :call GoToVimspectorWindow('server')<Cr>
    nnoremap <M-u>e :call GoToVimspectorWindow('stderr')<Cr>
    nnoremap <M-u>c :call GoToVimspectorWindow('Console')<Cr>
    nnoremap <M-u>t :call GoToVimspectorWindow('Telemetry')<Cr>
    nnoremap <M-u>v :call GoToVimspectorWindow('Vimspector')<Cr>
    nnoremap <M-u>1 :call GoToVimspectorWindow('variables')<Cr>
    nnoremap <M-u>2 :call GoToVimspectorWindow('watches')<Cr>
    nnoremap <M-u>3 :call GoToVimspectorWindow('stacktrace')<Cr>
    nnoremap <M-u>4 :call GoToVimspectorWindow('code')<Cr>
    nnoremap <M-u>5 :call GoToVimspectorWindow('terminal')<Cr>
    " ========== others
    nnoremap <M-u>; :Vimspector
    nnoremap <M-u>, :call vimspector#
    nnoremap <M-u>. :VimspectorEval
    nnoremap <M-u>p :call vimspector#Pause()<Cr>
    nnoremap <M-u>q :call vimspector#Stop()<Cr>
    nnoremap <M-u>r :call vimspector#Reset()<Cr>
    nnoremap <M-u>l :call vimspector#Launch()<Cr>
    nnoremap <M-u>w :VimspectorWatch
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
    nnoremap <leader>ma :A<Space>
    nnoremap <leader>me :A<Cr>
    nnoremap <leader>mx :AS<Space>
    nnoremap <leader>mv :AV<Space>
    nnoremap <leader>mt :AT<Space>
    nnoremap <leader>md :AD<Space>
    nnoremap <leader>mc :Pcd<Space>
    nnoremap <leader>ml :Plcd<Space>
    nnoremap <leader>mp :ProjectDo<Space>
endif
