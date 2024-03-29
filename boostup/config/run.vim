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
            let g:gcc_cmd = 'time gcc -Wall -O2 $(VIM_FILEPATH) -o ~/.cache/build/$(VIM_FILENOEXT) && echo && time ~/.cache/build/$(VIM_FILENOEXT)'
        endif
        if executable('g++')
            let g:gpp_cmd = 'time g++ -Wall -O2 $(VIM_FILEPATH) -o ~/.cache/build/$(VIM_FILENOEXT) && echo && time ~/.cache/build/$(VIM_FILENOEXT)'
        endif
        if executable('rustc')
            let g:rustc_cmd = 'time rustc -o ~/.cache/build/$(VIM_FILENOEXT) $(VIM_FILEPATH) && echo && time ~/.cache/build/$(VIM_FILENOEXT)'
        endif
    elseif WINDOWS()
        if executable('gcc')
            let g:gcc_cmd = 'ptime gcc $(VIM_FILEPATH) -o ..\target\test\$(VIM_FILENOEXT).exe & ptime ..\target\test\$(VIM_FILENOEXT).exe'
        endif
        if executable('g++')
            let g:gpp_cmd = 'ptime g++ $(VIM_FILEPATH) -o ..\target\test\$(VIM_FILENOEXT).exe & ptime ..\target\test\$(VIM_FILENOEXT).exe'
        endif
        if executable('rustc')
            let g:rustc_cmd = 'ptime rustc -o ..\target\test\$(VIM_FILENOEXT).exe $(VIM_FILEPATH) & ptime ..\target\test\$(VIM_FILENOEXT).exe'
        endif
    endif
    nnoremap ! :AsyncRun<Space>
    xnoremap ! :<C-u>AsyncRun <C-R>=GetVisualSelection()<Cr>
    nnoremap <Tab>q :AsyncStop!<CR>
    nnoremap <Tab>Q :AsyncStop<CR>
    au FileType qf nnoremap <buffer><silent><C-c> :if get(g:, 'asyncrun_status', '') == 'running' \| AsyncStop! \| else \| echo 'No job running' \| endif<Cr>
else
    let s:run_command = "!"
    nnoremap ! :!
    xnoremap ! :<C-u>!<C-R>=GetVisualSelection()<Cr>
