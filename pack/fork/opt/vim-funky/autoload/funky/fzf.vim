" -------------------------------
" NOTE: copied from fzf.vim
" -------------------------------
let s:default_action = {
            \ 'ctrl-t': 'tab split',
            \ 'ctrl-x': 'split',
            \ 'ctrl-v': 'vsplit',
            \ }
let s:TYPE = {'bool': type(0), 'dict': type({}), 'funcref': type(function('call')), 'string': type(''), 'list': type([])}
function! s:execute_silent(cmd)
    silent keepjumps keepalt execute a:cmd
endfunction
" [key, [filename, [stay_on_edit: 0]]]
function! s:action_for(key, ...)
    let Cmd = get(get(g:, 'fzf_action', s:default_action), a:key, '')
    let cmd = type(Cmd) == s:TYPE.string ? Cmd : ''
    let edit = stridx('edit', cmd) == 0 " empty, e, ed, ..
    " If no extra argument is given, we just execute the command and ignore
    " errors. e.g. E471: Argument required: tab drop
    if !a:0
        if !edit
            normal! m'
            silent! call s:execute_silent(cmd)
        endif
    else
        " For the default edit action, we don't execute the action if the
        " selected file is already opened in the current window, or we are
        " instructed to stay on the current buffer.
        let stay = edit && (a:0 > 1 && a:2 || fnamemodify(a:1, ':p') ==# expand('%:p'))
        if !stay
            normal! m'
            call s:execute_silent((len(cmd) ? cmd : 'edit').' '.s:escape(a:1))
        endif
    endif
endfunction

" -------------------------------
" core map
" -------------------------------
function! s:fzf_accept(item) abort
    let item = a:item
    if len(item) < 2 | return | endif
    let lnum = matchstr(item[1], ':\zs\d\+\ze:')
    let col = matchstr(item[1], ':\d\+:\zs\d\+\ze#')
    let lnum = empty(lnum) ? 1 : str2nr(lnum)
    let col = empty(col) ? 1 : str2nr(col)
    call s:action_for(item[0])
    call cursor(lnum, col)
    call funky#after_jump()
endfunction

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

function! s:pad_display_right(str, width) abort
    let pad = a:width - strdisplaywidth(a:str)
    return pad > 0 ? a:str . repeat(' ', pad) : a:str
endfunction

function! funky#fzf#funky(funkies)
    let candicates = []
    let fname = bufname(bufnr(''))
    let max_fname = 1
    let max_lnum = 1
    let max_col = 1
    for each in a:funkies
        let lnum = matchstr(each, '\d\+$')
        let func = split(each, " \t#")[0]
        let col = s:find_col(str2nr(lnum), func)
        let max_fname = max([max_fname, strdisplaywidth(fname)])
        let max_lnum = max([max_lnum, len(printf('%d', str2nr(lnum)))])
        let max_col = max([max_col, len(printf('%d', col))])
        call add(candicates, [fname, str2nr(lnum), col, func])
    endfor
    let funkies = []
    for each in candicates
        let fname_part = s:pad_display_right(each[0], max_fname)
        let lnum_part = printf('%' . max_lnum . 'd', each[1])
        let col_part = printf('%' . max_col . 'd', each[2])
        let funky = printf("%s:%s:%s#\t%s", fname_part, lnum_part, col_part, each[3])
        call add(funkies, funky)
    endfor
    return funkies
endfunction

" core function
function! funky#fzf#show(...)
    let options = ['--ansi', '--nth', "3..,1,2", '--delimiter', ':', '--prompt', 'Funky> ']
    let options += ['--expect', join(keys(get(g:, 'fzf_action', ['ctrl-x', 'ctrl-v', 'ctrl-t'])), ',')]
    let options += ['--preview-window', get(get(g:, 'fzf_vim'), 'preview_window', ['right,45%'])[0] . ',+{2}-/2']
    let options = fzf#vim#with_preview({'options': options, 'placeholder': ' {1}:{2}'}).options
    sleep 128m
    call fzf#run(fzf#wrap('funky', {
                \ 'source': funky#fzf#funky(funky#funky(0)),
                \ 'sink*': function('s:fzf_accept'),
                \ 'options' : options
                \ }))
endfunction
