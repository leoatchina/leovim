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
    let bufnr = matchstr(item[1], ':\zs\d\+\ze#')
    if bufnr("") != bufnr
        call execute('buffer ' . bufnr)
        let s:winnr = bufwinnr("")
    endif
    call s:action_for(item[0])
    call cursor(lnum, 1)
    call funky#after_jump()
endfunction

function! funky#fzf#funky(funkies)
    let buffers = funky#utils#buffers()
    let candicates = []
    for each in a:funkies
        let bufnr = matchstr(each, ':\zs\d\+\ze:')
        if has_key(buffers, bufnr)
            let fname = buffers[bufnr]
            let lnum = matchstr(each, '\d\+$')
            let func = split(each, " \t#")[0]
            let funky = printf("%s:%d:%d#\t%s", fname, lnum, bufnr, func)
            call add(candicates, funky)
        endif
    endfor
    let longest = max(map(copy(candicates), 'len(split(v:val, "#\t")[0])'))
    let funkies = []
    for each in candicates
        let length = len(split(each, "#\t")[0])
        let funky = substitute(each, "#\t", "#" . repeat(" ", longest - length) . "\t", "")
        call add(funkies, funky)
    endfor
    return funkies
endfunction

" core function
function! funky#fzf#show(...)
    let options = ['--ansi', '--nth', "1,3..", '--delimiter', ':', '--prompt', 'Funky> ']
    let options += ['--expect', join(keys(get(g:, 'fzf_action', ['ctrl-x', 'ctrl-v', 'ctrl-t'])), ',')]
    let options += ['--preview-window', get(get(g:, 'fzf_vim'), 'preview_window', ['right,45%'])[0] . ',+{2}-/2']
    let options = fzf#vim#with_preview({'options': options, 'placeholder': ' {1}:{2}'}).options
    sleep 128m
    call fzf#run(fzf#wrap('funky', {
                \ 'source': funky#fzf#funky(a:0 && a:1 > 0 ? funky#funky(1) : funky#funky(0)),
                \ 'sink*': function('s:fzf_accept'),
                \ 'options' : options
                \ }))
endfunction
