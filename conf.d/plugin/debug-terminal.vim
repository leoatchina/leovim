function! s:diag_or_errmsg(diagnostic)
    if a:diagnostic
        if Planned('ale')
            ALEDetail
        elseif PlannedCoc()
            call CocActionAsync('diagnosticInfo')
        elseif InstalledNvimLsp()
            lua vim.diagnostic.open_float()
        else
            call preview#errmsg('Please select lines to merge!')
        endif
    else
        call preview#errmsg('Please select lines to merge!')
    endif
endfunction
function! s:j(line1, line2, diagnostic) range abort
    let pos = getpos('.')
    if a:line1 != a:line2
        execute a:line1 . "," . a:line2 . "join"
    else
        call s:diag_or_errmsg(a:diagnostic)
        call setpos('.', pos)
    endif
endfunction
command! -range J call s:j(<line1>, <line2>, 0)
command! -range JDiag call s:j(<line1>, <line2>, 1)
xnoremap <silent>J :J<Cr>
" NOTE
if g:has_terminal == 0
    nnoremap <silent>J :JDiag<Cr>
    finish
endif
" --------------------------
" basic terminal map
" --------------------------
tmap <expr><C-r> '<C-\><C-n>"'.nr2char(getchar()).'pi'
" --------------------------
" open terminal
" --------------------------
if has('nvim')
    command! TermPackD tabe | call termopen([&shell], {'cwd': expand('~/.leovim.d')})
    nnoremap <silent><M-h>D :TermPackD<Cr>i
    nnoremap <silent><M-+> :tabnew<Cr>:terminal<Cr>i
    inoremap <silent><M-+> <C-o>:tabnew<Cr>:terminal<Cr>i
    tnoremap <silent><M-+> <C-\><C-n>:tabnew<Cr>:terminal<Cr>i
else
    nnoremap <silent><M-h>D :tab terminal<CR>cd ~/.leovim.d<tab><CR>
    nnoremap <silent><M-+> :tab terminal<Cr>
    inoremap <silent><M-+> <C-o>:tab terminal<Cr>
    tnoremap <silent><M-+> <C-\><C-n>:tab terminal<Cr>
endif
tnoremap <silent><C-v> <C-\><C-n>
tnoremap <silent><M-q> <C-\><C-n>:ConfirmQuit<Cr>
tnoremap <silent><M-w> <C-\><C-n>:tabclose<Cr>
tnoremap <silent><M-W> <C-\><C-n>:tabonly<Cr>i
" ---------------------------------------------------------
" floaterm
" ---------------------------------------------------------
let g:floaterm_open_command = 'drop'
let g:floaterm_wintype  = 'split'
let g:floaterm_position = 'belowright'
let g:floaterm_height = 0.3
PlugAddOpt 'vim-floaterm'
" --------------------------
" new floaterm
" --------------------------
command! FloatermCommands call FzfCallCommands('FloatermCommands', 'Floaterm')
nnoremap <Tab>f :FloatermCommands<Cr>
" --------------------------
" new floaterm
" --------------------------
let s:floaterm_parameters = {}
let s:floaterm_parameters.right = " --wintype=vsplit --width=0.382"
let s:floaterm_parameters.belowright = " --wintype=split --height=0.3"
if g:has_popup_floating
    let s:floaterm_parameters.center = " --wintype=float --width=0.618 --height=0.618"
    let s:floaterm_parameters.topright = " --wintype=float --width=0.45 --height=0.618"
    let s:floaterm_parameters.bottomright = " --wintype=float --width=0.45 --height=0.3"
endif
function! s:floaterm_select_pos()
    let positions = ['Right', 'Belowright', 'Center', 'Topright', 'BottomRight']
    if g:has_popup_floating == 0
        let positions = positions[:1]
    endif
    let title = 'Choose a Floaterm Position'
    let pos = tolower(ChooseOne(positions, title, 0))
    if empty(pos)
        return
    endif
    let position = " --position=" . pos
    let cmd = "FloatermNew" . s:floaterm_parameters[pos] . position
    execute cmd
