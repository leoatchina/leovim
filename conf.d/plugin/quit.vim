let g:autoclose_ft_buf = [
            \ 'netrw', 'coc-explorer', 'neo-tree', 'fern',
            \ 'qf', 'preview', 'loclist',
            \ 'vista', 'tagbar', 'leaderf',
            \ 'help', 'gitcommit', 'man', 'fugitive', 'fugtiveblame', 'gitcommit',
            \ 'terminal', 'floaterm', 'popup'
            \ ]
function! s:autoclose(check_last) abort
    if winnr("$") <= 1 && a:check_last || !a:check_last
        return index(g:autoclose_ft_buf, getbufvar(winbufnr(winnr()), &ft)) >= 0 ||
                    \  index(g:autoclose_ft_buf, getbufvar(winbufnr(winnr()), &bt)) >= 0
    else
        return 0
    endif
endfunction
autocmd WinEnter * if s:autoclose(1) | q! | endif
" confirem quit
function! s:confirm_quit(all) abort
    let all = a:all
    if &ft == 'floaterm'
        FloatermKill
    elseif &ft == '' && all == 0
        q!
    elseif Expand('%') == '' && all == 0
        q!
    elseif s:autoclose(0) && all == 0
        q!
    else
        let title = 'Want to quit'
        if all
            let title .= " all?"
        else
            let title .= "?"
        endif
        if &modified && all == 0
            let choices = ['Save And Quit', 'Quit']
            let confirmed = ChooseOne(choices, title, 0, 'Cancel')
            if confirmed =~# '^Save'
                wq!
            elseif confirmed =~# '^Quit'
                q!
            endif
        else
            let choices = ['Quit']
            let confirmed = ChooseOne(choices, title, 0, 'Cancel')
            if confirmed ==# 'Quit'
                if all
                    qall!
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
