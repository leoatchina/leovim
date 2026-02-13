if utils#is_vscode() || !pack#installed('vim-floaterm-enhance')
    finish
endif
nnoremap <M-a><M-i> <C-w><C-w>
xnoremap <M-a><M-i> <ESC><C-w><C-w>
tnoremap <M-a><M-i> <C-\><C-n><C-w><C-w>
" NOTE: ! means keep in current line
nnoremap <silent><M-a><M-r> :FloatermReplStart<Cr>
nnoremap <silent><M-a><Cr> :FloatermReplSendCrOrStart!<Cr>
" repl line send
nnoremap <silent><M-a>n :FloatermReplSend<Cr>
nnoremap <silent><M-a>l :FloatermReplSend!<Cr>
xnoremap <silent><M-a>n :FloatermReplSend<Cr>
xnoremap <silent><M-a>l :FloatermReplSend!<Cr>
nnoremap <silent><M-a>q :FloatermReplSendExit<Cr>
nnoremap <silent><M-a>L :FloatermReplSendClear<Cr>
" repl block send
xnoremap <silent><M-a><M-a>   :FloatermReplSend<Cr>
xnoremap <silent><M-a><Space> :FloatermReplSend!<Cr>
nnoremap <silent><M-a><M-a>   :FloatermReplSendBlock<Cr>
nnoremap <silent><M-a><Space> :FloatermReplSendBlock!<Cr>
" repl send above/below/all lines
nnoremap <silent><M-a>b :FloatermReplSendFromBegin!<Cr>
nnoremap <silent><M-a>e :FloatermReplSendToEnd!<Cr>
nnoremap <silent><M-a>a :FloatermReplSendAll!<Cr>
" repl send word
nnoremap <silent><M-a>k :FloatermReplSendWord<Cr>
xnoremap <silent><M-a>k :FloatermReplSendWord<Cr>
" repl mark print send
nnoremap <silent><M-a>m :FloatermReplMark<Cr>
xnoremap <silent><M-a>m :FloatermReplMark<Cr>
nnoremap <silent><M-a>s :FloatermReplSendMark<Cr>
nnoremap <silent><M-a>S :FloatermReplShowMark<Cr>
" ---------------------------------------
" jupynvim
" ---------------------------------------
if pack#installed('jupynium.nvim')
    " set url
    let g:jupynium_ip = get(g:, 'jupynium_ip', 'localhost')
    let g:jupynium_port = get(g:, 'jupynium_port', 9999)
    let g:jupynium_protocal = get(g:, 'jupynium_protocal', 'http')
    let g:jupynium_url = get(g:, 'jupynium_url', printf("%s://%s:%d/nbclassic", g:jupynium_protocal, g:jupynium_ip, g:jupynium_port))
    " setup
    lua require("jupynium").setup({ default_notebook_URL = vim.g.jupynium_url, use_default_keybindings = false })
    " self defined function
    function! s:jupynium_run(...)
        let jupynium_urls = get(g:, 'jupynium_urls', [g:jupynium_url])
        if len(jupynium_urls) == 1
            let tLjupynium_url = jupynium_urls[0]
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
    function! s:execute_and_forword() abort
        JupyniumExecuteSelectedCells
        let endline = search('^# %%', 'nW')
        if endline == 0
            let endline = line("$")
        elseif endline != line("$")
            let endline += 1
        endif
        execute "normal! " . endline . 'G'
    endfunction
    command JupyniumExecuteSelectedCellsForword call s:execute_and_forword()
    function! s:map() abort
        nnoremap <buffer><silent>q<Cr> <Cmd>JupyniumRun<Cr>
        nnoremap <buffer><silent>qr <Cmd>JupyniumStartSync <C-r>=get(t:, 'jupynium_url', '')<Cr>
        nnoremap <buffer><silent>qh <Cmd>JupyniumKernelHover<Cr>
        nnoremap <buffer><silent>qk <Cmd>JupyniumKernelSelect<Cr>
        nnoremap <buffer><silent>qt <Cmd>JupyniumRunInTerminal<Cr>
        nnoremap <buffer><silent>qq <Cmd>JupyniumStopSync<Cr>
        nnoremap <buffer><silent>qb <Cmd>JupyniumScrollToCell<Cr>
        nnoremap <buffer><silent>qu <Cmd>JupyniumScrollUp<Cr>
        nnoremap <buffer><silent>qd <Cmd>JupyniumScrollDown<Cr>
        nnoremap <buffer><silent>ql <Cmd>JupyniumExecuteSelectedCells<Cr>
        xnoremap <buffer><silent>ql <Cmd>JupyniumExecuteSelectedCells<Cr>
        nnoremap <buffer><silent>qL <Cmd>JupyniumClearSelectedCellsOutputs<Cr>
        xnoremap <buffer><silent>qL <Cmd>JupyniumClearSelectedCellsOutputs<Cr>
        nnoremap <buffer><silent>qf <Cmd>JupyniumExecuteSelectedCellsForword<Cr>
        nnoremap <buffer><silent><M-M> <Cmd>JupyniumCommands<Cr>
    endfunction
    au FileType python,r call s:map()
endif