endfunction
command! FloatermSpecial call s:floaterm_select_pos()
" -----------------------------
" show floaterm
" -----------------------------
function! s:floaterm_list() abort
    let bufs = floaterm#buflist#gather()
    let cnt = len(bufs)
    if cnt == 0
        let no_msg = "No floaterm windows"
        if Installed('vim-quickui')
            call quickui#textbox#open([no_msg], {})
        else
            call preview#errmsg(no_msg)
        endif
        return
    endif
    let content = []
    for bufnr in bufs
        let title = getbufvar(bufnr, 'floaterm_title')
        if title ==# "floaterm($1/$2)"
            let cur = index(bufs, bufnr) + 1
            let title = substitute(title, '$1', cur, 'gm')
            let title = substitute(title, '$2', cnt, 'gm')
        endif
        let postion = getbufvar(bufnr, 'floaterm_position')
        let wintype = getbufvar(bufnr, 'floaterm_wintype')
        let cmd     = getbufvar(bufnr, 'floaterm_cmd')
        let open_cmd = printf('call floaterm#terminal#open_existing(%s)', bufnr)
        if Installed('vim-quickui')
            let title = title . "@" . wintype . '/' .  postion . ' ' .  cmd
            let line = [title, open_cmd]
        else
            let title = title . "@" . wintype . '/' .  postion
            let line = {}
            let line.bufnr = bufnr
            let line.text = title
            let line.pattern = open_cmd
        endif
        call add(content, line)
    endfor
    if Installed('vim-quickui')
        let opts = {'title': 'All floaterm buffers', 'w': 64}
        call quickui#listbox#open(content, opts)
    else
        call setqflist(content)
        execute "belowright copen" . g:asyncrun_open
    endif
