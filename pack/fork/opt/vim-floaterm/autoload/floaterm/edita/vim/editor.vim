let s:quit_expr = "\<C-\>\<C-n>iEditaquit"

function! floaterm#edita#vim#editor#open(target, bufnr)
    call floaterm#window#hide(a:bufnr)
    let opener = floaterm#config#get(a:bufnr, 'opener', g:floaterm_opener)
    call floaterm#util#open([{'filename': fnameescape(a:target)}], opener)
    let b:edita = a:bufnr
    let filename = expand('%:t')
    if (index([
                \ 'COMMIT_EDITMSG',
                \ 'MERGE_MSG',
                \ 'git-rebase-todo',
                \ 'git-revise-todo',
                \ 'addp-hunk-edit.diff',
                \ ], filename) > -1) || (stridx(filename, 'commit.hg.txt') > -1)
        setlocal bufhidden=wipe
        augroup edita_buffer
            autocmd! * <buffer>
            autocmd BufDelete <buffer> call s:BufDelete()
            autocmd BufDelete <buffer> call timer_start(100, {->floaterm#curr()})
        augroup END
    else
        if !has('win32')
            call timer_start(100, {->s:BufDelete()})
            >>>>>>> 4e28c8dd0271e10a5f55142fb6fe9b1599ee6160
        endif
    endif
endfunction

function! s:BufDelete() abort
    let bufnr = getbufvar(expand('<afile>'), 'edita', v:null)
    if bufnr is# v:null
        return
    endif
    silent! call term_sendkeys(bufnr, s:quit_expr)
    call setbufvar(expand('<afile>'), 'edita', v:null)
endfunction

function! s:VimLeave() abort
    let expr = v:dying || v:exiting > 0 ? 'cquit' : 'qall'
    let editas = range(0, bufnr('$'))
    call map(editas, { -> getbufvar(v:val, 'edita', v:null) })
    call filter(editas, { -> !empty(v:val) })
    silent! call map(editas, { -> term_sendkeys(v:val, s:quit_expr) })
    " If COMMIT_EDITMSG buffer exists, suspend for the git commiting
    if len(editas) > 0
        sleep 10m
    endif
endfunction

augroup edita_internal
    autocmd! *
        autocmd VimLeave * call s:VimLeave()
augroup END