endif
function! s:asyncrun(...)
    w!
    if a:0 >= 2
        let pos = a:1
        let type = a:2
    elseif a:0 == 1
        let pos = a:1
        let type = 'term'
    else
        let pos = ''
        let type = 'qf'
    endif
    if !has('nvim') && v:version < 801
        let type = 'qf'
        if pos != ''
            let pos = 'right'
        endif
    endif
    if s:run_command == "!"
        let params = " "
        let type = "qf"
    elseif pos == 'external'
        let params = ' -cwd=$(VIM_FILEDIR) -mode=term -focus=1 -pos=external'
    elseif type == 'term'
        if pos == 'tab'
            let params = ' -cwd=$(VIM_FILEDIR) -mode=term -focus=1 -pos=tab -reuse'
        elseif pos == 'right'
            let params = ' -cwd=$(VIM_FILEDIR) -mode=term -focus=0 -pos=right -width=0.382'
        elseif pos == 'floaterm_float'
            let params = ' -cwd=$(VIM_FILEDIR) -mode=term -focus=0 -pos=floaterm_float -width=0.45 -height=0.3'
        elseif pos == 'floaterm_right'
            let params = ' -cwd=$(VIM_FILEDIR) -mode=term -focus=0 -pos=floaterm_right -width=0.45'
        else
            let params = ' -cwd=$(VIM_FILEDIR) -mode=term -focus=0 -pos=bottom -rows=0.3'
        endif
    else
        if has('patch-7.4.1829') || has('nvim')
            let params = ' -cwd=$(VIM_FILEDIR) -mode=async'
        else
            let params = ' -cwd=$(VIM_FILEDIR) -mode=bang'
        endif
    endif
    if WINDOWS()
        let time = ' ptime '
    else
        let time = ' time '
    endif
    if &ft ==# 'dosbatch' && WINDOWS()
        let run_cmd = s:run_command . params. ' ptime %'
    elseif &ft ==# 'sh' && executable('bash')
        let run_cmd = s:run_command . params . ' time bash %'
    elseif &ft ==# 'python' && executable('python')
        let run_cmd = s:run_command . params . time . 'python %'
    elseif &ft ==# 'r' && executable('Rscript')
        let run_cmd = s:run_command . params . time . 'Rscript %'
    elseif &ft ==# 'perl' && executable('perl')
        let run_cmd = s:run_command . params . time . 'perl %'
    elseif &ft ==# 'javascript' && executable('node')
        let run_cmd = s:run_command . params . time . 'node %'
    elseif &ft ==# 'go' && executable('go')
        let run_cmd = s:run_command . params . time . 'go run %'
    elseif &ft ==# 'vue' && executable('npm')
        let run_cmd = s:run_command . params . time . 'npm run %'
    elseif &ft ==# 'typescript' && executable('ts-node')
        let run_cmd = s:run_command . params . time . 'ts-node %'
    elseif &ft ==# 'javascript' && executable('node')
        let run_cmd = s:run_command . params . time . 'node %'
    " c && cpp && rust
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
    elseif &ft ==# 'rust' && get(g:, 'rustc_cmd', '') != ''
        if WINDOWS()
            silent! call mkdir("../target/test", "p")
        endif
        let run_cmd = s:run_command . params . ' '. g:rustc_cmd
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
        exec run_cmd
        if type == 'qf'
            if pos == 'right'
                wincmd H
                execute "vertical resize " . float2nr(&columns * 0.6)
            else
                wincmd p
                execute 'copen ' . g:asyncrun_open
            endif
        endif
    endif
endfunction
" basic run map
command! RunQfBottom call s:asyncrun('', 'qf')
nnoremap <silent><M-B> :RunQfBottom<CR>
if WINDOWS() || executable('gnome-terminal')
    command! RunExternal call s:asyncrun('external')
    nnoremap <silent><M-"> :RunExternal<CR>
endif
" advanced run map
if has('nvim') || v:version >= 801
    " run in tabterm
    let g:asyncrun_runner = get(g:, 'asyncrun_runner', {})
    command! RunTermTab call s:asyncrun('tab', 'term')
    nnoremap <silent><M-T> :RunTermTab<CR>
    " run in floaterm right
    function! s:floaterm_right(opts)
        let curr_bufnr = floaterm#buflist#curr()
        let cmd = 'FloatermNew --wintype=vsplit'
        if curr_bufnr == -1
            if has_key(a:opts, 'width')
                let cmd .= " --width=" . a:opts.width
            endif
            let cmd .= " --position=right"
            exec cmd
            let curr_bufnr = floaterm#buflist#curr()
        else
            call floaterm#terminal#open_existing(curr_bufnr)
        endif
        if has_key(a:opts, 'silent') && a:opts.silent == 1
            FloatermHide!
        endif
        let cd = 'cd ' . shellescape(getcwd())
        call floaterm#terminal#send(curr_bufnr, [cd])
        call floaterm#terminal#send(curr_bufnr, [a:opts.cmd])
        if get(a:opts, 'focus', 1) == 0
            stopinsert | noa wincmd p
        else
            call floaterm#util#startinsert()
        endif
    endfunc
    let g:asyncrun_runner.floaterm_right = function('s:floaterm_right')
    command! RunFloatermRight call s:asyncrun('floaterm_right', 'term')
    nnoremap <silent><M-R> :RunFloatermRight<CR>
    " run in floaterm float
    function! s:floaterm_float(opts)
        if !g:has_popup_floating
            call preview#errmsg("Please update to vim8.1+/nvim0.6+ to run script in floating or popu.")
            return
        endif
        let curr_bufnr = floaterm#buflist#curr()
        let cmd = 'FloatermNew --wintype=float'
        if curr_bufnr == -1
            if has_key(a:opts, 'width')
                let cmd .= " --width=" . a:opts.width
            endif
            if has_key(a:opts, 'height')
                let cmd .= " --height=" . a:opts.height
            else
                let cmd .= " --height=0.3"
            endif
            let cmd .= " --position=bottomright"
            exec cmd
            let curr_bufnr = floaterm#buflist#curr()
        else
            call floaterm#terminal#open_existing(curr_bufnr)
        endif
        if has_key(a:opts, 'silent') && a:opts.silent == 1
            FloatermHide!
        endif
        let cd = 'cd ' . shellescape(getcwd())
        call floaterm#terminal#send(curr_bufnr, [cd])
        call floaterm#terminal#send(curr_bufnr, [a:opts.cmd])
        if get(a:opts, 'focus', 1) == 0 && has('nvim')
            stopinsert | noa wincmd p
        elseif &ft == 'floaterm'
            call floaterm#util#startinsert()
        endif
    endfunction
    let g:asyncrun_runner.floaterm_float = function('s:floaterm_float')
    command! RunFloatermFloat call s:asyncrun('floaterm_float', 'term')
    nnoremap <silent><M-'> :RunFloatermFloat<CR>
