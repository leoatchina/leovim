if Installed('vimspector')
    let g:debug_tool = "vimspector"
    let g:vimspector_enable_mappings = 'HUMAN'
    "  breakpoint
    nmap <silent> ,C     :call vimspector#ClearBreakpoints()<Cr>
    nmap <silent> ,B     :call vimspector#ListBreakpoints()<Cr>
    nmap <silent> ,b     <Plug>VimspectorToggleBreakpoint
    nmap <silent> <F7>   <Plug>VimspectorToggleConditionalBreakpoint
    nmap <silent> <M-u>b <Plug>VimspectorToggleConditionalBreakpoint
    nmap <silent> <M-u>f <Plug>VimspectorAddFunctionBreakpoint
    "  run
    nmap <silent> ,r :call vimspector#Restart()<Cr>
    nmap <silent> ,d <Plug>VimspectorContinue
    nmap <silent> ,D <Plug>VimspectorRunToCursor
    nmap <silent> ,s <Plug>VimspectorStepOver
    nmap <silent> ,i <Plug>VimspectorStepInto
    nmap <silent> ,o <Plug>VimspectorStepOut
    "  jump to windows in vimspector
    nnoremap <M-m>o :call GoToVimspectorWindow('output')<Cr>
    nnoremap <M-m>e :call GoToVimspectorWindow('stderr')<Cr>
    nnoremap <M-m>s :call GoToVimspectorWindow('server')<Cr>
    nnoremap <M-m>c :call GoToVimspectorWindow('Console')<Cr>
    nnoremap <M-m>t :call GoToVimspectorWindow('Telemetry')<Cr>
    nnoremap <M-m>v :call GoToVimspectorWindow('Vimspector')<Cr>
    nnoremap <M-m>1 :call GoToVimspectorWindow('variables')<Cr>
    nnoremap <M-m>2 :call GoToVimspectorWindow('watches')<Cr>
    nnoremap <M-m>3 :call GoToVimspectorWindow('stacktrace')<Cr>
    nnoremap <M-m>4 :call GoToVimspectorWindow('code')<Cr>
    nnoremap <M-m>5 :call GoToVimspectorWindow('terminal')<Cr>
    "  others
    nnoremap <M-u>; :Vimspector
    nnoremap <M-u>, :call vimspector#
    nnoremap <M-u>p :call vimspector#Pause()<Cr>
    nnoremap <M-u>q :call vimspector#Stop()<Cr>
    nnoremap <M-u>r :call vimspector#Reset()<Cr>
    nnoremap <M-u>u :VimspectorUpdate<Cr>
    nnoremap <M-u>e :VimspectorEval
    nnoremap <M-u>w :VimspectorWatch
    nnoremap <M-u>l :call vimspector#Launch()<Cr>
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
    nnoremap <leader>pe :A<Cr>
    nnoremap <leader>pa :A<Space>
    nnoremap <leader>ps :AS<Space>
    nnoremap <leader>pv :AV<Space>
    nnoremap <leader>pt :AT<Space>
    nnoremap <leader>pd :AD<Space>
    nnoremap <leader>pc :Pcd<Space>
    nnoremap <leader>pl :Plcd<Space>
    nnoremap <leader>pp :ProjectDo<Space>
endif
