nnoremap <silent>- :call preview#errmsg("Please intalled debug plugins.")<Cr>
nnoremap _ -
inoremap !! !=
" --------------------
" J show diag
" --------------------
function! s:diag_or_errmsg(diagnostic)
    if a:diagnostic
        if Planned('ale')
            ALEDetail
        elseif PlannedCoc()
            call CocActionAsync('diagnosticInfo')
        elseif InstalledNvimLsp()
            lua vim.diagnostic.open_float()
        else
            call preview#errmsg('Please select lines to merge!') | sleep 2
        endif
    else
        call preview#errmsg('Please select lines to merge!') | sleep 2
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
nnoremap <silent><Tab>: :FloatermCommands<Cr>
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
inoremap <silent><C-\><C-f> <C-o>:FloatermList<Cr>
nnoremap <silent><C-\><C-f> :FloatermList<Cr>
tnoremap <silent><C-/> <C-\><C-n>:FloatermList<Cr>
inoremap <silent><C-/> <C-o>:FloatermList<Cr>
nnoremap <silent><C-/> :FloatermList<Cr>
" ---------------------------------
" debug: load_json
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
            let json_dir = fnamemodify(GetRootDir() . '/.vim', ':p')
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
" -----------------
" vimspector
" -----------------
if Planned('vimspector')
    let g:debug_tool = "vimspector"
    let g:vimspector_enable_auto_hover = 0
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
    nmap <leader>rI :VimspectorInstall<Space>
    nmap <leader>rL :call vimspector#GetConfigurations()<Left>
    nmap <silent><M-d>, <Plug>VimspectorJumpToPreviousBreakpoint
    nmap <silent><M-d>; <Plug>VimspectorJumpToNextBreakpoint
    nmap <silent><M-d><Space> <Plug>VimspectorToggleBreakpoint
    nmap <silent><M-d><M-d> <Plug>VimspectorRunToCursor
    nmap <silent><M-d><Tab> <Plug>VimspectorDisassemble
    nmap <silent><M-d><Cr> <Plug>VimspectorContinue
    nmap <silent><M-d>n <Plug>VimspectorStepOver
    nmap <silent><M-d>i <Plug>VimspectorStepInto
    nmap <silent><M-d>o <Plug>VimspectorStepOut
    nmap <silent><M-d>p <Plug>VimspectorPause
    nmap <silent><M-d>q :call vimspector#Reset()<Cr>
    nmap <silent><M-d>r :call vimspector#Launch()<Cr>
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
    command! VimspectorCommands call FzfCallCommands('VimspectorCommands', 'Vimspector')
    nnoremap <M-d>: :VimspectorCommands<Cr>
    nnoremap <M-d>v :call vimspector#
    " breakpoint
    nnoremap <silent><M-d>c :call vimspector#ClearBreakpoints()<Cr>
    nnoremap <silent><M-d>f :call vimspector#AddFunctionBreakpoint('')<left><left>
    nnoremap <silent><M-d>b :call vimspector#ToggleAllBreakpointsViewBreakpoint()<Cr>
    " start / stop
    nnoremap <silent><M-d>. :call .()<Cr>
    nnoremap <silent><M-d>Q :call vimspector#Stop({'interactive': v:true})<Cr>
    " function
    nnoremap <silent><M-d>u :call vimspector#UpFrame()<Cr>
    nnoremap <silent><M-d>d :call vimspector#DownFrame()<Cr>
    " --------------------------------------
    " jump/show windows in vimspector
    " --------------------------------------
    function! GoToVimspectorWindow(name) abort
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
        if windowNr >= 0
            execute windowNr . 'wincmd w'
        endif
    endfunction
    nnoremap <silent><M-'>  :call vimspector#ListBreakpoints()<Cr>
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
    au BufEnter * if s:vimspector_opened() | SignifyDisable | endif
    function! s:vimspector_opened()
        return bufwinnr('vimspector.Variables') >= 0 && bufwinnr('vimspector.Watches') >= 0 && bufwinnr('vimspector.StackTrace') >= 0
    endfunction
    function! s:vimspector_or_floaterm(type)
        if s:vimspector_opened()
            if a:type ==# 'code'
                try
                    let windowNr = bufwinnr(winbufnr(g:vimspector_session_windows['code']))
                    execute windowNr . 'wincmd w'
                catch /.*/
                    call preview#errmsg('No code window')
                endtry
            elseif a:type ==# 'eval'
                execute  "normal \<Plug>VimspectorBalloonEval"
            else
                call vimspector#ShowOutput(a:type)
            endif
        elseif a:type ==# 'Console'
            FloatermToggle
        elseif a:type ==# 'terminal'
            FloatermSpecial
        elseif a:type ==# 'eval'
            call s:diag_or_errmsg(1)
        endif
    endfunction
    command! BalloonEval call s:vimspector_or_floaterm('eval')
    command! FocusCode call s:vimspector_or_floaterm("code")
    command! ConsoleOrFloatermToggle call s:vimspector_or_floaterm('Console')
    command! TerminalOrFloatermSpecial call s:vimspector_or_floaterm('terminal')
    " other important map
    nnoremap <silent><M-m>0 :FocusCode<Cr>
    nnoremap <silent><M--> :ConsoleOrFloatermToggle<Cr>
    nnoremap <silent><M-=> :TerminalOrFloatermSpecial<Cr>
    " VimspectorDisassemble
    nmap <silent><F1> <Plug>VimspectorDisassemble
    " ----------------------
    " view variables
    " ----------------------
    nnoremap <silent>J :BalloonEval<Cr>
