" Skip in VSCode environment
if utils#is_vscode()
    finish
endif
augroup AutoClose
    autocmd!
    autocmd BufWinEnter,BufEnter * if utils#autoclose_lastwin() | q! | endif
augroup END
" -------------------------
" confirm quit
" -------------------------
" 执行退出操作
function! s:do_quit(save) abort
    UndotreeHide
    if a:save
        wq!
    else
        q!
    endif
endfunction

" 执行全部退出
function! s:do_quit_all() abort
    UndotreeHide
    if exists(':cquit')
        cquit
    else
        qall!
    endif
endfunction

" 处理用户选择
function! s:handle_choice(choice, type) abort
    if a:choice =~# '^Save'
        call s:do_quit(1)
    elseif a:choice =~# '^Quit'
        if a:type == 'all'
            call s:do_quit_all()
        else
            call s:do_quit(0)
        endif
    elseif a:choice =~# '^Kill'
        FloatermKill
    endif
endfunction

function! s:confirm_quit(type) abort
    " floaterm 处理：非 all 模式下询问确认
    if &ft == 'floaterm'
        let prog = trim(floaterm#config#get(floaterm#buflist#curr(), 'program', 'PROG'))
        if a:type == 'all' || index(['ai', 'repl'], tolower(prog)) < 0
            FloatermKill
        else
            let choice = utils#choose_one(['Kill Floaterm'], printf('Kill this floaterm %s process? Ctrl+C to cancel.', prog), 0, 'Cancel')
            call s:handle_choice(choice, a:type)
        endif
        return
    " 空文件或被忽略的文件直接退出
    elseif (&ft == '' || utils#expand('%') == '' || utils#is_ignored()) && a:type == 0
        q!
        return
    endif

    " 根据类型和修改状态确定选项和标题
    if a:type == 'all'
        let choices = ['Quit All']
        let title = "Do you want to quit all buffers? Ctrl+C to cancel."
    elseif a:type == 'direct'
        if &modified
            let choices = ['Save And Quit', 'Quit Only']
            let title = "Do you want to quit without save? Ctrl+C to cancel."
        else
            call s:do_quit(0)
            return
        endif
    else
        let title = "Do you want to quit? Ctrl+C to cancel"
        let choices = &modified ? ['Save And Quit', 'Quit Only'] : ['Quit']
    endif

    " 显示选择并处理
    let choice = utils#choose_one(choices, title, 0, 'Cancel')
    call s:handle_choice(choice, a:type)
endfun
command! ConfirmQuit call s:confirm_quit('check')
nnoremap <silent><M-q> :ConfirmQuit<Cr>
command! ConfirmQuitAll call s:confirm_quit('all')
nnoremap <silent><leader><BS> :ConfirmQuitAll<Cr>
command! Quit call s:confirm_quit('direct')
nnoremap <silent><leader>q :Quit<Cr>
