let g:autoclose_ft_buf = [
            \ 'netrw', 'tagbar', 'vista', 'vista_kind',
            \ 'qf', 'loclist', 'rg', 'outline',
            \ 'leaderf', 'fzf', 'help', 'man', 'startify',
            \ 'git', 'gitcommit', 'fugitive', 'fugtiveblame', 'diff',
            \ 'vimspector', 'vimspectorprompt',
            \ 'terminal', 'floaterm', 'popup', 'undotree',
            \ 'dropbar', 'dropbar_preview',
            \ ]
function! s:autoclose(check_last_win) abort
    let ft = tolower(getbufvar(winbufnr(winnr()), '&ft'))
    let bt = tolower(getbufvar(winbufnr(winnr()), '&bt'))
    if a:check_last_win == 0
        return ft == '' || index(g:autoclose_ft_buf, ft) >= 0 || index(g:autoclose_ft_buf, bt) >= 0
    elseif winnr("$") <= 1 && a:check_last_win > 0
        return index(g:autoclose_ft_buf, ft) >= 0 || index(g:autoclose_ft_buf, bt) >= 0
    else
        return 0
    endif
endfunction
function! FtBtIgnored() abort
    return s:autoclose(0)
endfunction
function! FtBtAutoClose() abort
    return s:autoclose(1)
endfunction
augroup AutoClose
    autocmd!
    autocmd BufWinEnter * if FtBtAutoClose() | q! | endif
augroup END
" -------------------------
" confirem quit
" -------------------------
function! s:confirm_quit(type) abort
    let type = a:type
    if &ft == 'floaterm'
        FloatermKill
    elseif (&ft == '' || Expand('%') == '' || FtBtIgnored()) && type == 0
        q!
    else
        if type == 'all'
            let choices = ['Quit All']
            let title = "Do you want to quit all buffers? Ctrl+C to cancel"
        elseif type == 'direct'
            if &modified
                let choices = ['Save And Quit', 'Quit Only']
                let title = "Do you want to quit without save? Ctrl+C to cancel""
            else
                UndotreeHide
                q!
                return
            endif
        else
            let title = "Do you want to quit? Ctrl+C to cancel""
            if &modified
                let choices = ['Save And Quit', 'Quit Only']
            else
                let choices = ['Quit']
            endif
        endif
        if &modified && type == 'check'
            let choice = ChooseOne(choices, title, 0, 'Cancel')
            if choice =~# '^Save'
                UndotreeHide
                wq!
            elseif choice =~# '^Quit'
                UndotreeHide
                q!
            endif
        else
            let choice = ChooseOne(choices, title, 0, 'Cancel')
            if choice =~# '^Quit'
                if type == 'all'
                    UndotreeHide
                    if exists(':cquit')
                        cquit
                    else
                        qall!
                    endif
                else
                    UndotreeHide
                    q!
                endif
            elseif choice =~# '^Save'
                UndotreeHide
                wq!
            endif
        endif
    endif
endfun
command! ConfirmQuit call s:confirm_quit('check')
nnoremap <silent><M-q> :ConfirmQuit<Cr>
command! ConfirmQuitAll call s:confirm_quit('all')
nnoremap <silent><leader><BS> :ConfirmQuitAll<Cr>
command! Quit call s:confirm_quit('direct')
nnoremap <silent><leader>q :Quit<Cr>
