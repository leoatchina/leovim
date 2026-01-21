" --------------------------------------------------------------
" AI buf control
" --------------------------------------------------------------
function! floaterm#ai#get_ai_bufnr(...) abort
    let t:floaterm_ai_lst = get(t:, 'floaterm_ai_lst', [])
    let all_bufnrs = floaterm#buflist#gather()
    if empty(all_bufnrs) || empty(t:floaterm_ai_lst)
        let t:floaterm_ai_lst = []
        return 0
    endif
    let ai_bufnr = (a:0 && a:1) ? a:1 : 0
    if ai_bufnr
        call floaterm#ai#set_ai_bufnr(ai_bufnr)
    else
        call filter(t:floaterm_ai_lst, {_, v -> index(all_bufnrs, v) >= 0})
    endif
    if empty(t:floaterm_ai_lst)
        return 0
    else
        return t:floaterm_ai_lst[0]
    endif
endfunction
function! floaterm#ai#set_ai_bufnr(...) abort
    " 把 bufnr 放到  floaterm_ai_bufnr的第一个
    let t:floaterm_ai_lst = get(t:, 'floaterm_ai_lst', [])
    let all_bufnrs = floaterm#buflist#gather()
    if a:0 && type(a:1) == type(0)
        let bufnr = a:1
    elseif exists('t:floaterm_program_bufnr')
        let bufnr = t:floaterm_program_bufnr
    else
        let bufnr = 0
    endif
    if bufnr <= 0
        return
    endif
    call filter(t:floaterm_ai_lst, {_, v -> v != bufnr && index(all_bufnrs, v) >= 0})
    " call floaterm#config#set(bufnr, 'program', 'AI')
    call insert(t:floaterm_ai_lst, bufnr, 0)
endfunction
function! floaterm#ai#async_set_ai_bufnr(...) abort
    while exists('t:floaterm_program_bufnr') && t:floaterm_program_bufnr < 0
        sleep 50m
    endwhile
    call floaterm#ai#set_ai_bufnr()
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
        call floaterm#ai#set_ai_bufnr()
    else
        call floaterm#enhance#fzf_run(programs, 'FloatermAI', function('floaterm#ai#set_ai_bufnr'))
    endif
endfunction
" ------------------------------------------------------
" Send a newline to AI or start AI if not running
" ------------------------------------------------------
function! floaterm#ai#send_cr(stay_curr, ...) abort
    let ai_bufnr = floaterm#ai#get_ai_bufnr()
    if ai_bufnr
        call floaterm#terminal#send(ai_bufnr, ["\r"])
        if a:stay_curr
            wincmd p
            if has('nvim')
                stopinsert
            endif
        endif
    else
        call floaterm#enhance#showmsg('No AI floaterm window found', 1)
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
function! floaterm#ai#_send(type, stary_curr, ...) abort
    let ai_bufnr = floaterm#ai#get_ai_bufnr()
    if !ai_bufnr
        call floaterm#enhance#showmsg('No AI floaterm window found', 1)
        return
    endif
    if a:type == 'range'
        if a:0 == 2 && a:1 && a:2 && a:1 <= a:2
            let content = floaterm#ai#at(floaterm#enhance#get_file_line_range(a:1, a:2))
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
    if a:stary_curr
        wincmd p
        if has('nvim')
            stopinsert
        endif
    endif
endfunction
" send range
function! floaterm#ai#send_line_range(stay_curr, ...) abort
    if a:0 >= 2
        let firstline = a:1
        let lastline = a:2
    else
        let firstline = line('.')
        let lastline = firstline
    endif
    call floaterm#ai#_send('range', a:stay_curr, firstline, lastline)
endfunction
" send file
function! floaterm#ai#send_file(stay_curr) abort
    call floaterm#ai#_send('file', a:stay_curr)
endfunction
" send dir
function! floaterm#ai#send_dir(stay_curr) abort
    call floaterm#ai#_send('dir', a:stay_curr)
endfunction
" --------------------------------------------------------------
" fzf file picker with root dir files -> send paths to latest AI terminal
" --------------------------------------------------------------
function! floaterm#ai#fzf_file_sink(ai_bufnr, stay_curr, lines) abort
    if empty(a:lines)
        call floaterm#enhance#showmsg('No file selected', 1)
    else
        call floaterm#terminal#send(a:ai_bufnr, [floaterm#ai#at(a:lines)], 0)
        if a:stay_curr
            wincmd p
            if has('nvim')
                stopinsert
            endif
        endif
    endif
endfunction
function! floaterm#ai#fzf_file(stay_curr) abort
    let ai_bufnr = floaterm#ai#get_ai_bufnr()
    if ai_bufnr
        let root_dir = floaterm#path#get_root()
        let relative_dir = substitute(floaterm#enhance#get_file_absdir(), '^' . root_dir . '/', '', '')
        call fzf#vim#files(root_dir, fzf#vim#with_preview({
                    \ 'sink*': function('floaterm#ai#fzf_file_sink', [ai_bufnr, a:stay_curr]),
                    \ 'options': ['--multi', '--prompt', 'FloatermFzfFile> ', '--query', relative_dir]
                    \ }), 0)
    else
        call floaterm#enhance#showmsg('No AI floaterm window found', 1)
    endif
endfunction
