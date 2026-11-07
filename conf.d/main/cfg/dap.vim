" ---------------------------------
" nvim-dap debug tool
" ---------------------------------
" load template
if pack#planned_fzf()
    function! ReadDapTemplate(template_file) abort
        call debug#load_json(1, a:template_file)
    endfunction
    function! s:load_dap() abort
        let options = ['--prompt', 'DapTemplate> ', '--delimiter', ':']
        let wrap = fzf#wrap('dap',{
                    \ 'source': utils#is_win() ? 'dir /B /S ' . $CONF_D_DIR . '\\dap\\*.json' : 'ls -1 ' . $CONF_D_DIR . '/dap/*.json',
                    \ 'sink': function('ReadDapTemplate'),
                    \ 'options': extend(options, call('fzf#vim#with_preview', copy(g:fzf_vim.preview_window)).options)
                    \ })
        call fzf#run(wrap)
    endfunction
    command! LoadDap call s:load_dap()
    nnoremap <silent><leader>rl :LoadDap<Cr>
    command! OpenDap call debug#load_json(1)
    nnoremap <silent><leader>ro :OpenDap<Cr>
    nnoremap <leader>rO :tabe ~/.leovim/conf.d/dap/
endif
nnoremap <leader>rI :DapInstall<Space>
nnoremap <leader>rU :DapUninstall<Space>
nnoremap <leader>rL :lua DapLoadConfig()<Left>
nnoremap <silent><M-e>, <cmd>lua DapBreakpointPrev()<Cr>
nnoremap <silent><M-e>; <cmd>lua DapBreakpointNext()<Cr>
nnoremap <silent><M-e><Space> <cmd>lua require"dap".toggle_breakpoint()<Cr>
nnoremap <silent><M-e><M-e> <cmd>lua DapRunToCursor()<Cr>
nnoremap <silent><M-e><Cr> <cmd>lua DapContinue()<Cr>
nnoremap <silent><M-e>p <cmd>lua DapPause()<Cr>
nnoremap <silent><M-e>q <cmd>lua DapReset()<Cr>
nnoremap <silent><M-e>n <cmd>lua require"dap".step_over()<Cr>
nnoremap <silent><M-e>N <cmd>lua require"dap".step_back()<Cr>
nnoremap <silent><M-e>i <cmd>lua require"dap".step_into()<Cr>
nnoremap <silent><M-e>o <cmd>lua require"dap".step_out()<Cr>
nnoremap <silent><F3> <cmd>lua DapReset()<Cr>
nnoremap <silent><F4> <cmd>lua DapRunToCursor()<Cr>
nnoremap <silent><F5> <cmd>lua DapContinue()<Cr>
nnoremap <silent><F6> <cmd>lua DapPause()<Cr>
nnoremap <silent><F7> <cmd>lua DapBreakpointPrev()<Cr>
nnoremap <silent><F8> <cmd>lua DapBreakpointNext()<Cr>
nnoremap <silent><F9> <cmd>lua require"dap".toggle_breakpoint()<Cr>
nnoremap <silent><F10> <cmd>lua require"dap".step_over()<Cr>
nnoremap <silent><F11> <cmd>lua require"dap".step_into()<Cr>
nnoremap <silent><F12> <cmd>lua require"dap".step_out()<Cr>
" basic <M-e> map
nnoremap <M-e>l :lua require"dap".
nnoremap <silent><M-e>. <cmd>lua require"dap".run_last()<Cr>
nnoremap <silent><M-e>a <cmd>lua require"dap".attach(vim.fn.input('Attatch to: '))<Cr>
" breakpoints
nnoremap <silent><M-e>c <cmd>lua require"dap".clear_breakpoints()<Cr>
nnoremap <silent><M-e>e <cmd>lua require"dap".set_exception_breakpoints("")<left><left>
nnoremap <silent><M-e>s <cmd>lua require"dap".set_breakpoint()<left>
" debug
nnoremap <silent><M-e>u <cmd>lua require"dap".up()<Cr>
nnoremap <silent><M-e>d <cmd>lua require"dap".down()<Cr>
" auto attach
au FileType dap-repl lua require('dap.ext.autocompl').attach()
" --------------------------------------
" nvim-dap-ui
" ---------------------------------------
nnoremap <M-m>l :lua require("dapui").
" watch
nnoremap <silent><M-m>s <cmd>lua require("dapui").float_element('scopes')<Cr>
nnoremap <silent><M-m>w <cmd>lua require("dapui").float_element('watches')<Cr>
nnoremap <silent><M-m>t <cmd>lua require("dapui").float_element('stacks')<Cr>
nnoremap <silent><M-m>c <cmd>lua require("dapui").float_element('console')<Cr>
nnoremap <silent><M-m>r <cmd>lua require("dapui").float_element('repl')<Cr>
function! GoToDAPWindows(name) abort
    try
        let windowNr = bufwinnr(a:name)
        execute windowNr . 'wincmd w'
    catch
        if a:name == 'DAP Breakpoints'
            lua require"dap".list_breakpoints(true)
        endif
    endtry
endfunction
nnoremap <silent><M-m>b <Cmd>call GoToDAPWindows("DAP Breakpoints")<Cr>
nnoremap <silent><M-m>1 <Cmd>call GoToDAPWindows("DAP Scopes")<Cr>
nnoremap <silent><M-m>2 <Cmd>call GoToDAPWindows("DAP Watches")<Cr>
nnoremap <silent><M-m>3 <Cmd>call GoToDAPWindows("DAP Stacks")<Cr>
" check dapui openned: debug#dapui_opened() is defined in plugin/debug.vim.
" --------------------------------------
" special map
" ---------------------------------------
function! s:dap_or_floaterm(type)
    if a:type == "eval"
        if luaeval('require"dap".session() ~= nil')
            lua require('dapui').eval(nil, {context='hover', width=math.floor(vim.o.columns*0.5), height=math.floor(vim.o.lines*0.25), enter=false})
        else
            call diagnostic#show(1)
        endif
    elseif debug#dapui_opened()
        if a:type == "console"
            lua require("dapui").float_element('console')
        elseif a:type == "repl"
            lua require("dapui").float_element('repl')
        elseif a:type == "element"
            lua require("dapui").float_element()
        else
            call GoToDAPWindows("DAP Breakpoints")
            wincmd k
        endif
    elseif a:type == "repl"
        FloatermToggle
    elseif a:type == "element"
        TermNewOrFzfList
    else
        call preview#errmsg('Please start dap session.') | sleep 2
    endif
endfunction
command! DapUIEval call s:dap_or_floaterm("eval")
command! FocusCode call s:dap_or_floaterm("focus")
command! ReplOrFloatermToggle call s:dap_or_floaterm("repl")
command! ConsoleOrFloatermToggle call s:dap_or_floaterm("console")
command! ElementOrFloatermNewOrFzfList call s:dap_or_floaterm("element")
" other important map
nnoremap <silent><M-m>0 :FocusCode<Cr>
nnoremap <silent><M--> :ConsoleOrFloatermToggle<Cr>
nnoremap <silent><M-=> :ElementOrFloatermNewOrFzfList<Cr>
" view variables
nnoremap <silent>J :DapUIEval<Cr>
