" --------------------------
" set asyncrun_open
" --------------------------
augroup SetRunOpen
    au VimResized,VimEnter * call s:SetRunRows()
augroup END
function! s:SetRunRows()
    let row = float2nr(&lines * 0.2)
    if row < 10 || get(g:, 'asyncrun_open', 10) < 10
        let g:asyncrun_open = 10
    else
        let g:asyncrun_open = row
    endif
endfunction
" --------------------------
" asyncrun
" --------------------------
if has('nvim') || has('timers') && has('channel') && has('job')
    let g:asyncrun_rootmarks = g:root_patterns
    let s:run_command = "AsyncRun"
    if WINDOWS()
        let g:asyncrun_encs = get(g:, 'asyncrun_encs', 'gbk')
    else
        let g:asyncrun_encs = get(g:, 'asyncrun_encs', 'utf-8')
    endif
    PlugAddOpt 'asyncrun.vim'
    if UNIX()
        silent! call mkdir(Expand("$HOME/.cache/build"), "p")
        if executable('gcc')
            let g:gcc_cmd = 'gcc -Wall -O2 $(VIM_FILEPATH) -o ~/.cache/build/$(VIM_FILENOEXT) && echo && ~/.cache/build/$(VIM_FILENOEXT)'
        endif
        if executable('g++')
            let g:gpp_cmd = 'g++ -Wall -O2 $(VIM_FILEPATH) -o ~/.cache/build/$(VIM_FILENOEXT) && echo && ~/.cache/build/$(VIM_FILENOEXT)'
        endif
    elseif WINDOWS()
        if executable('gcc')
            let g:gcc_cmd = 'gcc $(VIM_FILEPATH) -o ..\target\test\$(VIM_FILENOEXT).exe & ..\target\test\$(VIM_FILENOEXT).exe'
        endif
        if executable('g++')
            let g:gpp_cmd = 'g++ $(VIM_FILEPATH) -o ..\target\test\$(VIM_FILENOEXT).exe & ..\target\test\$(VIM_FILENOEXT).exe'
        endif
    endif
    nnoremap ! :AsyncRun<Space>
    xnoremap ! :<C-u>AsyncRun <C-R>=GetVisualSelection()<Cr>
    nnoremap <Tab>q :AsyncStop!<CR>
    nnoremap <Tab>Q :AsyncStop<CR>
    xnoremap <M-r> :AsyncRun -raw<Space>
    au FileType qf nnoremap <buffer><silent><C-c> :if get(g:, 'asyncrun_status', '') == 'running' \| AsyncStop! \| else \| echo 'No job running' \| endif<Cr>
else
    let s:run_command = "!"
    nnoremap ! :!
    xnoremap ! :<C-u>!<C-R>=GetVisualSelection()<Cr>
