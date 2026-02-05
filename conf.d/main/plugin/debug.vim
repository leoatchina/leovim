" Skip in VSCode environment
if utils#is_vscode()
    finish
endif
nnoremap - :call preview#errmsg("Please intalled debug plugins.")<Cr>
nnoremap _ -
if g:has_terminal == 0
    finish
endif
" ---------------------------------
" debug: load_json
" ---------------------------------
if pack#planned_fzf()
    function! s:load_json(dap, ...)
        let dap = a:dap
        if a:0 && filereadable(a:1)
            let template_file = a:1
        else
            let template_file = ''
        endif
        if dap
            let json_file = fnamemodify(utils#get_root_dir() . '/.vim/dap.json', ':p')
            let json_dir = fnamemodify(utils#get_root_dir() . '/.vim', ':p')
            if !isdirectory(json_dir)
                try
                    call mkdir(json_dir, 'p')
                catch /.*/
                    call preview#errmsg('mkdir ' . json_dir . ' failed')
                    return
                endtry
            endif
        else
            let json_file = fnamemodify(utils#get_root_dir() . '/.vimspector.json', ':p')
        endif
        if filereadable(json_file)
            execute "tabe " . json_file
        else
            let json_dict = {}
            if dap
                let json_dict['version'] = "0.2.0"
                let json_dict['configurations'] = []
            else
                let json_dict['configurations'] = {}
            endif
            let json = json_encode(json_dict)
            call writefile(split(json, "\n"), json_file)
            execute "tabe " . json_file
            if executable('jq')
                execute '%!jq'
                w!
            endif
        endif
        if template_file != ''
            if &columns > &lines * 3
                execute "vsplit " . template_file
            else
                execute "split " . template_file
            endif
        endif
    endfunction
endif
" -----------------
" vimspector
" -----------------
if pack#planned('vimspector')
    let g:debug_tool = "vimspector"
    let g:vimspector_enable_auto_hover = 0
    let g:vimspector_base_dir = utils#expand("~/.leovim.d/vimspector")
    " load template
    if pack#planned_fzf()
        function! ReadVimspectorTemplate(template_file) abort
            call s:load_json(0, a:template_file)
        endfunction
        function! s:load_vimspector()
            let options = ['--prompt', 'VimspectorTemplate> ', '--delimiter', ':']
            let wrap = fzf#wrap('vimspector',{
                        \ 'source': utils#is_win() ? 'dir /B /S ' . $CONF_D_DIR . '\\vimspector\\*.json' : 'ls -1 ' . $CONF_D_DIR . '/vimspector/*.json',
                        \ 'sink': function('ReadVimspectorTemplate'),
                        \ 'options': extend(options, call('fzf#vim#with_preview', copy(g:fzf_vim.preview_window)).options)
                        \ })
            call fzf#run(wrap)
        endfunction
        command! LoadVimspector call s:load_vimspector()
        nnoremap <silent><leader>rl :LoadVimspector<Cr>
        command! OpenVimspector call s:load_json(0)
        nnoremap <silent><leader>ro :OpenVimspector<Cr>
        nnoremap <leader>rO :tabe ~/.leovim/conf.d/vimspector/
    endif
    nmap <leader>rI :VimspectorInstall<Space>
    nmap <leader>rL :call vimspector#GetConfigurations()<Left>
    nmap <silent><M-e>, <Plug>VimspectorJumpToPreviousBreakpoint
    nmap <silent><M-e>; <Plug>VimspectorJumpToNextBreakpoint
    nmap <silent><M-e><Space> <Plug>VimspectorToggleBreakpoint
    nmap <silent><M-e><M-e> <Plug>VimspectorRunToCursor
    nmap <silent><M-e><Tab> <Plug>VimspectorDisassemble
    nmap <silent><M-e><Cr> <Plug>VimspectorContinue
    nmap <silent><M-e>n <Plug>VimspectorStepOver
    nmap <silent><M-e>i <Plug>VimspectorStepInto
    nmap <silent><M-e>o <Plug>VimspectorStepOut
    nmap <silent><M-e>p <Plug>VimspectorPause
    nmap <silent><M-e>q :call vimspector#Reset()<Cr>
    nmap <silent><M-e>r :call vimspector#Launch()<Cr>
    nmap <silent><F3> :VimspectorReset<Cr>
    nmap <silent><F4> <Plug>VimspectorRunToCursor
    nmap <silent><F5> <Plug>VimspectorContinue
    nmap <silent><F6> <Plug>VimspectorPause
    nmap <silent><F7> <Plug>VimspectorJumpToPreviousBreakpoint
    nmap <silent><F8> <Plug>VimspectorJumpToNextBreakpoint
    nmap <silent><F9> <Plug>VimspectorToggleBreakpoint
    nmap <silent><F10> <Plug>VimspectorStepOver
    nmap <silent><F11> <Plug>VimspectorStepInto
    nmap <silent><F12> <Plug>VimspectorStepOut
    " session
    nnoremap <M-e><M-l> :VimspectorLoadSession
    nnoremap <M-e><M-m> :VimspectorMkSession<Cr>
    nnoremap <M-e><M-n> :VimspectorNewSession<Space>
    nnoremap <M-e><M-q> :VimspectorDestroySession<Space>
    nnoremap <M-e><M-r> :VimspectorRenameSession<Space>
    nnoremap <M-e><M-s> :VimspectorSwitchToSession<Space>
    command! VimspectorCommands call FzfCallCommands('VimspectorCommands', 'Vimspector')
    nnoremap <M-e>: :VimspectorCommands<Cr>
    nnoremap <M-e>v :call vimspector#
    " breakpoint
    nnoremap <silent><M-e>c :call vimspector#ClearBreakpoints()<Cr>
    nnoremap <silent><M-e>f :call vimspector#AddFunctionBreakpoint('')<left><left>
    nnoremap <silent><M-e>b :call vimspector#ToggleAllBreakpointsViewBreakpoint()<Cr>
    " start / stop
    nnoremap <silent><M-e>. :call vimspector#Restart()<Cr>
    nnoremap <silent><M-e>Q :call vimspector#Stop({'interactive': v:true})<Cr>
    " function
    nnoremap <silent><M-e>u :call vimspector#UpFrame()<Cr>
    nnoremap <silent><M-e>d :call vimspector#DownFrame()<Cr>
    " --------------------------------------
    " jump/show windows in vimspector
    " --------------------------------------
    function! GoToVimspectorWindow(name) abort
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
                let windowNr = -1
            endif
        catch
            call preview#errmsg('Wrong input name.')
            let windowNr = -1
        endtry
        if windowNr >= 0
            execute windowNr . 'wincmd w'
        endif
    endfunction
    nnoremap <silent><M-'>  :call vimspector#ListBreakpoints()<Cr>
    nnoremap <silent><M-m>i :call GoToVimspectorWindow('important')<Cr>
    nnoremap <silent><M-m>s :call GoToVimspectorWindow('server')<Cr>
    nnoremap <silent><M-m>e :call GoToVimspectorWindow('stderr')<Cr>
    nnoremap <silent><M-m>v :call GoToVimspectorWindow('Vimspector')<Cr>
    nnoremap <silent><M-m>t :call GoToVimspectorWindow('Telemetry')<Cr>
    nnoremap <silent><M-m>1 :call GoToVimspectorWindow('variables')<Cr>
    nnoremap <silent><M-m>2 :call GoToVimspectorWindow('watches')<Cr>
    nnoremap <silent><M-m>3 :call GoToVimspectorWindow('stacktrace')<Cr>
    " --------------------------------------
    " special map
    " ---------------------------------------
    function! s:vimspector_opened()
        return bufwinnr('vimspector.Variables') >= 0 || bufwinnr('vimspector.Watches') >= 0 || bufwinnr('vimspector.StackTrace') >= 0
    endfunction
    au BufEnter * if s:vimspector_opened() | SignifyDisable | endif
    function! s:vimspector_or_floaterm(type)
        if s:vimspector_opened()
            if index(['code', 'terminal'], a:type) >= 0
                try
                    let windowNr = bufwinnr(winbufnr(g:vimspector_session_windows[a:type]))
                    execute windowNr . 'wincmd w'
                catch /.*/
                    call preview#errmsg('No ' . a:type . ' window')
                endtry
            elseif a:type ==# 'eval'
                execute  "normal \<Plug>VimspectorBalloonEval"
            else
                call vimspector#ShowOutput(a:type)
            endif
        elseif a:type ==# 'Console'
            FloatermToggle
        elseif a:type ==# 'terminal'
            FloatermNewOrFzfList
        elseif a:type ==# 'eval'
            call diagnostic#show(1)
        endif
    endfunction
    command! BalloonEval call s:vimspector_or_floaterm('eval')
    command! FocusCode call s:vimspector_or_floaterm("code")
    command! ConsoleOrFloatermToggle call s:vimspector_or_floaterm('Console')
    command! TerminalOrFloatermNewOrFzfList call s:vimspector_or_floaterm('terminal')
    " other important map
    nnoremap <silent><M-m>0 :FocusCode<Cr>
    nnoremap <silent><M--> :ConsoleOrFloatermToggle<Cr>
    nnoremap <silent><M-=> :TerminalOrFloatermNewOrFzfList<Cr>
    " VimspectorDisassemble
    nmap <silent><F1> <Plug>VimspectorDisassemble
    " view variables
    nnoremap <silent>J :BalloonEval<Cr>
    " deletewatch
    au FileType VimspectorPrompt nnoremap <buffer><silent>x :call vimspector#DeleteWatch()<Cr>
elseif pack#installed('nvim-dap', 'nvim-dap-ui', 'nvim-nio', 'mason.nvim', 'mason-nvim-dap.nvim')
    let g:debug_tool = 'nvim-dap'
    lua require("cfg/dap")
    " load template
    if pack#planned_fzf()
        function! ReadDapTemplate(template_file) abort
            call s:load_json(1, a:template_file)
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
        command! OpenDap call s:load_json(1)
        nnoremap <silent><leader>ro :OpenDap<Cr>
        nnoremap <leader>rO :tabe ~/.leovim/conf.d/dap/
    endif
    nnoremap <leader>rI :DapInstall<Space>
    nnoremap <leader>rU :DapUninstall<Space>
    nnoremap <leader>rL :lua DapLoadConfig()<Left>
    nnoremap <silent><M-e>, <cmd>lua DapBreakpointPrev()<Cr>
    nnoremap <silent><M-e>; <cmd>lua DapBreakpointNext()<Cr>
    nnoremap <silent><M-e><Space> <cmd>lua require"dap".toggle_breakpoint()<Cr>
    nnoremap <silent><M-e><M-e> <cmd>lua DapRunToCusor()<Cr>
    nnoremap <silent><M-e><Cr> <cmd>lua DapContinue()<Cr>
    nnoremap <silent><M-e>p <cmd>lua DapPause()<Cr>
    nnoremap <silent><M-e>q <cmd>lua DapReset()<Cr>
    nnoremap <silent><M-e>n <cmd>lua require"dap".step_over()<Cr>
    nnoremap <silent><M-e>N <cmd>lua require"dap".step_back()<Cr>
    nnoremap <silent><M-e>i <cmd>lua require"dap".step_into()<Cr>
    nnoremap <silent><M-e>o <cmd>lua require"dap".step_out()<Cr>
    nnoremap <silent><F3> <cmd>lua DapReset()<Cr>
    nnoremap <silent><F4> <cmd>lua DapRunToCusor()<Cr>
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
    nnoremap <silent><M-'>  <Cmd>call GoToDAPWindows("DAP Breakpoints")<Cr>
    nnoremap <silent><M-m>1 <Cmd>call GoToDAPWindows("DAP Scopes")<Cr>
    nnoremap <silent><M-m>2 <Cmd>call GoToDAPWindows("DAP Watches")<Cr>
    nnoremap <silent><M-m>3 <Cmd>call GoToDAPWindows("DAP Stacks")<Cr>
    " check dapui openned
    function! s:dapui_opened()
        return bufwinnr("DAP Scopes") >= 0 || bufwinnr("DAP Watches") >= 0 || bufwinnr("DAP Stacks") >= 0
    endfunction
    au BufEnter * if s:dapui_opened() | SignifyDisable | endif
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
        elseif s:dapui_opened()
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
            FloatermNewOrFzfList
        else
            call preview#errmsg('Please start dap session.') | sleep 2
        endif
    endfunction
    command! DapUIEval call s:dap_or_floaterm("eval")
    command! FocusCode call s:dap_or_floaterm("focus")
    command! ReplOrFloatermToggle call s:dap_or_floaterm("repl")
    command! FloatElementOrFloatermNewOrFzfList call s:dap_or_floaterm("element")
    " other important map
    nnoremap <silent><M-m>0 :FocusCode<Cr>
    nnoremap <silent><M--> :ReplOrFloatermToggle<Cr>
    nnoremap <silent><M-=> :FloatElementOrFloatermNewOrFzfList<Cr>
    " view variables
    nnoremap <silent>J :DapUIEval<Cr>
elseif v:version >= 801 && !has('nvim') && pack#get('termdebug')
    let g:debug_tool = 'termdebug'
    let g:termdebug_map_K = 1
    let g:termdebug_use_prompt = 1
    packadd termdebug
    nnoremap <M-e><Space> :Break<Space>
    nnoremap <M-e><M-e> :Until<Cr>
    nnoremap <M-e><Cr> :Continue<Cr>
    nnoremap <M-e>c :Clear<Space>
    nnoremap <M-e>r :Run<Space>
    nnoremap <M-e>n :Over<Cr>
    nnoremap <M-e>i :Step<Cr>
    nnoremap <M-e>o :Finish<Cr>
    nnoremap <M-e>a :Arguments<Space>
    nnoremap <F1> :Run<Space>
    nnoremap <F3> :Stop<Space>
    nnoremap <F4> :Until<Cr>
    nnoremap <F5> :Continue<Cr>
    nnoremap <F6> :Pause<Cr>
    nnoremap <F7> :Clear<Space>
    nnoremap <F8> :Clear<Space>
    nnoremap <F9> :Break<Space>
    nnoremap <F10> :Over<Cr>
    nnoremap <F11> :Step<Cr>
    nnoremap <F12> :Finish<Cr>
    " debug
    nnoremap J :Evaluate <C-r><C-w><Cr>
    " other
    nnoremap <M-m>d :Termdebug<Space>
    nnoremap <M-m>c :TermdebugCommand<Space>
    nnoremap <silent><M-m>w :Winbar<Cr>
    nnoremap <silent><M-m>p :Program<Cr>
    nnoremap <silent><M-m>a :Asm<Cr>
    nnoremap <silent><M-m>s :Source<Cr>
    nnoremap <silent><M-m>g :Gdb<Cr>
endif
" watch Variable
function! s:watch() range
    if pack#installed('nvim-dap')
        if !s:dapui_opened()
            call preview#errmsg("Please start nvim-dap session first.")
            return
        endif
    elseif pack#installed('vimspector')
        if !s:vimspector_opened()
            call preview#errmsg("Please start vimspector session first.")
            return
        endif
    else
        call preview#errmsg("Could not watch")
    endif
    " Handle visual mode selection
    let l:selected_text = ''
    if mode() =~# "[vV\<C-v>]"
        let [line_start, column_start] = getpos("'<")[1:2]
        let [line_end, column_end] = getpos("'>")[1:2]
        let lines = getline(line_start, line_end)
        if empty(lines)
            call preview#errmsg("No text selected")
            return
        endif
        " Handle single line selection
        if line_start == line_end
            let l:selected_text = lines[0][column_start - 1 : column_end - 1]
        else
            " Handle multi-line selection
            let lines[-1] = lines[-1][: column_end - 1]
            let lines[0] = lines[0][column_start - 1:]
            let l:selected_text = join(lines, "\n")
        endif
    else
        " Handle normal mode (word under cursor)
        let l:selected_text = utils#expand('<cword>')
    endif
    " Trim whitespace
    let l:selected_text = utils#trim(l:selected_text)
    if !empty(l:selected_text)
        try
            if pack#installed('vimspector')
                call vimspector#AddWatch(l:selected_text)
            elseif pack#installed('nvim-dap')
                let cmd = "lua require'dapui'.elements.watches.add(" .  l:selected_text . ")"
                execute(cmd)
            endif
        catch
            call preview#errmsg("Failed to add watch for reason: " . v:exception)
        endtry
    else
        call preview#errmsg("No valid text to watch")
    endif
endfunction
command! -range WatchCword call s:watch()
xnoremap - :WatchCword<CR>
nnoremap - :WatchCword<CR>
" -----------------------------------------------------------------------------------------
" using vim-floaterm-enhance to do repl/run/ai. NOTE: below bang[!] means cursor not move
" -----------------------------------------------------------------------------------------
nnoremap <M-i><M-i> <C-w><C-w>
inoremap <M-i><M-i> <ESC><C-w><C-w>
xnoremap <M-i><M-i> <ESC><C-w><C-w>
if pack#installed('vim-floaterm', 'vim-floaterm-enhance')
    tnoremap <M-i><M-i> <C-\><C-n><C-w><C-w>
    " NOTE: ! means keep in current line
    nnoremap <silent><M-i><M-r> :FloatermReplStart<Cr>
    nnoremap <silent><M-i><M-a> :FloatermReplStart!<Cr>
    nnoremap <silent><M-i><Cr> :FloatermReplSendCrOrStart!<Cr>
    " repl line send
    nnoremap <silent><M-i>n :FloatermReplSend<Cr>
    nnoremap <silent><M-i>l :FloatermReplSend!<Cr>
    xnoremap <silent><M-i>n :FloatermReplSend<Cr>
    xnoremap <silent><M-i>l :FloatermReplSend!<Cr>
    nnoremap <silent><M-i>q :FloatermReplSendExit<Cr>
    nnoremap <silent><M-i>L :FloatermReplSendClear<Cr>
    " repl block send
    xnoremap <silent><M-i><M-e> :FloatermReplSend<Cr>
    xnoremap <silent><M-i>e     :FloatermReplSend!<Cr>
    nnoremap <silent><M-i><M-e> :FloatermReplSendBlock<Cr>
    nnoremap <silent><M-i>e     :FloatermReplSendBlock!<Cr>
    " repl send above/below/all lines
    nnoremap <silent><M-i>b :FloatermReplSendFromBegin!<Cr>
    nnoremap <silent><M-i>e :FloatermReplSendToEnd!<Cr>
    nnoremap <silent><M-i>a :FloatermReplSendAll!<Cr>
    " repl send word
    nnoremap <silent><M-i>k :FloatermReplSendWord<Cr>
    xnoremap <silent><M-i>k :FloatermReplSendWord<Cr>
    " repl mark print send
    nnoremap <silent><M-i>m :FloatermReplMark<Cr>
    xnoremap <silent><M-i>m :FloatermReplMark<Cr>
    nnoremap <silent><M-i>s :FloatermReplSendMark<Cr>
    nnoremap <silent><M-i>S :FloatermReplShowMark<Cr>
endif
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
