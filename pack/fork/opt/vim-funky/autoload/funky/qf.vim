function! funky#qf#show(type) abort
    let buffers = funky#utils#buffers()
    let funkies = funky#funky(a:type)
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