endif
function! s:asyncrun(...)
    if &ft == '' || &buftype != ''
        call preview#errmsg("nofiletype could not be runned.")
        return
    endif
    w!
    if !has('nvim') && v:version < 801
        let type = 'qf'
        if a:0
            let pos = a:1
        else
            let pos = 'bottom'
        endif
    elseif a:0 == 1
        let pos = a:1
        let type = 'term'
    elseif a:0 >= 2
        let pos = a:1
        let type = a:2
    else
        let pos = 'bottom'
        let type = 'qf'
    endif
    if s:run_command == "!"
        let params = " "
        let type = "qf"
    elseif pos == 'external'
        let params = ' -cwd=$(VIM_FILEDIR) -mode=term -focus=1 -pos=external'
    elseif type == 'term'
        if pos == 'tab'
            let params = ' -cwd=$(VIM_FILEDIR) -mode=term -focus=1 -pos=tab -reuse'
        elseif pos == 'floaterm_right'
            let params = ' -cwd=$(VIM_FILEDIR) -mode=term -focus=0 -pos=floaterm_right -width=0.45'
        elseif pos == 'floaterm_float'
            let params = ' -cwd=$(VIM_FILEDIR) -mode=term -focus=0 -pos=floaterm_float -width=0.45 -height=0.3'
        elseif pos == 'floaterm_bottom'
            let params = ' -cwd=$(VIM_FILEDIR) -mode=term -focus=0 -pos=floaterm_bottom -height=0.3'
        elseif pos == 'right'
            let params = ' -cwd=$(VIM_FILEDIR) -mode=term -focus=0 -pos=right -width=0.45'
        else
            let params = ' -cwd=$(VIM_FILEDIR) -mode=term -focus=0 -pos=bottom -height=0.3'
        endif
    else
        if has('patch-7.4.1829') || has('nvim')
            let params = ' -cwd=$(VIM_FILEDIR) -mode=async'
        else
            let params = ' -cwd=$(VIM_FILEDIR) -mode=bang'
        endif
    endif
    if &ft ==# 'dosbatch' && WINDOWS()
        let run_cmd = s:run_command . params. ' %'
    elseif &ft ==# 'sh' && executable('bash')
        let run_cmd = s:run_command . params . ' bash %'
    elseif &ft ==# 'python' && executable('python3')
        let run_cmd = s:run_command . params . ' python3 %'
    elseif &ft ==# 'python' && executable('python')
        let run_cmd = s:run_command . params . ' python %'
    elseif &ft ==# 'r' && executable('Rscript')
        let run_cmd = s:run_command . params . ' Rscript %'
    elseif &ft ==# 'go' && executable('go')
        let run_cmd = s:run_command . params . ' go run %'
    elseif &ft ==# 'perl' && executable('perl')
        let run_cmd = s:run_command . params . ' perl %'
    elseif &ft ==# 'javascript' && executable('node')
        let run_cmd = s:run_command . params . ' node %'
    elseif &ft ==# 'vue' && executable('npm')
        let run_cmd = s:run_command . params . ' npm run %'
    elseif &ft ==# 'typescript' && executable('ts-node')
        let run_cmd = s:run_command . params . ' ts-node %'
    elseif &ft ==# 'javascript' && executable('node')
        let run_cmd = s:run_command . params . ' node %'
    " c && cpp
    elseif &ft ==# 'c' && get(g:, 'gcc_cmd', '') != ''
        if WINDOWS()
            silent! call mkdir("../target/test", "p")
        endif
        let run_cmd = s:run_command . params . ' '. g:gcc_cmd
    elseif &ft ==# 'cpp' && get(g:, 'gpp_cmd', '') != ''
        if WINDOWS()
            silent! call mkdir("../target/test", "p")
        endif
        let run_cmd = s:run_command . params . ' '. g:gpp_cmd
    else
        let run_cmd = ''
    endif
    if empty(run_cmd)
        if &ft ==# 'vim'
            echo "source current vim file"
            execute("source %")
        else
            call preview#errmsg('FileType ' . &ft . ' could not be runned.')
        endif
    else
        if type == 'qf'
            if a:0 >= 3 || a:3
                let asyncrun_open = g:asyncrun_open
                let g:asyncrun_open = 0
                exec run_cmd
                let g:asyncrun_open = asyncrun_open
            else
                exec run_cmd
                if pos == 'right'
                    wincmd H
                    execute "vertical resize " . float2nr(&columns * 0.6)
                else
                    wincmd p
                endif
            endif
        else
            exec run_cmd
        endif
    endif