else
    nnoremap <M-T> :call preview#errmsg("Please update to vim8.1+/nvim to run script in terminal.")<Cr>
    nnoremap <M-'> :call preview#errmsg("Please update to vim8.1+/nvim to run script in terminal.")<Cr>
    command! RunQfRight call s:asyncrun('right', 'qf')
    nnoremap <silent><M-R> :RunQfRight<CR>
endif
" ----------------
" asynctasks
" ----------------
if has('nvim') || v:version >= 801
    let g:asyncrun_rootmarks     = g:root_patterns
    let g:asynctasks_config_name = [".tasks", ".git/tasks.ini", ".hg/tasks.ini", ".svn/tasks.ini", ".root/tasks.ini", ".project/tasks.ini"]
    let g:asynctasks_rtp_config  = "tasks.ini"
    let g:asynctasks_term_reuse  = 1
    let g:asynctasks_term_focus  = 0
    let g:asynctasks_term_listed = 0
    let g:asynctasks_sort        = 1
    " template
    let g:asynctasks_template = '~/.leovim/boostup/tasks/tasks_template.ini'
    let g:asynctasks_extra_config = [
                \ '~/.leovim/boostup/tasks/tasks.ini',
                \ '~/.leovim.d/boostup/tasks/tasks.ini',
                \ ]
    " packadd
    PlugAddOpt 'asynctasks.vim'
    silent! call mkdir(Expand("~/.leovim.d/tasks"), 'p')
    " open template
    nnoremap <leader>r<Cr>  :tabe $LEOVIM_PATH/boostup/tasks/tasks_example.ini<Cr>
    nnoremap <leader>r<Tab> :tabe $HOME/.leovim.d/boostup/tasks/tasks.ini<Cr>
    " asynctask shortcuts
    nnoremap <leader>ra :AsyncTask
    nnoremap <leader>rm :AsyncTaskMacro<Cr>
    nnoremap <leader>re :AsyncTaskEdit<Space>
    " run shortcuts
    nnoremap <leader>rr :AsyncTask project-run<Cr>
    nnoremap <leader>ri :AsyncTask project-init<Cr>
    nnoremap <leader>rb :AsyncTask project-build<Cr>
    nnoremap <leader>rc :AsyncTask project-compile<Cr>
    nnoremap <leader>rd :AsyncTask project-debug<Cr>
    nnoremap <leader>rt :AsyncTask project-test<Cr>
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
    nnoremap <leader>rp :<C-u>AsyncTaskProfileLoop<CR>
    nnoremap <leader>rf :<C-u>AsyncTaskProfile<CR>
    if InstalledFzf()
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
