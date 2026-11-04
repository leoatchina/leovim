if utils#is_vscode() || !pack#installed('vim-floaterm-enhance')
    finish
endif
nnoremap <M-r><M-i> <C-w><C-w>
xnoremap <M-r><M-i> <ESC><C-w><C-w>
tnoremap <M-r><M-i> <C-\><C-n><C-w><C-w>
" NOTE: ! means keep in current line
nnoremap <silent><M-r><M-r> :FloatermReplStart<Cr>
nnoremap <silent><M-r><Cr> :FloatermReplSendCrOrStart!<Cr>
" repl line send
nnoremap <silent><M-r>n :FloatermReplSend<Cr>
nnoremap <silent><M-r>l :FloatermReplSend!<Cr>
xnoremap <silent><M-r>n :FloatermReplSend<Cr>
xnoremap <silent><M-r>l :FloatermReplSend!<Cr>
nnoremap <silent><M-r>q :FloatermReplSendExit<Cr>
nnoremap <silent><M-r>L :FloatermReplSendClear<Cr>
" repl block send
xnoremap <silent><M-r><M-r>   :FloatermReplSend<Cr>
xnoremap <silent><M-r><Space> :FloatermReplSend!<Cr>
nnoremap <silent><M-r><M-r>   :FloatermReplSendBlock<Cr>
nnoremap <silent><M-r><Space> :FloatermReplSendBlock!<Cr>
" repl send above/below/all lines
nnoremap <silent><M-r>b :FloatermReplSendFromBegin!<Cr>
nnoremap <silent><M-r>e :FloatermReplSendToEnd!<Cr>
nnoremap <silent><M-r>a :FloatermReplSendAll!<Cr>
" repl send word
nnoremap <silent><M-r>k :FloatermReplSendWord<Cr>
xnoremap <silent><M-r>k :FloatermReplSendWord<Cr>
" repl mark print send
nnoremap <silent><M-r>m :FloatermReplMark<Cr>
xnoremap <silent><M-r>m :FloatermReplMark<Cr>
nnoremap <silent><M-r>s :FloatermReplSendMark<Cr>
nnoremap <silent><M-r>S :FloatermReplShowMark<Cr>
" ---------------------------------------
" jupynvim
" ---------------------------------------
if pack#installed('jupynium.nvim')
    " set url
    let g:jupynium_ip = get(g:, 'jupynium_ip', 'localhost')
    let g:jupynium_port = get(g:, 'jupynium_port', 9999)
    let g:jupynium_protocal = get(g:, 'jupynium_protocal', 'http')
    let g:jupynium_url = get(g:, 'jupynium_url', printf("%s://%s:%d/nbclassic", g:jupynium_protocal, g:jupynium_ip, g:jupynium_port))
    " self defined function
    function! s:jupynium_run(...)
        let jupynium_urls = get(g:, 'jupynium_urls', [g:jupynium_url])
        if len(jupynium_urls) == 1
            let t:jupynium_url = jupynium_urls[0]
        else
            let t:jupynium_url = utils#choose_one(jupynium_urls, 'Choose a jupynium url', 1)
        endif
        if empty(t:jupynium_url)
            return
        endif
        try
            if a:0 && a:1 > 0
                execute "JupyniumStartAndAttachToServerInTerminal ". t:jupynium_url
            else
                execute "JupyniumStartAndAttachToServer ". t:jupynium_url
            endif
        catch /.*/
            call preview#errmsg("JupyniumStartAndAttachToServer Error")
        endtry
    endfunction
    command! JupyniumRun call s:jupynium_run()
    command! JupyniumRunInTerminal call s:jupynium_run(1)
    command! JupyniumCommands call FzfCallCommands('JupyniumCommands', 'Jupynium', ['JupyniumRun'])
    function! s:execute_and_forward() abort
        JupyniumExecuteSelectedCells
        let endline = search('^# %%', 'nW')
        if endline == 0
            let endline = line("$")
        elseif endline != line("$")
            let endline += 1
        endif
        execute "normal! " . endline . 'G'
    endfunction
    command JupyniumExecuteSelectedCellsForward call s:execute_and_forward()
    function! s:map() abort
        nnoremap <buffer><silent>M<Cr>    <Cmd>JupyniumRun<Cr>
        nnoremap <buffer><silent>M<Space> <Cmd>JupyniumStartSync <C-r>=get(t:, 'jupynium_url', '')<Cr>
        nnoremap <buffer><silent>MK <Cmd>JupyniumKernelHover<Cr>
        nnoremap <buffer><silent>MH <Cmd>JupyniumKernelSelect<Cr>
        nnoremap <buffer><silent>MT <Cmd>JupyniumRunInTerminal<Cr>
        nnoremap <buffer><silent>MQ <Cmd>JupyniumStopSync<Cr>
        nnoremap <buffer><silent>MB <Cmd>JupyniumScrollToCell<Cr>
        nnoremap <buffer><silent>MU <Cmd>JupyniumScrollUp<Cr>
        nnoremap <buffer><silent>MD <Cmd>JupyniumScrollDown<Cr>
        nnoremap <buffer><silent>ML <Cmd>JupyniumExecuteSelectedCells<Cr>
        xnoremap <buffer><silent>ML <Cmd>JupyniumExecuteSelectedCells<Cr>
        nnoremap <buffer><silent>MC <Cmd>JupyniumClearSelectedCellsOutputs<Cr>
        xnoremap <buffer><silent>MC <Cmd>JupyniumClearSelectedCellsOutputs<Cr>
        nnoremap <buffer><silent>M; <Cmd>JupyniumExecuteSelectedCellsForward<Cr>
        nnoremap <buffer><silent><M-M> <Cmd>JupyniumCommands<Cr>
    endfunction
    au FileType python,r call s:map()
endif