endfunction
command! RunQfSilent call s:asyncrun('bottom', 'qf', 1)
command! RunQfBottom call s:asyncrun('bottom', 'qf')
command! RunQfRight call s:asyncrun('right', 'qf')
" -------------------------
" run in floterm
" -------------------------
if has('nvim') || v:version >= 801
    " run in tabterm
    let g:asyncrun_runner = get(g:, 'asyncrun_runner', {})
    command! RunTermTab call s:asyncrun('tab', 'term')
    nnoremap <silent><M-T> :RunTermTab<CR>
    " run in floaterm right/bottom
    function! s:floaterm(opts, wintype, position)
        if !g:has_popup_floating && a:wintype == 'float'
            call preview#errmsg("Please update to vim8.1+/nvim0.6+ to run script in floating or popup window.")
            return
        endif
        let found_same_floaterm = v:false
        let buflist = floaterm#buflist#gather()
        if len(buflist) > 0
            for floaterm_bufnr in buflist
                " NOTE: found floaterm of same floaterm wintype
                if floaterm#config#get(floaterm_bufnr, 'wintype') == a:wintype
                    let found_same_floaterm = v:true
                    break
                endif
            endfor
        endif
        if found_same_floaterm
            call floaterm#terminal#open_existing(floaterm_bufnr)
        else
            let cmd = 'FloatermNew --wintype=' . a:wintype
            if has_key(a:opts, 'width')
                let cmd .= " --width=" . a:opts.width
            elseif a:wintype == 'float'
                let cmd .= " --width=0.7"
            elseif a:wintype == 'vsplit'
                let cmd .= " --width=0.45"
            endif
            if has_key(a:opts, 'height')
                let cmd .= " --height=" . a:opts.height
            elseif a:wintype == 'float' || a:wintype == 'split'
                let cmd .= " --height=0.3"
            endif
            let cmd .= " --position=" . a:position
            exec cmd
            let floaterm_bufnr = floaterm#buflist#curr()
        endif
        if has_key(a:opts, 'silent') && a:opts.silent == 1
            FloatermHide!
        endif
        let cd = 'cd ' . shellescape(getcwd())
        call floaterm#terminal#send(floaterm_bufnr, [cd])
        call floaterm#terminal#send(floaterm_bufnr, [a:opts.cmd])
        if get(a:opts, 'focus', 1) == 0
            if has('nvim')
                stopinsert | noa wincmd p
            elseif a:wintype != 'float'
                call feedkeys("\<C-_>w", "n")
            endif
        elseif &ft == 'floaterm'
            call floaterm#util#startinsert()
        endif
    endfunction
    function! s:floaterm_right(opts)
        call s:floaterm(a:opts, 'vsplit', 'right')
    endfunc
    function! s:floaterm_float(opts)
        call s:floaterm(a:opts, 'float', 'bottomright')
    endfunc
    function! s:floaterm_bottom(opts)
        call s:floaterm(a:opts, 'split', 'botright')
    endfunc
    let g:asyncrun_runner.floaterm_right = function('s:floaterm_right')
    let g:asyncrun_runner.floaterm_float = function('s:floaterm_float')
    let g:asyncrun_runner.floaterm_bottom = function('s:floaterm_bottom')
    command! RunFloatermRight call s:asyncrun('floaterm_right', 'term')
    command! RunFloatermFloat call s:asyncrun('floaterm_float', 'term')
    command! RunFloatermBottom call s:asyncrun('floaterm_bottom', 'term')
    nnoremap <silent><M-R> :RunFloatermRight<CR>
    nnoremap <silent><M-B> :RunFloatermBottom<CR>
    if has('nvim')
        nnoremap <silent><M-F> :RunFloatermFloat<CR>
    else
        nnoremap <silent><M-F> :RunQfSilent<CR>
    endif
else
    nnoremap <M-T> :call preview#errmsg("Please update to vim8.1+/nvim to run script in terminal.")<Cr>
    nnoremap <silent><M-B> :RunQfBottom<CR>
    nnoremap <silent><M-R> :RunQfRight<CR>
    nnoremap <silent><M-F> :RunQfSilent<CR>
endif
if WINDOWS() || executable('gnome-terminal') && HAS_GUI()
    command! RunExternal call s:asyncrun('external')
    nnoremap <silent><M-"> :RunExternal<CR>
endif
" SmartRunTerm is for different filetypes
function SmartRunTerm(cmd, pos)
    if a:pos ==# 'smart'
        if &columns > &lines * 3
            execute "AsyncRun -cwd=$(VIM_FILEDIR) -focus=0 -mode=term -pos=floaterm_right -width=0.45 " .  a:cmd
        else
            if has("nvim")
                execute "AsyncRun -cwd=$(VIM_FILEDIR) -focus=0 -mode=term -pos=floaterm_float -width=0.9 -height=0.4 " .  a:cmd
            else
                execute "AsyncRun -cwd=$(VIM_FILEDIR) -focus=0 -mode=term -pos=floaterm_bottom -height=0.4 " .  a:cmd
            endif
        endif
    elseif a:pos ==# "external"
        execute "AsyncRun -cwd=$(VIM_FILEDIR) -focus=1 -mode=external " . a:cmd
    else
        execute "AsyncRun -cwd=$(VIM_FILEDIR) -focus=1 -mode=term -pos=" . a:pos . " " . a:cmd
    endif