elseif Installed('nvim-dap', 'nvim-dap-ui', 'nvim-nio', 'mason.nvim', 'mason-nvim-dap.nvim')
    let g:debug_tool = 'nvim-dap'
    lua require("cfg/dap")
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
    nnoremap <leader>rI :DapInstall<Space>
    nnoremap <leader>rU :DapUninstall<Space>
    nnoremap <leader>rL :lua DapLoadConfig()<Left>
    nnoremap <silent><M-d>, <cmd>lua DapBreakpointPrev()<Cr>
    nnoremap <silent><M-d>; <cmd>lua DapBreakpointNext()<Cr>
    nnoremap <silent><M-d><Space> <cmd>lua require"dap".toggle_breakpoint()<Cr>
    nnoremap <silent><M-d><M-d> <cmd>lua DapRunToCusor()<Cr>
    nnoremap <silent><M-d><Cr> <cmd>lua DapContinue()<Cr>
    nnoremap <silent><M-d>n <cmd>lua require"dap".step_over()<Cr>
    nnoremap <silent><M-d>N <cmd>lua require"dap".step_back()<Cr>
    nnoremap <silent><M-d>i <cmd>lua require"dap".step_into()<Cr>
    nnoremap <silent><M-d>o <cmd>lua require"dap".step_out()<Cr>
    nnoremap <silent><M-d>p <cmd>lua require"dap".pause()<Cr>
    nnoremap <silent><M-d>q <cmd>lua DapReset()<Cr>
    nnoremap <silent><F3> <cmd>lua DapReset()<Cr>
    nnoremap <silent><F4> <cmd>lua DapRunToCusor()<Cr>
    nnoremap <silent><F5> <cmd>lua DapContinue()<Cr>
    nnoremap <silent><F6> <cmd>lua require"dap".pause()<Cr>
    nnoremap <silent><F7> <cmd>lua DapBreakpointPrev()<Cr>
    nnoremap <silent><F8> <cmd>lua DapBreakpointNext()<Cr>
    nnoremap <silent><F9> <cmd>lua require"dap".toggle_breakpoint()<Cr>
    nnoremap <silent><F10> <cmd>lua require"dap".step_over()<Cr>
    nnoremap <silent><F11> <cmd>lua require"dap".step_into()<Cr>
    nnoremap <silent><F12> <cmd>lua require"dap".step_out()<Cr>
    " basic <M-d> map
    nnoremap <M-d>l :lua require"dap".
    nnoremap <silent><M-d>. <cmd>lua require"dap".run_last()<Cr>
    nnoremap <silent><M-d>a <cmd>lua require"dap".attach(vim.fn.input('Attatch to: '))<Cr>
    " breakpoints
    nnoremap <silent><M-d>c <cmd>lua require"dap".clear_breakpoints()<Cr>
    nnoremap <silent><M-d>e <cmd>lua require"dap".set_exception_breakpoints("")<left><left>
    nnoremap <silent><M-d>s <cmd>lua require"dap".set_breakpoint()<left>
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
        return bufwinnr("DAP Scopes") >= 0 && bufwinnr("DAP Watches") >= 0 && bufwinnr("DAP Stacks") >= 0
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
                call s:diag_or_errmsg(1)
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
            FloatermSpecial
        else
            call preview#errmsg('Please start dap session.') | sleep 2
        endif
    endfunction
    command! DapUIEval call s:dap_or_floaterm("eval")
    command! FocusCode call s:dap_or_floaterm("focus")
    command! ReplOrFloatermToggle call s:dap_or_floaterm("repl")
    command! FloatElementOrFloatermSpecial call s:dap_or_floaterm("element")
    " other important map
    nnoremap <silent><M-m>0 :FocusCode<Cr>
    nnoremap <silent><M--> :ReplOrFloatermToggle<Cr>
    nnoremap <silent><M-=> :FloatElementOrFloatermSpecial<Cr>
    " ----------------------
    " view variables
    " ----------------------
    nnoremap <silent>J :DapUIEval<Cr>
