function! fzf#tabs#source(...)
    if exists('*execute')
        let tab_lst = split(execute('tabs'), '\n')
    else
        redir => reg
        silent tabs
        redir END
        let tab_lst = split(reg, '\n')
    endif
    let line = ''
    let lines = []
    let index = 0
    let index_added = 0
    for tab in tab_lst
        " find a new tab
        if tab =~# '^Tab'
            let index += 1
            if line != ''
                call add(lines, line)
            endif
            let line = index . "\t"
        " check newtab added
        elseif index_added < index
            let index_added = index
            let line .= tab[4:]
        endif
    endfor
    call add(lines, line)
    return lines
endfunction

function! fzf#tabs#select(item, ...) abort
    let num = split(a:item, "\t")[0]
    execute 'tabn' . num
endfunction

function! fzf#tabs#show() abort
    let options = ['--ansi', '--nth', '..', '--delimiter', '\t', '--prompt', 'Tabs> ']
    let options += ['--preview-window', get(get(g:, 'fzf_vim'), 'preview_window', ['right,45%'])[0]]
    let options = fzf#vim#with_preview({'options': options, 'placeholder': '{2}'}).options
    call fzf#run(fzf#wrap('tabs', {
                \ 'source': fzf#tabs#source(),
                \ 'sink': function('fzf#tabs#select'),
                \ 'options': options
                \ }))
endfunction
