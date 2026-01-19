" --------------------------------------------------------------
" AI buf control
" --------------------------------------------------------------
function! floaterm#ai#get_ai_bufnr(...) abort
    let t:floaterm_ai_bufnrs = get(t:, 'floaterm_ai_bufnrs', [])
    let all_bufnrs = floaterm#buflist#gather()
    if empty(all_bufnrs) || empty(t:floaterm_ai_bufnrs)
        let t:floaterm_ai_bufnrs = []
        return 0
    endif
    let ai_bufnr = (a:0 && a:1) ? a:1 : 0
    if ai_bufnr && index(t:floaterm_ai_bufnrs, ai_bufnr) >= 0 && index(all_bufnrs, ai_bufnr) >= 0
        return ai_bufnr
    endif
    call filter(t:floaterm_ai_bufnrs, {_, v -> index(all_bufnrs, v) > 0})
    if empty(t:floaterm_ai_bufnrs)
        return 0
    endif
    return t:floaterm_ai_bufnrs[0]
endfunction
function! floaterm#ai#update_ai_bufnr(bufnr)
    " 把 bufnr 放到  floaterm_ai_bufnr的第一个
    let t:floaterm_ai_bufnrs = get(t:, 'floaterm_ai_bufnrs', [])
    let all_bufnrs = floaterm#buflist#gather()
    call filter(t:floaterm_ai_bufnrs, {_, v -> v != a:bufnr && index(all_bufnrs, v) > 0})
    call insert(t:floaterm_ai_bufnrs, a:bufnr, 0)
endfunction
" --------------------------------------------------------------
" get programs
" --------------------------------------------------------------
function! floaterm#ai#get_parsed_programs() abort
    return floaterm#enhance#parse_programs(get(g:, 'floaterm_ai_programs', []), 'AI')
endfunction
" --------------------------------------------------------------
" AI helpers for vim-floaterm-enhance
" --------------------------------------------------------------
function! floaterm#ai#start(now) abort
    let ai_bufnr = floaterm#ai#get_ai_bufnr()
    if ai_bufnr
        call floaterm#enhance#showmsg(printf("AI for %s already started", ai_bufnr))
    else
        let programs = floaterm#ai#get_parsed_programs()
        if empty(programs)
            call floaterm#enhance#showmsg("No AI programs available ", 1)
            return
        endif
        " XXX: -1:没有run 过， 0 :run cmd but fail,  > 0 -> floaterm_bufnr
        let t:floaterm_program_bufnr = -1
        if a:now
            let [cmd, opts, type] = programs[0]
            call floaterm#enhance#cmd_run(cmd, opts, type)
            call floaterm#ai#update_ai_bufnr(t:floaterm_program_bufnr)
        else
            call floaterm#enhance#fzf_run(programs, 'FloatermAI')
            call timer_start(0, {-> floaterm#ai#update_ai_bufnr(t:floaterm_program_bufnr)})
        endif
    endif
endfunction
" ------------------------------------------------------
" Send a newline to AI or start AI if not running
" ------------------------------------------------------
function! floaterm#ai#send_cr_or_start(start, stay_curr, ...) abort
    let ai_bufnr = floaterm#ai#get_ai_bufnr()
    if ai_bufnr
        call floaterm#terminal#send(ai_bufnr, [""], a:stay_curr)
    elseif a:start
        call floaterm#ai#start(a:0 && a:1 ? 1:0)
    endif
endfunction
" --------------------------------------------------------------
" format string/list with '@' string
" --------------------------------------------------------------
function! floaterm#ai#at(...) abort
    if !a:0
        return ''
    endif
    let result = []
    for each in a:000
        if type(each) == type('')
            call add(result, each)
        elseif type(each) == type([])
            call extend(result, each)
        endif
    endfor
    if empty(result)
        return ""
    else
        return '@' . join(result, ' @') . ' '
    endif
endfunction
" --------------------------------------------------------------
" send file path with line range to latest AI terminal
" --------------------------------------------------------------
function! floaterm#ai#_send(type, keep_curr, ...) abort
    let ai_bufnr = floaterm#ai#get_ai_bufnr()
    if !ai_bufnr
        call floaterm#enhance#showmsg('No AI floaterm window found', 1)
        return
    endif
    if a:type == 'range'
        if a:0
            if a:0 == 1 && a:1
                let content = floaterm#ai#at(floaterm#enhance#get_file_line_range(a:1, a:1))
            elseif a:1 && a:2 && a:1 <= a:2
                let content = floaterm#ai#at(floaterm#enhance#get_file_line_range(a:1, a:2))
            else
                let content = floaterm#ai#at(floaterm#enhance#get_file_abspath())
            endif
        else
            let content = floaterm#ai#at(floaterm#enhance#get_file_abspath())
        endif
    elseif a:type == 'file'
        let content = floaterm#ai#at(floaterm#enhance#get_file_abspath())
    elseif a:type == 'dir'
        let content = floaterm#ai#at(floaterm#enhance#get_file_absdir())
    else
        return
    endif
    if empty(content)
        return
    endif
    call floaterm#terminal#send(ai_bufnr, [content], 0)
    if a:keep_curr
        wincmd p
        if has('nvim')
            stopinsert
        endif
    endif
endfunction
" send range
function! floaterm#ai#send_line_range(keep_curr) range abort
    call floaterm#ai#_send('range', a:keep_curr, a:firstline, a:lastline)
endfunction
" send file
function! floaterm#ai#send_file(keep_curr) abort
    call floaterm#ai#_send('file', a:keep_curr)
endfunction
" send dir
function! floaterm#ai#send_dir(keep_curr) abort
    call floaterm#ai#_send('dir', a:keep_curr)
endfunction
" --------------------------------------------------------------
" fzf file picker with root dir files -> send paths to latest AI terminal
" --------------------------------------------------------------
function! floaterm#ai#fzf_file_sink(ai_bufnr, keep_curr, lines) abort
    if empty(a:lines)
        call floaterm#enhance#showmsg('No file selected', 1)
    else
        call floaterm#terminal#send(a:ai_bufnr, [floaterm#ai#at(a:lines)], 0)
        if a:keep_curr
            wincmd p
            if has('nvim')
                stopinsert
            endif
        endif
    endif
endfunction
function! floaterm#ai#fzf_file(keep_curr) abort
    let ai_bufnr = floaterm#ai#get_ai_bufnr()
    if ai_bufnr
        let root_dir = floaterm#path#get_root()
        let relative_dir = substitute(floaterm#enhance#get_file_absdir(), '^' . root_dir . '/', '', '')
        call fzf#vim#files(root_dir, fzf#vim#with_preview({
                    \ 'sink*': function('floaterm#ai#fzf_file_sink', [ai_bufnr, a:keep_curr]),
                    \ 'options': ['--multi', '--prompt', 'FloatermFzfFile> ', '--query', relative_dir]
                    \ }), 0)
    else
        call floaterm#enhance#showmsg('No AI floaterm window found', 1)
    endif
endfunction