endfunc
command! FloatermList call s:floaterm_list()
tnoremap <silent><C-\><C-f> <C-\><C-n>:FloatermList<Cr>
nnoremap <silent><C-\><C-f> :FloatermList<Cr>
" ---------------------------------
" debug
" ---------------------------------
if PlannedFzf()
    function! s:load_json(dap, ...)
        let dap = a:dap
        if a:0 && filereadable(a:1)
            let template_file = a:1
        else
            let template_file = ''
        endif
        if dap
            let json_file = fnamemodify(GetRootDir() . '/.vim/dap.json', ':p')
            let json_dir = fnamemodify(json_file, ':h')
            if !isdirectory(json_dir)
                try
                    call mkdir(json_dir, 'p')
                catch /.*/
                    call preview#errmsg('mkdir ' . json_dir . ' failed')
                    return
                endtry
            endif
        else
            let json_file = fnamemodify(GetRootDir() . '/.vimspector.json', ':p')
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
if Planned('vimspector')
    let g:debug_tool = "vimspector"
    let g:vimspector_base_dir = $DEPLOY_DIR . "/vimspector"
    " load template
    if PlannedFzf()
        function! ReadVimspectorTemplate(template_file) abort
            call s:load_json(0, a:template_file)
        endfunction
        function! s:load_vimspector()
            let options = ['--prompt', 'VimspectorTemplate> ', '--delimiter', ':']
            let wrap = fzf#wrap('vimspector',{
                        \ 'source': WINDOWS() ? 'dir /B /S ' . $CONF_D_DIR . '\\vimspector\\*.json' : 'ls -1 ' . $CONF_D_DIR . '/vimspector/*.json',
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
    " core keymaps
    nmap <M-d>I :VimspectorInstall<Space>
    nmap <silent><M-d><Space> <Plug>VimspectorToggleBreakpoint
    nmap <silent><M-d><M-d> <Plug>VimspectorRunToCursor
    nmap <silent><M-d><M-e> <Plug>VimspectorContinue
    nmap <silent><M-d>n <Plug>VimspectorStepOver
    nmap <silent><M-d>i <Plug>VimspectorStepInto
    nmap <silent><M-d>o <Plug>VimspectorStepOut
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
    nnoremap <M-d><M-l> :VimspectorLoadSession
    nnoremap <M-d><M-m> :VimspectorMkSession<Cr>
    nnoremap <M-d><M-n> :VimspectorNewSession<Space>
    nnoremap <M-d><M-q> :VimspectorDestroySession<Space>
    nnoremap <M-d><M-r> :VimspectorRenameSession<Space>
    nnoremap <M-d><M-s> :VimspectorSwitchToSession<Space>
    " core shortcuts
    command! VimspectorCommands call FzfCallCommands('VimspectorCommands', 'Vimspector')
    nnoremap <M-d>v :VimspectorCommands<Cr>
    nnoremap <M-d>V :call vimspector#
    " watch
    nnoremap + :VimspectorWatch <C-r>=expand('<cword>')<Cr>
    nnoremap _ :VimspectorDisassemble<Cr>
    nnoremap = :VimspectorEval <C-r>=expand('<cword>')<Cr>
    au FileType VimspectorPrompt nnoremap <buffer><silent>- :call vimspector#DeleteWatch()<Cr>
    " breakpoint
    nnoremap <silent><M-d>c :call vimspector#ClearBreakpoints()<Cr>
    nnoremap <silent><M-d>f :call vimspector#AddFunctionBreakpoint('')<left><left>
    nnoremap <silent><M-d>b :call vimspector#ToggleAllBreakpointsViewBreakpoint()<Cr>
    " start / stop
    nnoremap <silent><M-d><Tab> :call vimspector#Launch()<Cr>
    nnoremap <silent><M-d>r :call vimspector#Restart()<Cr>
    nnoremap <silent><M-d>q :call vimspector#Reset()<Cr>
    nnoremap <silent><M-d>Q :call vimspector#Stop({'interactive': v:true})<Cr>
    " function
    nnoremap <silent><M-d>u :call vimspector#UpFrame()<Cr>
    nnoremap <silent><M-d>d :call vimspector#DownFrame()<Cr>
    " other commands
    nnoremap <silent><M-d>g :call vimspector#GetConfigurations()<Cr>
    " --------------------------------------
    " jump/show windows in vimspector
    " --------------------------------------
    au BufEnter * if s:vimspector_opened() | SignifyDisable | endif
    function! s:vimspector_opened()
        return bufwinnr('vimspector.Variables') >= 0 && bufwinnr('vimspector.Watches') >= 0 && bufwinnr('vimspector.StackTrace') >= 0
    endfunction
    function! GoToVimspectorWindow(name) abort
        if !s:vimspector_opened()
            return
        endif
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
            call preview#errmsg('Wrong input name.')
            let windowNr = -1
        endtry
        if windowNr > 0
            execute windowNr . 'wincmd w'
        endif
        return windowNr
    endfunction
    nnoremap <silent><M-:>  :call vimspector#ListBreakpoints()<Cr>
    nnoremap <silent><M-m>i :call GoToVimspectorWindow('important')<Cr>
    nnoremap <silent><M-m>s :call GoToVimspectorWindow('server')<Cr>
    nnoremap <silent><M-m>v :call GoToVimspectorWindow('Vimspector')<Cr>
    nnoremap <silent><M-m>t :call GoToVimspectorWindow('Telemetry')<Cr>
    nnoremap <silent><M-m>1 :call GoToVimspectorWindow('variables')<Cr>
    nnoremap <silent><M-m>2 :call GoToVimspectorWindow('watches')<Cr>
    nnoremap <silent><M-m>3 :call GoToVimspectorWindow('stacktrace')<Cr>
    " --------------------------------------
    " special map
    " ---------------------------------------
    function! s:vimspector_or_floaterm(...)
        if s:vimspector_opened()
            if a:0
                if a:1 ==# 'code'
                    try
                        let windowNr = bufwinnr(winbufnr(g:vimspector_session_windows['code']))
                        execute windowNr . 'wincmd w'
                    catch /.*/
                        call preview#errmsg('No code window')
                    endtry
                else
                    call vimspector#ShowOutput(a:1)
                endif
            else
                execute  "normal \<Plug>VimspectorBalloonEval"
            endif
        elseif a:0
            if a:1 ==# 'stderr'
                FloatermKill
            elseif a:1 ==# 'Console'
                FloatermToggle
            elseif a:1 ==# 'terminal'
                FloatermSpecial
            else
                FloatermList
            endif
        else
            call s:diag_or_errmsg(1)
        endif
    endfunction
    command! BalloonEval call s:vimspector_or_floaterm()
    command! FocusCode call s:vimspector_or_floaterm("code")
    command! ConsoleOrFloatermToggle call s:vimspector_or_floaterm('Console')
    command! ErrOrFloatermKill call s:vimspector_or_floaterm('stderr')
    command! TerminalOrFloatermSpecial call s:vimspector_or_floaterm('terminal')
    nnoremap <silent>J :BalloonEval<Cr>
    nnoremap <silent><M-'> :FocusCode<Cr>
    nnoremap <silent><M--> :ConsoleOrFloatermToggle<Cr>
    nnoremap <silent><M-_> :ErrOrFloatermKill<Cr>
    nnoremap <silent><M-=> :TerminalOrFloatermSpecial<Cr>