endfunction
" ----------------
" asynctasks
" ----------------
if has('nvim') || v:version >= 801
    let g:asyncrun_rootmarks     = g:root_patterns
    let g:asynctasks_config_name = [".vim/tasks.ini", ".git/tasks.ini", ".vscode/tasks.ini"]
    let g:asynctasks_rtp_config  = "tasks.ini"
    let g:asynctasks_term_reuse  = 1
    let g:asynctasks_term_focus  = 0
    let g:asynctasks_term_listed = 0
    let g:asynctasks_sort        = 1
    " template
    let g:asynctasks_template = '~/.leovim/conf.d/tasks/tasks_template.ini'
    let g:asynctasks_extra_config = [
                \ '~/.leovim/conf.d/tasks/tasks_common.ini',
                \ '~/.leovim.d/tasks/tasks.ini',
                \ ]
    " packadd
    PlugAddOpt 'asynctasks.vim'
    " open template
    function! s:tasks_open(...)
        if a:0
            if a:1 > 0
                tabe ~/.leovim/conf.d/tasks/tasks_template.ini
            else
                tabe ~/.leovim/conf.d/tasks/tasks_common.ini
            endif
        else
            call mkdir("$HOME/.leovim.d/tasks", "p")
            tabe ~/.leovim.d/tasks/tasks.ini
            if &columns > &lines * 3
                vsplit ~/.leovim/conf.d/tasks/tasks_example.ini
            else
                split ~/.leovim/conf.d/tasks/tasks_example.ini
            endif
            wincmd p
        endif
    endfunction
    command! AsyncTaskDeploy call s:tasks_open()
    command! AsyncTaskCommon call s:tasks_open(0)
    command! AsyncTaskTemplate call s:tasks_open(1)
    nnoremap <leader>r<Cr> :AsyncTaskDeploy<Cr>
    nnoremap <leader>r<Tab> :AsyncTaskTemplate<Cr>
    nnoremap <leader>r<Space> :AsyncTaskCommon<Cr>
    " asynctask shortcuts
    command! AsyncTaskCommands call FzfCallCommands('AsyncTaskCommands', 'AsyncTask')
    nnoremap <leader>ra :AsyncTaskCommands<Cr>
    nnoremap <leader>rm :AsyncTaskMacro<Cr>
    nnoremap <leader>re :AsyncTaskEdit<Space>
    " run shortcuts
    nnoremap <leader>ri :AsyncTask project-init<Cr>
    nnoremap <leader>rr :AsyncTask project-run<Cr>
    nnoremap <leader>rt :AsyncTask project-test<Cr>
    nnoremap <leader>rb :AsyncTask project-build<Cr>
    nnoremap <leader>rc :AsyncTask project-compile<Cr>
    nnoremap <leader>rd :AsyncTask project-debug<Cr>
    nnoremap <leader>ru :AsyncTask project-push<Cr>
    nnoremap <leader>rp :AsyncTask project-pull<Cr>
    function! AsyncTaskProfileLoop() abort
        if get(g:, 'asynctasks_profile', '') == ''
            let g:asynctasks_profile = 'debug'
        elseif g:asynctasks_profile == 'debug'
            let g:asynctasks_profile = 'build'
        elseif g:asynctasks_profile == 'build'
            let g:asynctasks_profile = 'release'
        elseif g:asynctasks_profile == 'release'
            let g:asynctasks_profile = 'debug'
        endif
        echom "asynctasks_profile is " . g:asynctasks_profile
    endfunction
    command! AsyncTaskProfileLoop call AsyncTaskProfileLoop()
    nnoremap <leader>rL :<C-u>AsyncTaskProfileLoop<CR>
    nnoremap <leader>rf :<C-u>AsyncTaskProfile<CR>
    if PlannedFzf()
        function! s:fzf_sink(what)
            let p1 = stridx(a:what, '<')
            if p1 >= 0
                let name = strpart(a:what, 0, p1)
                let name = substitute(name, '^\s*\(.\{-}\)\s*$', '\1', '')
                if name != ''
                    exec "AsyncTask ". fnameescape(name)
                endif
            endif
        endfunction
        function! s:fzf_tasks()
            let rows = asynctasks#source(&columns * 48 / 100)
            let source = []
            for row in rows
                let name = row[0]
                let source = [name . '  ' . row[1] . '  : ' . row[2]] + source
            endfor
            let opts = {'source': source, 'sink': function('s:fzf_sink'), 'options': '+m --nth 1 --inline-info --tac' }
            if exists('g:fzf_layout')
                for key in keys(g:fzf_layout)
                    let opts[key] = deepcopy(g:fzf_layout[key])
                endfor
            endif
            call fzf#run(opts)
        endfunction
        command! -nargs=0 FzfAsyncTasks call s:fzf_tasks()
        nnoremap <silent><M-r> :FzfAsyncTasks<Cr>
    endif
endif
