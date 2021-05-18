" --------------------------
" toggle quickfix
" --------------------------
function! s:OpenCloseQuickfix(type) abort
    if a:type < 2
        for i in range(1, winnr('$'))
            let bnum = winbufnr(i)
            if getbufvar(bnum, '&buftype') == 'quickfix'
                cclose
                lclose
                return
            endif
        endfor
    endif
    if a:type > 0
        let t:quickfix_return_to_window = winnr()
        execute "copen " . g:asyncrun_open
        execute t:quickfix_return_to_window . "wincmd w"
    endif
endfunction
command! CloseQuickfix  call s:OpenCloseQuickfix(0)
command! ToggleQuickfix call s:OpenCloseQuickfix(1)
command! OpenQuickfix   call s:OpenCloseQuickfix(2)
if get(g:, 'has_terminal', 0) == 0 || !exists('g:plugs')
    nnoremap <silent> q<C-m> :ToggleQuickfix<CR>
endif
nnoremap <silent> q<space> :CloseQuickfix<Cr>
" --------------------------
" repl tool
" --------------------------
au FileType python,sh,perl,javascript,lua imap <M-y> # %% ##############  ##############<C-o>F<space>
if g:has_terminal > 0 && executable('python')
    if has('nvim') && get(g:, 'terminal_plus', '') =~ 'floaterm'
        au FileType python,sh,perl,javascript,lua xmap <M-e> :FloatermSend<Cr>j
        au FileType python,sh,perl,javascript,lua nmap <M-e> :FloatermSend<Cr>j
        au FileType python,sh,perl,javascript,lua xmap <M-d> :FloatermSend<Cr>j
        au FileType python,sh,perl,javascript,lua nmap <M-d> vaB:FloatermSend<Cr>j:call search('# %%', 'eW')<Cr>j
        au FileType python,sh,perl,javascript,lua imap <M-e> <Esc>:FloatermSend<Cr>j
        au FileType python,sh,perl,javascript,lua imap <M-d> <Esc>vaB:FloatermSend<Cr>j:call search('# %%', 'eW')<Cr>j
        if executable('ipython')
            au FileType python nnoremap <leader>rr :FloatermNew ipython --no-autoindent<Cr>
        endif
    " vim-repl only for vim8+
    elseif v:version >= 800 && !has('nvim')
        if !exists('g:leovim_loaded')
            set rtp+=$ADDINS_PATH/vim-repl
        endif
        if get(g:, 'terminal_plus', '') == ''
            let g:terminal_plus = 'repl'
        else
            let g:terminal_plus .= '-repl'
        endif
        let g:sendtorepl_invoke_key = "<M-e>"
        let g:repl_position         = 3
        let g:repl_cursor_down      = 1
        let g:repl_python_automerge = 1
        let g:repl_console_name     = "REPL"
        let g:repl_predefine_python = {
                \ 'numpy':      'import numpy as np',
                \ 'matplotlib': 'from matplotlib import pyplot as plt'
                \ }
        if !exists('g:repl_program')
            let g:repl_program = {}
        endif
        let g:repl_program.python = []
        if executable('ipython')
            let g:repl_program.python += ['ipython']
        endif
        if (LINUX() || MACOS()) && executable('ptpython')
            let g:repl_program.python += ['ptpython']
        endif
        if executable('python3')
            let g:repl_program.python += ['python3']
        endif
        let g:repl_program.python += ['python']
        " map
        au Filetype python,sh,perl,javascript,lua call s:set_repl_map()
        function! s:set_repl_map() abort
            nmap <M-d> vaB<M-e>
            xmap <M-d> <M-e>
            imap <M-e> <ESC><M-e>
            imap <M-d> <ESC><M-d>
            nnoremap <leader>rr :<C-u>REPLToggle<Cr>
            nnoremap <leader>rl :REPL
        endfunction
        " ipdb settings
        if get(g:, 'ipdb_import', 0) > 0
            au Filetype python imap <M-u> import ipdb; ipdb.set_trace()
            au Filetype python call s:set_ipdb_map()
            function! s:set_ipdb_map() abort
                nnoremap <leader>re :<C-u>REPLDebugStopAtCurrentLine<Cr>
                nnoremap <leader>ru :<C-u>REPLPDBU<Cr>
                nnoremap <leader>rc :<C-u>REPLPDBC<Cr>
                nnoremap <leader>rn :<C-u>REPLPDBN<Cr>
                nnoremap <leader>rs :<C-u>REPLPDBS<Cr>
            endf
        endif
    endif
