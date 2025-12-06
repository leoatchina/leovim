if utils#pref_fzf()
    nnoremap <silent><leader>b :FzfBuffers<Cr>
elseif utils#is_planned_leaderf()
    nnoremap <silent><leader>b :LeaderfBuffer<Cr>
elseif utils#is_planned('vim-quickui')
    nnoremap <silent><leader>b :call quickui#tools#list_buffer('e')<Cr>
else
    nnoremap <silent><leader>b :CtrlPBuffer<Cr>
endif
" kill other buffers
command! BdOther silent! execute "%bd|e#|bd#"
nnoremap <silent><Leader>Q :BdOther<Cr>
" Command ':Bclose' executes ':bd' to delete buffer in current window.
if !exists('g:bclose_multiple')
    let g:bclose_multiple = 1
endif
function! s:buffer_close(bang, buffer)
    if empty(a:buffer)
        let btarget = bufnr('%')
    elseif a:buffer =~ '^\d\+$'
        let btarget = bufnr(str2nr(a:buffer))
    else
        let btarget = bufnr(a:buffer)
    endif
    if btarget < 0
        call preview#errmsg('No matching buffer for '.a:buffer)
        return
    endif
    if empty(a:bang) && getbufvar(btarget, '&modified')
        call preview#errmsg('No write since last change for buffer '.btarget.' (use :Bclose!)')
        return
    endif
    " Numbers of windows that view target buffer which we will delete.
    let wnums = filter(range(1, winnr('$')), 'winbufnr(v:val) == btarget')
    if !g:bclose_multiple && len(wnums) > 1
        call preview#errmsg('Buffer is in multiple windows (use ":let bclose_multiple=1")')
        return
    endif
    let wcurrent = winnr()
    for w in wnums
        execute w.'wincmd w'
        let prevbuf = bufnr('#')
        if prevbuf > 0 && buflisted(prevbuf) && prevbuf != btarget
            buffer #
        else
            bprevious
        endif
        if btarget == bufnr('%')
            " Numbers of listed buffers which are not the target to be deleted.
            let blisted = filter(range(1, bufnr('$')), 'buflisted(v:val) && v:val != btarget')
            " Listed, not target, and not displayed.
            let bhidden = filter(copy(blisted), 'bufwinnr(v:val) < 0')
            " Take the first buffer, if any (could be more intelligent).
            let bjump = (bhidden + blisted + [-1])[0]
            if bjump > 0
                execute 'buffer '.bjump
            else
                execute 'enew'.a:bang
            endif
        endif
    endfor
    execute 'bdelete'.a:bang.' '.btarget
    execute wcurrent.'wincmd w'
endfunction
command! -bang -complete=buffer -nargs=? Bclose call s:buffer_close(<q-bang>, <q-args>)
nnoremap <silent><leader>B :Bclose!<Cr>