elseif v:version >= 801 && !has('nvim') && Require('termdebug')
    let g:debug_tool = 'termdebug'
    let g:termdebug_map_K = 1
    let g:termdebug_use_prompt = 1
    packadd termdebug
    nnoremap <M-d><Space> :Break<Space>
    nnoremap <M-d><M-d> :Until<Cr>
    nnoremap <M-d><Cr> :Continue<Cr>
    nnoremap <M-d>c :Clear<Space>
    nnoremap <M-d>r :Run<Space>
    nnoremap <M-d>n :Over<Cr>
    nnoremap <M-d>i :Step<Cr>
    nnoremap <M-d>o :Finish<Cr>
    nnoremap <M-d>a :Arguments<Space>
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
    nnoremap - :Evaluate<Space>
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
    if Installed('nvim-dap')
        if !s:dapui_opened()
            call preview#errmsg("Please start nvim-dap session first.")
            return
        endif
    elseif Installed('vimspector')
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
        let l:selected_text = expand('<cword>')
    endif
    " Trim whitespace
    let l:selected_text = trim(l:selected_text)
    if !empty(l:selected_text)
        try
            if Installed('vimspector')
                call vimspector#AddWatch(l:selected_text)
            elseif Installed('nvim-dap')
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
au FileType VimspectorPrompt nnoremap <buffer><silent>x :call vimspector#DeleteWatch()<Cr>
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
call s:bind_keymap('<M-->', 'FloatermToggle')
call s:bind_keymap('<M-=>', 'FloatermSpecial')
call s:bind_keymap('<M-_>', 'FloatermKill')
" ---------------------------------------
" using vim-floaterm to do repl
" ---------------------------------------
PlugAddOpt 'vim-floaterm-repl'
" NOTE: below bang[!] means cursor not move
" start
nnoremap <silent><M-e>r :FloatermReplStart!<Cr>
nnoremap <silent><M-e><Cr> :FloatermReplSendNewlineOrStart<Cr>
" basic send
nnoremap <silent><M-e>n :FloatermReplSend<Cr>
nnoremap <silent><M-e>l :FloatermReplSend!<Cr>
xnoremap <silent><M-e>n :FloatermReplSendVisual<Cr>
xnoremap <silent><M-e>l :FloatermReplSendVisual!<Cr>
nnoremap <silent><M-e>q :FloatermReplSendExit<Cr>
" block send
xnoremap <silent><M-e><M-e>   :FloatermReplSendVisual<Cr>
xnoremap <silent><M-e><Space> :FloatermReplSendVisual!<Cr>
nnoremap <silent><M-e><M-e>   :FloatermReplSendBlock<Cr>
nnoremap <silent><M-e><Space> :FloatermReplSendBlock!<Cr>
" send above/below/all lines
nnoremap <silent><M-e>b :FloatermReplSendFromBegin!<Cr>
nnoremap <silent><M-e>e :FloatermReplSendToEnd!<Cr>
nnoremap <silent><M-e>a :FloatermReplSendAll!<Cr>
" send word
nnoremap <silent><M-e>k :FloatermReplSendWord<Cr>
xnoremap <silent><M-e>k :FloatermReplSendWord!<Cr>
" mark print send
nnoremap <silent><M-e>m :FloatermReplMark<Cr>
xnoremap <silent><M-e>m :FloatermReplMark!<Cr>
nnoremap <silent><M-e>s :FloatermReplSendMark<Cr>
nnoremap <silent><M-e>q :FloatermReplQuickuiMark<Cr>
" clear
nnoremap <silent><M-e>L :FloatermReplSendClear<Cr>
" ---------------------------------------
" jupynvim
" ---------------------------------------
if Installed('jupynium.nvim')
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
    command! JupyniumCommands call FzfCallCommands('JupyniumCommands', 'Jupynium', 'SetPython3Host', ['JupyniumRun'])
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
