function! funky#qf#show(...) abort
    let buffers = funky#utils#buffers()
    if a:0 && a:1 > 0
        let funkies = funky#funky(1)
    else
        let funkies = funky#funky(0)
    endif
    let candicates = []
    for each in funkies
        let sp = split(each, "\t")
        let funky = sp[0]
        let sp1 = split(sp[1], ":")
        let bufnr = sp1[1]
        let lnum = sp1[2]
        if has_key(buffers, bufnr)
            let fname = buffers[bufnr]
            let candicates += [{'filename': fname, 'lnum': lnum, 'text': funky}]
        endif
    endfor
    call setqflist(candicates)
    copen
endfunction
