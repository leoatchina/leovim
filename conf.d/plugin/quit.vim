" confirem quit
function! s:confirm_quit(all) abort
    let all = a:all
    if &ft == 'floaterm'
        FloatermKill
    elseif &ft == '' && all == 0
        q!
    elseif Expand('%') == '' && all == 0
        q!
    elseif CheckIgnoreFtBt() && all == 0
        q!
    else
        if all
            let title = "Do you want to quit all?"
        else
            let title = "Do you want to quit?"
        endif
        if &modified && all == 0
            let choices = ['Save And Quit', 'Quit Only']
            let confirmed = ChooseOne(choices, title, 0, 'Cancel')
            if confirmed =~# '^Save'
                wq!
            elseif confirmed =~# '^Quit'
                q!
            endif
        else
            if all
                let choices = ['Quit All']
            else
                let choices = ['Quit']
            endif
            let confirmed = ChooseOne(choices, title, 0, 'Cancel')
            if confirmed =~# '^Quit'
                if all
                    if exists(':cquit')
                        cquit
                    else
                        qall!
                    endif
                else
                    q!
                endif
            endif
        endif
    endif
endfun
command! ConfirmQuit call s:confirm_quit(0)
nnoremap <silent><M-q> :ConfirmQuit<Cr>
command! ConfirmQuitAll call s:confirm_quit(1)
nnoremap <silent><leader><BS> :ConfirmQuitAll<Cr>
" quit directly
function! s:quit() abort
    if &modified
        let choices = ['Save And Quit', 'Quit']
        let confirmed = ChooseOne(choices, 'Save && Quit || Quit only', 0, 'Cancel')
        if confirmed =~# '^Save'
            wq!
        elseif confirmed =~# '^Quit'
            q!
        endif
    else
        q!
    endif
endfunction
command! Quit call s:quit()
nnoremap <silent><leader>q :Quit<Cr>
