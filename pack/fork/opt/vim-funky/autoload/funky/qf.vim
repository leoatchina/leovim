function! s:find_col(lnum, func) abort
    let line = getline(a:lnum)
    if empty(line) || empty(a:func)
        return 1
    endif
    let col = match(line, '\V' . escape(a:func, '\')) + 1
    if col > 0
        return col
    endif
    let head = matchstr(a:func, '\k\+')
    if empty(head)
        return 1
    endif
    let col = match(line, '\V' . escape(head, '\')) + 1
    return col > 0 ? col : 1
endfunction

function! funky#qf#show(...) abort
    let funkies = funky#funky(0)
    let candicates = []
    let fname = bufname(bufnr(''))
    for each in funkies
        let lnum = str2nr(matchstr(each, '\d\+$'))
        let func = split(each, " \t#")[0]
        let col = s:find_col(lnum, func)
        let candicates += [{'filename': fname, 'lnum': lnum, 'col': col, 'text': func}]
    endfor
    call setqflist(candicates)
    copen
endfunction
