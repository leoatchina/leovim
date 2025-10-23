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
