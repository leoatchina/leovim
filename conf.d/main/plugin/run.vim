" Skip in VSCode environment
if utils#is_vscode()
    finish
endif
" --------------------------
" set asyncrun_open
" --------------------------
au VimResized,VimEnter * call s:set_run_row()
function! s:set_run_row()
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
if pack#planned('asyncrun.vim')
    let g:asyncrun_rootmarks = g:root_patterns
    let s:run_command = "AsyncRun"
    if utils#is_win()
        let g:asyncrun_encs = get(g:, 'asyncrun_encs', 'gbk')
    else
        let g:asyncrun_encs = get(g:, 'asyncrun_encs', 'utf-8')
    endif
    if utils#is_unix()
        silent! call mkdir(utils#expand("$HOME/.cache/build"), "p")
        if executable('gcc')
            let g:asyncrun_gcc_cmd = 'gcc -Wall -O2 $(VIM_FILEPATH) -o ~/.cache/build/$(VIM_FILENOEXT) && echo && ~/.cache/build/$(VIM_FILENOEXT)'
        endif
        if executable('g++')
            let g:asyncrun_gpp_cmd = 'g++ -Wall -O2 $(VIM_FILEPATH) -o ~/.cache/build/$(VIM_FILENOEXT) && echo && ~/.cache/build/$(VIM_FILENOEXT)'
        endif
        if executable('rustc')
            let g:asyncrun_rustc_cmd = 'rustc -o ~/.cache/build/$(VIM_FILENOEXT) $(VIM_FILEPATH) && echo && ~/.cache/build/$(VIM_FILENOEXT)'
        endif
    elseif utils#is_win()
        if executable('gcc')
            let g:asyncrun_gcc_cmd = 'gcc $(VIM_FILEPATH) -o ..\target\test\$(VIM_FILENOEXT).exe & ..\target\test\$(VIM_FILENOEXT).exe'
        endif
        if executable('g++')
            let g:asyncrun_gpp_cmd = 'g++ $(VIM_FILEPATH) -o ..\target\test\$(VIM_FILENOEXT).exe & ..\target\test\$(VIM_FILENOEXT).exe'
        endif
        if executable('rustc')
            let g:asyncrun_rustc_cmd = 'rustc -o ..\target\test\$(VIM_FILENOEXT).exe $(VIM_FILEPATH) & ..\target\test\$(VIM_FILENOEXT).exe'
        endif
    endif
    nnoremap ! :AsyncRun<Space>
    xnoremap ! :<C-u>AsyncRun <C-R>=utils#get_visual()<Cr>
    nnoremap <Tab>q :AsyncStop!<CR>
    nnoremap <Tab>Q :AsyncStop<CR>
    xnoremap <M-a> :AsyncRun -raw<Space>
    au FileType qf nnoremap <buffer><silent><C-c> :if get(g:, 'asyncrun_status', '') == 'running' \| AsyncStop! \| else \| echo 'No job running' \| endif<Cr>
else
    let s:run_command = "!"
    nnoremap ! :!
    xnoremap ! :<C-u>!<C-R>=utils#get_visual()<Cr>
endif

" Probe once on the first Python run: -1 unknown, 0 unavailable, 1 available.
let s:pretty_errors = -1

function! s:asyncrun(...)
    let ft = &ft
    if ft == '' || &buftype != ''
        call preview#errmsg("empty filetype could not be runned.")
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
    let ft = &ft
    if ft ==# 'dosbatch' && utils#is_win()
        let run_cmd = s:run_command . params. ' %'
    elseif (ft ==# 'sh' || ft ==# 'bash') && executable('bash')
        let run_cmd = s:run_command . params . ' bash %'
    elseif ft ==# 'python' && executable(g:python_prog)
        let python = g:python_prog
        if s:pretty_errors == -1
            call system(shellescape(python) . ' -c ' . shellescape('import pretty_errors'))
            let s:pretty_errors = v:shell_error == 0
        endif
        let module = s:pretty_errors ? ' -m pretty_errors' : ''
        let run_cmd = s:run_command . params . ' ' . shellescape(python) . module . ' %'
    elseif ft ==# 'r' && executable('Rscript')
        let run_cmd = s:run_command . params . ' Rscript %'
    elseif ft ==# 'go' && executable('go')
        let run_cmd = s:run_command . params . ' go run %'
    elseif ft ==# 'perl' && executable('perl')
        let run_cmd = s:run_command . params . ' perl %'
    elseif ft ==# 'javascript' && executable('node')
        let run_cmd = s:run_command . params . ' node %'
    elseif ft ==# 'vue' && executable('npm')
        let run_cmd = s:run_command . params . ' npm run dev'
    elseif ft ==# 'typescript' && executable('ts-node')
        let run_cmd = s:run_command . params . ' ts-node %'
    elseif ft ==# 'javascript' && executable('node')
        let run_cmd = s:run_command . params . ' node %'
    " c && cpp
    elseif ft ==# 'c' && get(g:, 'asyncrun_gcc_cmd', '') != ''
        if utils#is_win()
            silent! call mkdir("../target/test", "p")
        endif
        let run_cmd = s:run_command . params . ' '. g:asyncrun_gcc_cmd
    elseif ft ==# 'cpp' && get(g:, 'asyncrun_gpp_cmd', '') != ''
        if utils#is_win()
            silent! call mkdir("../target/test", "p")
        endif
        let run_cmd = s:run_command . params . ' '. g:asyncrun_gpp_cmd
    elseif ft ==# 'rust' && get(g:, 'asyncrun_rustc_cmd', '') != ''
        if utils#is_win()
            silent! call mkdir("../target/test", "p")
        endif
        let run_cmd = s:run_command . params . ' '. g:asyncrun_rustc_cmd
    else
        let run_cmd = ''
    endif
    if empty(run_cmd)
        if ft ==# 'vim'
            echo "source current vim file"
            execute("source %")
        else
            call preview#errmsg('FileType ' . ft . ' could not be runned.')
        endif
    else
        if type == 'qf'
            if get(a:, 3, 0)
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
command! RunQfRight  call s:asyncrun('right',  'qf')
" ----------------
" asynctasks: plugin side coordination, config in cfg/asynctasks.vim
" ----------------
if pack#planned('asynctasks.vim')
    " ---------------------------------------------------
    " Task check firstly, if not, run in special position
    " ---------------------------------------------------
    function s:task_check(task_name)
        let tasks = asynctasks#list('')
        if len(tasks) == 0
            return 0
        endif
        for task in tasks
            if utils#trim(task['name']) == a:task_name
                return 1
            endif
        endfor
        return 0
    endfunc
    function s:task_run_or_pos(task_name, pos)
        let task_name = a:task_name
        let pos = a:pos
        if s:task_check(task_name)
            execute('AsyncTask ' . task_name)
        else
            if !has('nvim') && pos == 'floaterm_float' || pos == 'qf'
                RunQfSilent
            else
                call s:asyncrun(pos, 'term')
            endif
        endif
    endfunction
    " set commands
    command! TaskTestOrTab       call s:task_run_or_pos('task-test', 'tab')
    command! TaskFinalizeOrQf    call s:task_run_or_pos('task-finalize', 'qf')
    command! TaskRunOrRight      call s:task_run_or_pos('task-run', 'floaterm_right')
    command! TaskBuildOrBottom   call s:task_run_or_pos('task-build', 'floaterm_bottom')
    command! TaskFinalizeOrFloat call s:task_run_or_pos('task-finalize', 'floaterm_float')
    " map
    if has('nvim')
        nnoremap <silent><M-F> :TaskFinalizeOrFloat<CR>
    else
        nnoremap <silent><M-F> :TaskFinalizeOrQf<CR>
    endif
    nnoremap <silent><M-T> :TaskTestOrTab<CR>
    nnoremap <silent><M-R> :TaskRunOrRight<CR>
    nnoremap <silent><M-B> :TaskBuildOrBottom<CR>
else
    nnoremap <M-T> :call preview#errmsg("Please update to vim8.1+/nvim to run script in terminal.")<Cr>
    nnoremap <silent><M-B> :RunQfBottom<CR>
    nnoremap <silent><M-R> :RunQfRight<CR>
    nnoremap <silent><M-F> :RunQfSilent<CR>
endif
if utils#is_win() || executable('gnome-terminal') && utils#has_gui()
    command! RunExternal call s:asyncrun('external')
    nnoremap <silent><M-"> :RunExternal<CR>
endif
