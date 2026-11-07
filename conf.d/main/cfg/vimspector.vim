" ---------------------------------
" vimspector debug tool
" ---------------------------------
let g:vimspector_enable_auto_hover = 0
let g:vimspector_base_dir = utils#expand("~/.leovim.d/vimspector")
" load template
if pack#planned_fzf()
    function! ReadVimspectorTemplate(template_file) abort
        call debug#load_json(0, a:template_file)
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
    command! OpenVimspector call debug#load_json(0)
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
" VimspectorDisassemble
nmap <silent><M-e>D <Plug>VimspectorDisassemble
" session
nnoremap <M-e><M-l> :VimspectorLoadSession
nnoremap <M-e><M-m> :VimspectorMkSession<Cr>
nnoremap <M-e><M-n> :VimspectorNewSession<Space>
nnoremap <M-e><M-q> :VimspectorDestroySession<Space>
nnoremap <M-e><M-r> :VimspectorRenameSession<Space>
nnoremap <M-e><M-s> :VimspectorSwitchToSession<Space>
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
" commands
command! VimspectorCommands call FzfCallCommands('VimspectorCommands', 'Vimspector')
nnoremap <M-e>: :VimspectorCommands<Cr>
nnoremap <M-e>v :call vimspector#
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
nnoremap <silent><M-m>b :call vimspector#ListBreakpoints()<Cr>
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
" debug#vimspector_opened() is defined in plugin/debug.vim.
if pack#planned('vim-signify')
    au BufEnter * if exists('*debug#vimspector_opened') && debug#vimspector_opened() | SignifyDisable | endif
endif
function! s:vimspector_or_floaterm(type)
    if debug#vimspector_opened()
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
        TermNewOrFzfList
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
" view variables
nnoremap <silent>J :BalloonEval<Cr>
" deletewatch
au FileType VimspectorPrompt nnoremap <buffer><silent>x :call vimspector#DeleteWatch()<Cr>
