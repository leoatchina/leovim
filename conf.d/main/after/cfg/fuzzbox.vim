" Configure before Fuzzbox's plugin script registers its mappings.
let g:fuzzbox_mappings = 0
let g:fuzzbox_root_patterns = copy(g:root_patterns)
let g:fuzzbox_include_hidden = 0
let g:fuzzbox_exclude_dir = ['.git', '.hg', '.svn', '.vscode', '.idea', '.root', '.ccls']
let g:fuzzbox_exclude_file = ['*.swp', 'tags', '*.exe', '*.so', '*.dll', '*.pyd', '*.msi']

" CtrlPBufTag generated symbols for a standalone file, without project tags.
function! s:buffer_tags() abort
    let path = expand('%:p')
    if empty(path) || !filereadable(path)
        echo 'Save the file before listing its tags.'
        return
    endif
    let ctags = utils#is_win() ? utils#expand('~/.leovim.windows/tools/ctags.exe') : 'ctags'
    let output = systemlist(shellescape(ctags) . ' -f - --sort=no --fields=+n ' . shellescape(path))
    if v:shell_error
        echoerr 'ctags failed: ' . join(output, "\n")
        return
    endif
    let items = []
    for entry in output
        let fields = split(entry, "\t")
        let lnum = str2nr(matchstr(entry, '\tline:\zs\d\+'))
        if len(fields) >= 3 && lnum > 0 && entry !~# '^!'
            call add(items, printf("%d\t%s", lnum, fields[0]))
        endif
    endfor
    if empty(items)
        echo 'No tags found in the current file.'
        return
    endif
    let target = bufnr('%')
    call fuzzbox#Select(items, {
                \ 'title': 'Current File Tags',
                \ 'select_cb': function('s:jump', ['buffer', target]),
                \ 'default_actions': 0,
                \ 'actions': {
                \ "\<C-x>": function('s:jump', ['sbuffer', target]),
                \ "\<C-s>": function('s:jump', ['sbuffer', target]),
                \ "\<C-]>": function('s:jump', ['vertical sbuffer', target]),
                \ "\<C-t>": function('s:jump', ['tab sbuffer', target]),
                \ }})
endfunction

function! s:jump(command, target, winid, result, ...) abort
    if empty(a:result) || !bufexists(a:target)
        return
    endif
    call popup_close(a:winid)
    execute a:command . ' ' . a:target
    normal! m'
    call cursor(str2nr(a:result), 1)
    normal! zvzz
endfunction
command! FuzzboxBufferTags call <SID>buffer_tags()
