let g:autoclose_ft_buf = [
            \ 'netrw', 'tagbar', 'vista', 'vista_kind',
            \ 'qf', 'loclist', 'rg', 'outline',
            \ 'leaderf', 'fzf', 'help', 'man', 'startify',
            \ 'git', 'gitcommit', 'fugitive', 'fugtiveblame', 'diff',
            \ 'vimspector', 'vimspectorprompt',
            \ 'terminal', 'floaterm', 'popup', 'undotree',
            \ 'dropbar', 'dropbar_preview',
            \ ]
function! s:autoclose(...) abort
    let ft = tolower(getbufvar(winbufnr(winnr()), '&ft'))
    let bt = tolower(getbufvar(winbufnr(winnr()), '&bt'))
    if winnr("$") <= 1 && a:0 && a:1
        return index(g:autoclose_ft_buf, ft) >= 0 || index(g:autoclose_ft_buf, bt) >= 0
    elseif !a:0 || a:1 == 0
        return ft == '' || index(g:autoclose_ft_buf, ft) >= 0 || index(g:autoclose_ft_buf, bt) >= 0
    else
        return 0
    endif
endfunction
function! FtBtIgnored() abort
    return s:autoclose(0)
endfunction
function! AutoClose() abort
    return s:autoclose(1)
endfunction
augroup AutoClose
    autocmd!
    autocmd BufWinEnter * if AutoClose() | q! | endif
augroup END