elseif Installed('nvim-dap', 'nvim-dap-ui', 'nvim-nio', 'mason.nvim', 'mason-nvim-dap.nvim')
    let g:debug_tool = 'nvim-dap'
    lua require("dap_cfg")
    " load template
    if PlannedFzf()
        function! ReadDapTemplate(template_file) abort
            call s:load_json(1, a:template_file)
        endfunction
        function! s:load_dap() abort
            let options = ['--prompt', 'DapTemplate> ', '--delimiter', ':']
            let wrap = fzf#wrap('dap',{
                        \ 'source': WINDOWS() ? 'dir /B /S ' . $CONF_D_DIR . '\\dap\\*.json' : 'ls -1 ' . $CONF_D_DIR . '/dap/*.json',
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
    " core keymaps
    nnoremap <silent><M-d><Space> <cmd>lua require"dap".toggle_breakpoint()<Cr>
    nnoremap <silent><M-d><M-d> <cmd>lua require"dap".run_to_cursor()<Cr>
    nnoremap <silent><M-d><M-e> <cmd>lua require"dap".continue()<Cr>
    nnoremap <silent><M-d>n <cmd>lua require"dap".step_over()<Cr>
    nnoremap <silent><M-d>N <cmd>lua require"dap".step_back()<Cr>
    nnoremap <silent><M-d>i <cmd>lua require"dap".step_into()<Cr>
    nnoremap <silent><M-d>o <cmd>lua require"dap".step_out()<Cr>
    nnoremap <silent><F3> <cmd>lua DapReset()<Cr>
    nnoremap <silent><F4> <cmd>lua require"dap".run_to_cursor()<Cr>
    nnoremap <silent><F5> <cmd>lua DapLaunch()<Cr>
    nnoremap <silent><F6> <cmd>lua require"dap".pause()<Cr>
    nnoremap <silent><F9> <cmd>lua require"dap".toggle_breakpoint()<Cr>
    nnoremap <silent><F10> <cmd>lua require"dap".step_over()<Cr>
    nnoremap <silent><F11> <cmd>lua require"dap".step_into()<Cr>
    nnoremap <silent><F12> <cmd>lua require"dap".step_out()<Cr>
    " view, NOTE: preview is like eval in vimspector
    nnoremap <silent>= <cmd>lua require("dap.ui.widgets").preview()<Cr>
    nnoremap <silent><M-d>s <cmd>lua require("dap.ui.widgets").centered_float(widgets.scopes)<Cr>
    " basic <M-d> map
    nnoremap <M-d>l :lua require"dap".
    nnoremap <M-d>I :DapInstall<Space>
    nnoremap <M-d>U :DapUninstall<Space>
    nnoremap <silent><M-d><Tab> <cmd>lua DapLaunch()<Cr>
    nnoremap <silent><M-d>q <cmd>lua DapClose()<Cr>
    nnoremap <silent><M-d>p <cmd>lua require"dap".pause()<Cr>
    nnoremap <silent><M-d>r <cmd>lua require"dap".run_last()<Cr>
    nnoremap <silent><M-d>a <cmd>lua require"dap".attach(vim.fn.input('Attatch to: '))<Cr>
    " breakpoints
    nnoremap <silent><M-d>c <cmd>lua require"dap".clear_breakpoints()<Cr>
    nnoremap <silent><M-d>e <cmd>lua require"dap".set_exception_breakpoints("")<left><left>
    " debug
    nnoremap <silent><M-d>u <cmd>lua require"dap".up()<Cr>
    nnoremap <silent><M-d>d <cmd>lua require"dap".down()<Cr>
    " auto attach
    au FileType dap-repl lua require('dap.ext.autocompl').attach()
    " --------------------------------------
    " nvim-dap-ui
    " ---------------------------------------
    nnoremap <M-m>l :lua require("dapui").
    " watch
    nnoremap <silent><M-m>s <cmd>lua require("dapui").float_element('stacks')<Cr>
    nnoremap <silent><M-m>c <cmd>lua require("dapui").float_element('console')<Cr>
    nnoremap <silent><M-m>w <cmd>lua require("dapui").float_element('watches')<Cr>
    " jump to windows in dapui
    au BufEnter * if s:dapui_opened() | SignifyDisable | endif
    function! s:dapui_opened()
        return bufwinnr("DAP Scopes") >= 0 && bufwinnr("DAP Watches") >= 0 && bufwinnr("DAP Stacks") >= 0
    endfunction
    nnoremap <silent><M-:>  <cmd>call GoToDAPWindows("DAP Breakpoints")<Cr>
    nnoremap <silent><M-m>1 <Cmd>call GoToDAPWindows("DAP Scopes")<Cr>
    nnoremap <silent><M-m>2 <Cmd>call GoToDAPWindows("DAP Watches")<Cr>
    nnoremap <silent><M-m>3 <Cmd>call GoToDAPWindows("DAP Stacks")<Cr>
    function! GoToDAPWindows(name) abort
        if !s:dapui_opened()
            return
        endif
        try
            let windowNr = bufwinnr(a:name)
        catch
            let windowNr = -1
        endtry
        if windowNr > 0
            execute windowNr . 'wincmd w'
        endif
        return windowNr
    endfunction
    function! s:dap_breakpoint(...)
        if GoToDAPWindows('DAP Breakpoints') > 0
            if a:0 && a:1 > 0
                normal j^
            else
                normal k^
            endif
        endif
    endfunction
    command! DapBreakpointPrev call s:dap_breakpoint(0)
    command! DapBreakpointNext call s:dap_breakpoint(1)
    nnoremap <silent><F7> <Cmd>DapBreakpointPrev<Cr>
    nnoremap <silent><F8> <Cmd>DapBreakpointNext<Cr>
    " --------------------------------------
    " special map
    " ---------------------------------------
    function! s:dap_or_floaterm(...)
        if s:dapui_opened()
            if a:0 == 0
                lua require('dapui').eval(nil, {context='hover', width=math.floor(vim.o.columns*0.5), height=math.floor(vim.o.lines*0.25), enter=false})
            elseif a:1 == "-"
                call GoToDAPWindows("DAP Breakpoints")
            elseif a:1 == "_"
                lua require("dapui").float_element()
            elseif a:1 == "="
                lua require("dapui").float_element('repl')
            else
                call GoToDAPWindows("DAP Breakpoints")
                wincmd k
            endif
        elseif a:0
            if a:1 == "-"
                FloatermToggle
            elseif a:1 == "_"
                FloatermKill
            elseif a:1 == "="
                FloatermSpecial
            else
                FloatermList
            endif
        else
            call s:diag_or_errmsg(1)
        endif
    endfunction
    command! DapUIEval call s:dap_or_floaterm()
    command! FocusCode call s:dap_or_floaterm("'")
    command! ConsoleOrFloatermToggle call s:dap_or_floaterm("-")
    command! FloatElementOrFloatermKill call s:dap_or_floaterm("_")
    command! FloatReplOrFloatermSpecial call s:dap_or_floaterm("=")
    nnoremap <silent>J :DapUIEval<Cr>
    nnoremap <silent><M-'> :FocusCode<Cr>
    nnoremap <silent><M--> :ConsoleOrFloatermToggle<Cr>
    nnoremap <silent><M-_> :FloatElementOrFloatermKill<Cr>
    nnoremap <silent><M-=> :FloatReplOrFloatermSpecial<Cr>