endif
" --------------------------
" asyncrun
" --------------------------
augroup Set asyncrun_rows
    au VimResized,VimEnter * call s:SetAsyncRunRows()
augroup END
function! s:SetAsyncRunRows()
    let row = float2nr(&lines * 0.23)
    if row < 10 && get(g:, 'asyncrun_open', 10) < 10
        let g:asyncrun_open = 10
    else
        let g:asyncrun_open = row
    endif
endfunction
if has('nvim') || has('timers') && has('channel') && has('job') && has('patch-7.4.1829')
    if !exists('g:leovim_loaded')
        set rtp+=$ADDINS_PATH/asyncrun.vim
        set rtp+=$ADDINS_PATH/asyncrun.extra
    endif
    nnoremap qs :AsyncStop<CR>
    nnoremap qu :AsyncStop!<CR>
    nnoremap qr :AsyncRun
    nnoremap qa :AsyncRun!
    if get(g:, 'has_terminal', 0) == 0 || !exists('g:plugs')
        nnoremap <silent> qt :AsyncStop!<Cr>:ToggleQuickfix<CR>
    endif
    if executable('git')
        if WINDOWS()
            nnoremap <M-G> :AsyncRun -mode=external git<Space>
        elseif g:has_terminal > 0
            nnoremap <M-G> :AsyncRun -mode=term -focus=1 git<Space>
        else
            nnoremap <M-G> :AsyncRun! -focus=1 git<Space>
        endif
    endif
    let $PYTHONUNBUFFERED=1
    let g:asyncrun_rootmarks = ['.root', '.git', '.svn', '.hg']
    au BufEnter * if (winnr("$") == 1 && exists("AsyncRun!")) | q | endif
    function! s:AsyncRunNow(type)
        w!
        if &filetype != '' && &filetype != 'markdown'
            if g:has_terminal > 0
                if a:type == 0
                    let params = "-mode=async -focus=0"
                elseif a:type == 1
                    if WINDOWS()
                        let params = '-mode=term -pos=external'
                    else
                        let params = '-mode=term -reuse -pos=tab -focus=1'
                    endif
                else
                    let params = '-mode=term -pos=floaterm'
                endif
            else
                if a:type == 2
                    let a:type = 1
                endif
                if WINDOWS() && a:type == 1
                    let params = '-pos=external'
                else
                    if has('patch-7.4.1829') || has('nvim')
                        let params = '-mode=async -focus=0'
                    else
                        let params = '-mode=bang'
                    endif
                endif
            endif
            if &filetype ==# 'dosbatch'
                exec "AsyncRun -raw=1 ".params." ptime %"
            elseif &filetype ==# 'python' && get(g:, 'python_exe_path', '') != ''
                if WINDOWS()
                    exec "AsyncRun -raw=1 ".params." ptime " . g:python_exe_path . " %"
                else
                    exec "AsyncRun -raw=1 ".params." time " . g:python_exe_path . " %"
                endif
            elseif &filetype ==# 'rust' && executable('cargo')
                if WINDOWS()
                    exec "AsyncRun -raw=1 ".params." ptime cargo run %"
                else
                    exec "AsyncRun -raw=1 ".params." time  cargo run %"
                endif
            elseif &filetype ==# 'go' && executable('go')
                if WINDOWS()
                    exec "AsyncRun -raw=1 ".params." ptime go run %"
                else
                    exec "AsyncRun -raw=1 ".params." time  go run %"
                endif
            elseif &filetype ==# 'java' && executable('java') && executable('javac')
                if WINDOWS()
                    exec "AsyncRun ".params." javac % -o %< & ptime java %<"
                else
                    exec "AsyncRun ".params." javac % -o %< ; time  java %<"
                endif
            elseif &filetype ==# 'sh' && executable('bash')
                exec "AsyncRun -raw=1 ".params." time bash %"
            elseif &filetype ==# 'perl' && executable('perl')
                if WINDOWS()
                    exec "AsyncRun ".params." ptime perl %"
                else
                    exec "AsyncRun ".params." time perl %"
                endif
            elseif &filetype ==# 'javascript' && executable('node')
                if WINDOWS()
                    exec "AsyncRun! ".params." -raw=1 ptime node %"
                else
                    exec "AsyncRun! ".params." -raw=1 time  node %"
                endif
            else
                call feedkeys(":AsyncRun")
            endif
        endif
    endfunction
    command! AsyncRunBot call <SID>AsyncRunNow(0)
    command! AsyncRunTab call <SID>AsyncRunNow(1)
    nnoremap <M-R>  :<C-u>AsyncRunBot<CR>
    nnoremap <M-T>  :<C-u>AsyncRunTab<CR>
    if get(g:, 'terminal_plus', '') =~ 'floaterm'
        " intergrated with asynctasks
        function! s:runner_proc(opts)
            let curr_bufnr = floaterm#curr()
            if has_key(a:opts, 'silent') && a:opts.silent == 1
                call floaterm#hide()
            endif
            let cmd = 'cd ' . shellescape(getcwd())
            call floaterm#terminal#send(curr_bufnr, [cmd])
            call floaterm#terminal#send(curr_bufnr, [a:opts.cmd])
            stopinsert
            if &filetype == 'floaterm' && g:floaterm_autoinsert
                startinsert
            endif
        endfunction
        let g:asyncrun_runner = get(g:, 'asyncrun_runner', {})
        let g:asyncrun_runner.floaterm = function('s:runner_proc')
        command! AsyncRunFloaterm call <SID>AsyncRunNow(2)
        nnoremap <M-A> :<C-u>AsyncRunFloaterm<CR>
    endif
    if !Installed('vim-sidebar-manager')
        nnoremap t<Tab> :AsyncStop!<Cr>:ToggleQuickfix<Cr>
    endif
    " ----------------
    " asynctasks
    " ----------------
    if has('nvim') || v:version >= 801
        if !exists('g:leovim_loaded')
            set rtp+=$ADDINS_PATH/asynctasks.vim
        endif
        let g:asynctasks_config_name  = [".root/asynctasks.ini", ".git/asynctasks.ini", ".hg/asynctasks.ini", ".svn/asynctasks.ini", ".asynctasks/asynctasks.ini"]
        let g:asynctasks_rtp_config   = "asynctasks.ini"
        let g:asynctasks_extra_config = [$ADDINS_PATH . "/asynctasks.ini"]
        let g:asynctasks_term_reuse   = 1
        let g:asynctasks_term_focus   = 0
        let g:asynctasks_term_listed  = 0
        " asynctask shortcuts
        nnoremap <M-r>; :<C-u>AsyncTask
        nnoremap <M-r>m :<C-u>AsyncTaskMacro<Cr>
        nnoremap <M-r>e :<C-u>AsyncTaskEdit<Space>
        " run shortcuts
        nnoremap <M-r><M-r> :<C-u>AsyncTask project-run<Cr>
        nnoremap <M-r>r :<C-u>AsyncTask project-run<Cr>
        nnoremap <M-r>b :<C-u>AsyncTask project-build<Cr>
        nnoremap <M-r>d :<C-u>AsyncTask project-debug<Cr>
        nnoremap <M-r>c :<C-u>AsyncTask project-compile<Cr>
        nnoremap <M-r>t :<C-u>AsyncTask project-test<Cr>
        nnoremap <M-r>i :<C-u>AsyncTask project-init<Cr>
        let g:asynctasks_template = {}
        let g:asynctasks_template.cargo = [
                    \ '[project-build]',
                    \ 'command=cargo build',
                    \ 'cwd=$(VIM_FILEDIR)/..',
                    \ 'errorformat=%. %#--> %f:%l:%c',
                    \ 'output=terminal',
                    \ 'pos=right',
                    \ 'cols=80',
                    \ '',
                    \ '[project-run]',
                    \ 'command=cargo run',
                    \ 'cwd=$(VIM_FILEDIR)/..',
                    \ 'output=terminal',
                    \ 'pos=right',
                    \ 'cols=80',
                    \ ]
        let g:asynctasks_template.cplusplus= [
                    \ '[project-build]',
                    \ 'command=clang++ $(VIM_FILEPATH) -std=c++2a -o $(VIM_PATHNOEXT)',
                    \ 'cwd=<root>',
                    \ 'errorformat=%. %#--> %f:%l:%c',
                    \ 'output=terminal',
                    \ 'pos=right',
                    \ 'cols=80',
                    \ '',
                    \ '[project-run]',
                    \ 'command=$(VIM_PATHNOEXT)',
                    \ 'cwd=<root>',
                    \ 'output=terminal',
                    \ 'pos=right',
                    \ 'cols=80',
                    \ ]
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
        nnoremap <M-r>, :<C-u>AsyncTaskProfileLoop<CR>
        nnoremap <M-r>. :<C-u>AsyncTaskProfile<CR>
        if g:fuzzy_finder == 'leaderf'
            function! s:lf_task_source(...)
                let rows = asynctasks#source(&columns * 48 / 100)
                let source = []
                for row in rows
                    let name = row[0]
                    let source += [name . '  ' . row[1] . '  : ' . row[2]]
                endfor
                return source
            endfunc
            function! s:lf_task_accept(line, arg)
                let pos = stridx(a:line, '<')
                if pos < 0
                    return
                endif
                let name = strpart(a:line, 0, pos)
                let name = substitute(name, '^\s*\(.\{-}\)\s*$', '\1', '')
                if name != ''
                    exec "AsyncTask " . name
                endif
            endfunc
            function! s:lf_task_digest(line, mode)
                let pos = stridx(a:line, '<')
                if pos < 0
                    return [a:line, 0]
                endif
                let name = strpart(a:line, 0, pos)
                return [name, 0]
            endfunc
            function! s:lf_win_init(...)
                setlocal nonumber
                setlocal nowrap
            endfunc
            let g:Lf_Extensions = get(g:, 'Lf_Extensions', {})
            let g:Lf_Extensions.tasks = {
                        \ 'source': string(function('s:lf_task_source'))[10:-3],
                        \ 'accept': string(function('s:lf_task_accept'))[10:-3],
                        \ 'get_digest': string(function('s:lf_task_digest'))[10:-3],
                        \ 'highlights_def': {
                        \     'Lf_hl_funcScope': '^\S\+',
                        \     'Lf_hl_funcDirname': '^\S\+\s*\zs<.*>\ze\s*:',
                        \ },
                        \ }
            nnoremap <M-t> :Leaderf tasks<Cr>
        elseif g:fuzzy_finder == 'fzf' || g:fuzzy_finder == 'coc'
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
            function! s:fzf_task()
                let rows = asynctasks#source(&columns * 48 / 100)
                let source = []
                for row in rows
                    let name = row[0]
                    let source += [name . '  ' . row[1] . '  : ' . row[2]]
                endfor
                let opts = { 'source': source, 'sink': function('s:fzf_sink'),
                            \ 'options': '+m --nth 1 --inline-info --tac' }
                if exists('g:fzf_layout')
                    for key in keys(g:fzf_layout)
                        let opts[key] = deepcopy(g:fzf_layout[key])
                    endfor
                endif
                call fzf#run(opts)
            endfunction
            command! -nargs=0 FZFAsyncTask call s:fzf_task()
            nnoremap <M-t> :FZFAsyncTask<Cr>
        endif
    endif
endif
