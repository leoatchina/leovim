" ----------------
" asynctasks
" ----------------
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
" open template
function! asynctasks#tasks_open(...)
    if a:0
        if a:1 > 0
            tabe ~/.leovim/conf.d/tasks/tasks_template.ini
        else
            tabe ~/.leovim/conf.d/tasks/tasks_common.ini
        endif
    else
        call mkdir(utils#expand("$HOME/.leovim.d/tasks"), "p")
        tabe ~/.leovim.d/tasks/tasks.ini
        if &columns > &lines * 3
            vsplit ~/.leovim/conf.d/tasks/tasks_example.ini
        else
            split ~/.leovim/conf.d/tasks/tasks_example.ini
        endif
        wincmd p
    endif
endfunction
command! AsyncTaskDeploy call asynctasks#tasks_open()
command! AsyncTaskCommon call asynctasks#tasks_open(0)
command! AsyncTaskTemplate call asynctasks#tasks_open(1)
nnoremap <leader>rD :AsyncTaskDeploy<Cr>
nnoremap <leader>rC :AsyncTaskCommon<Cr>
nnoremap <leader>rE :AsyncTaskTemplate<Cr>
" asynctask shortcuts
command! AsyncTaskCommands call FzfCallCommands('AsyncTaskCommands', 'AsyncTask')
nnoremap <leader>r: :AsyncTaskCommands<Cr>
nnoremap <leader>rm :AsyncTaskMacro<Cr>
nnoremap <leader>re :AsyncTaskEdit<Space>
" run shortcuts
nnoremap <leader>ri :AsyncTask project-init<Cr>
nnoremap <leader>rb :AsyncTask project-build<Cr>
nnoremap <leader>rc :AsyncTask project-compile<Cr>
nnoremap <leader>rd :AsyncTask project-debug<Cr>
nnoremap <leader>rr :AsyncTask project-run<Cr>
nnoremap <leader>rt :AsyncTask project-test<Cr>
nnoremap <leader>r. :AsyncTaskLast<Cr>
function! asynctasks#profile_loop() abort
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
command! AsyncTaskProfileLoop call asynctasks#profile_loop()
nnoremap <leader>rp :<C-u>AsyncTaskProfileLoop<CR>
nnoremap <leader>rP :<C-u>AsyncTaskProfile<CR>
if pack#planned_fzf()
    function! asynctasks#fzf_sink(what)
        let p1 = stridx(a:what, '<')
        if p1 >= 0
            let name = strpart(a:what, 0, p1)
            let name = substitute(name, '^\s*\(.\{-}\)\s*$', '\1', '')
            if name != ''
                exec "AsyncTask ". fnameescape(name)
            endif
        endif
    endfunction
    function! asynctasks#fzf_tasks()
        let rows = asynctasks#source(&columns * 48 / 100)
        let source = []
        for row in rows
            let name = row[0]
            let source = [name . '  ' . row[1] . '  : ' . row[2]] + source
        endfor
        let opts = {'source': source, 'sink': function('asynctasks#fzf_sink'), 'options': '+m --nth 1 --inline-info --tac' }
        if exists('g:fzf_layout')
            for key in keys(g:fzf_layout)
                let opts[key] = deepcopy(g:fzf_layout[key])
            endfor
        endif
        call fzf#run(opts)
    endfunction
    command! -nargs=0 FzfAsyncTasks call asynctasks#fzf_tasks()
    nnoremap <silent><M-a> :FzfAsyncTasks<Cr>
endif