else
    if v:version >= 801 && !has('nvim') && Require('termdebug')
        let g:debug_tool = 'termdebug'
        let g:termdebug_map_K = 1
        let g:termdebug_use_prompt = 1
        packadd termdebug
        " coremap
        nnoremap <M-d><Space> :Break<Space>
        nnoremap <M-d><M-d> :Until<Cr>
        nnoremap <M-d><Tab> :Run<Space>
        nnoremap <M-d><M-e> :Continue<Cr>
        nnoremap <M-d>c :Clear<Space>
        nnoremap <M-d>n :Over<Cr>
        nnoremap <M-d>i :Step<Cr>
        nnoremap <M-d>o :Finish<Cr>
        nnoremap <M-d>a :Arguments<Space>
        nnoremap <F3> :Stop<Cr>
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
        nnoremap = :Evaluate <C-r><C-w>
        " other
        nnoremap <M-m>d :Termdebug<Space>
        nnoremap <M-m>c :TermdebugCommand<Space>
        nnoremap <silent><M-m>w :Winbar<Cr>
        nnoremap <silent><M-m>p :Program<Cr>
        nnoremap <silent><M-m>a :Asm<Cr>
        nnoremap <silent><M-m>s :Source<Cr>
        nnoremap <silent><M-m>g :Gdb<Cr>
    endif
    nnoremap <silent>J :JDiag<Cr>
    nnoremap <silent><M-'> :FloatermList<Cr>
endif
inoremap <silent><M-'> <C-o>:FloatermList<Cr>
tnoremap <silent><M-'> <C-\><C-n>:FloatermList<Cr>
" -------------------------------------
" map Floaterm keys
" -------------------------------------
function! s:bind_keymap(mapvar, command) abort
    if !Planned('vimspector') && !Planned('nvim-dap') || a:mapvar ==# '<M-{>' || a:mapvar ==# '<M-}>'
        execute printf('nnoremap <silent> %s :%s<CR>', a:mapvar, a:command)
    endif
    execute printf('inoremap <silent>%s <C-o>:%s<CR>', a:mapvar, a:command)
    execute printf('tnoremap <silent>%s <C-\><C-n>:%s<CR>', a:mapvar, a:command)
endfunction
call s:bind_keymap('<M-{>', 'FloatermPrev')
call s:bind_keymap('<M-}>', 'FloatermNext')
call s:bind_keymap('<M-_>', 'FloatermKill')
call s:bind_keymap('<M-->', 'FloatermToggle')
call s:bind_keymap('<M-=>', 'FloatermSpecial')
" ---------------------------------------
" using vim-floaterm to do repl
" ---------------------------------------
PlugAddOpt 'vim-floaterm-repl'
" basic send, NOTE: bang! means stay
nnoremap <silent><M-e>r :FloatermReplStart!<Cr>
nnoremap <silent><M-e>n :FloatermReplSend<Cr>
nnoremap <silent><M-e>l :FloatermReplSend!<Cr>
xnoremap <silent><M-e>n :FloatermReplSendVisual<Cr>
xnoremap <silent><M-e>l :FloatermReplSendVisual!<Cr>
nnoremap <silent><M-e>q :FloatermReplSendExit<Cr>
nnoremap <silent><M-e>L :FloatermReplSendClear<Cr>
nnoremap <silent><M-e><Cr> :FloatermReplSendNewlineOrStart<Cr>
" block send, NOTE: bang! means stay
xnoremap <silent><M-e><M-e>   :FloatermReplSendVisual<Cr>
xnoremap <silent><M-e><Space> :FloatermReplSendVisual!<Cr>
nnoremap <silent><M-e><M-e>   :FloatermReplSendBlock<Cr>
nnoremap <silent><M-e><Space> :FloatermReplSendBlock!<Cr>
" send above, below, all lines, NOTE: bang! means stay
nnoremap <silent><M-e>b :FloatermReplSendFromBegin!<Cr>
nnoremap <silent><M-e>e :FloatermReplSendToEnd!<Cr>
nnoremap <silent><M-e>s :FloatermReplSendAll!<Cr>
" send word, NOTE: bang! means visual
nnoremap <silent><M-e>k :FloatermReplSendWord<Cr>
xnoremap <silent><M-e>k :FloatermReplSendWord!<Cr>
" mark print send, NOTE: bang! means visual
nnoremap <silent><M-e><M-m> :FloatermReplMark<Cr>
xnoremap <silent><M-e><M-m> :FloatermReplMark!<Cr>
nnoremap <silent><M-e><M-l> :FloatermReplSendMark<Cr>
nnoremap <silent><M-e><M-r> :FloatermReplQuickuiMark<Cr>
" ---------------------------------------
" jupynvim
" ---------------------------------------
if Installed('jupynium.nvim')
    " set url
    let g:jupynium_ip = get(g:, 'jupynium_ip', 'localhost')
    let g:jupynium_port = get(g:, 'jupynium_port', 9999)
    let g:jupynium_protocal = get(g:, 'jupynium_protocal', 'http')
    let jupynium_url = printf("%s://%s:%d/nbclassic", g:jupynium_protocal, g:jupynium_ip, g:jupynium_port)
    let g:jupynium_url = get(g:, 'jupynium_url', jupynium_url)
    " setup
    lua require("jupynium").setup({ default_notebook_URL = vim.g.jupynium_url, use_default_keybindings = false })
    function! s:jupynium_run(...)
        let jupynium_urls = get(g:, 'jupynium_urls', [g:jupynium_url])
        if len(jupynium_urls) == 1
            let t:jupynium_url = jupynium_urls[0]
        else
            let t:jupynium_url = ChooseOne(jupynium_urls, 'Choose a jupynium url', 1)
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
        nnoremap <buffer><C-\><Cr> :JupyniumStartSync <C-r>=get(t:, 'jupynium_url', '')<Cr>
        nnoremap <buffer><silent><C-\><Space> <Cmd>JupyniumKernelHover<Cr>
        nnoremap <buffer><silent><C-\><C-r> <Cmd>JupyniumRun<Cr>
        nnoremap <buffer><silent><C-\><C-t> <Cmd>JupyniumRunInTerminal<Cr>
        nnoremap <buffer><silent><C-\><C-q> <Cmd>JupyniumStopSync<Cr>
        nnoremap <buffer><silent><C-\><C-s> <Cmd>JupyniumKernelSelect<Cr>
        nnoremap <buffer><silent><C-\><C-b> <Cmd>JupyniumScrollToCell<Cr>
        nnoremap <buffer><silent><C-\><C-k> <Cmd>JupyniumScrollUp<Cr>
        nnoremap <buffer><silent><C-\><C-j> <Cmd>JupyniumScrollDown<Cr>
        nnoremap <buffer><silent><C-\><C-c> <Cmd>JupyniumClearSelectedCellsOutputs<Cr>
        xnoremap <buffer><silent><C-\><C-c> <Cmd>JupyniumClearSelectedCellsOutputs<Cr>
        nnoremap <buffer><silent><C-\><C-l> <Cmd>JupyniumExecuteSelectedCells<Cr>
        xnoremap <buffer><silent><C-\><C-l> <Cmd>JupyniumExecuteSelectedCells<Cr>
        nnoremap <buffer><silent><C-\><C-\> <Cmd>JupyniumExecuteSelectedCellsForword<Cr>
        nnoremap <buffer><silent><M-M> <Cmd>JupyniumCommands<Cr>
    endfunction
    au FileType python,r call s:map()
endif
