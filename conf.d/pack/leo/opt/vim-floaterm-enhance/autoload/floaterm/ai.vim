" --------------------------------------------------------------
" AI buf control
" --------------------------------------------------------------
function! floaterm#ai#get_ai_bufnr(...) abort
    let g:floaterm_ai_lst = get(g:, 'floaterm_ai_lst', [])
    let all_bufnrs = floaterm#buflist#gather()
    if empty(all_bufnrs) || empty(g:floaterm_ai_lst)
        let g:floaterm_ai_lst = []
        return 0
    endif
    let ai_bufnr = (a:0 && a:1) ? a:1 : 0
    if ai_bufnr
        call floaterm#ai#set_ai_bufnr(ai_bufnr)
    else
        call filter(g:floaterm_ai_lst, {_, v -> index(all_bufnrs, v) >= 0})
    endif
    if empty(g:floaterm_ai_lst)
        return 0
    else
        let ai_bufnr = g:floaterm_ai_lst[0]
        return ai_bufnr
    endif
endfunction
function! floaterm#ai#set_ai_bufnr(...) abort
    " 把 bufnr 放到  floaterm_ai_bufnr的第一个
    let g:floaterm_ai_lst = get(g:, 'floaterm_ai_lst', [])
    let all_bufnrs = floaterm#buflist#gather()
    if a:0 && type(a:1) == type(0)
        let bufnr = a:1
    else
        let bufnr = 0
    endif
    if bufnr <= 0
        return
    endif
    call filter(g:floaterm_ai_lst, {_, v -> v != bufnr && index(all_bufnrs, v) >= 0})
    " call floaterm#config#set(bufnr, 'program', 'AI')
    call insert(g:floaterm_ai_lst, bufnr, 0)
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
    if a:now
        let [cmd, opts, type] = programs[0]
        call floaterm#enhance#cmd_run(cmd, opts, type)
    else
        call floaterm#enhance#fzf_run(programs, 'FloatermAI')
    endif
endfunction
" --------------------------------------------------------------
" format string/list with '@' string
" --------------------------------------------------------------
function! s:at_prompt(...) abort
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
" XXX: send prompt
" --------------------------------------------------------------
function! s:send_prompt(type, stary_curr, ...) abort
    let ai_bufnr = floaterm#ai#get_ai_bufnr()
    if !ai_bufnr
        call floaterm#enhance#showmsg('No AI floaterm window found', 1)
        return
    endif
    if a:type == 'range'
        if a:0 == 2 && a:1 && a:2 && a:1 <= a:2
            let content = s:at_prompt(floaterm#enhance#get_file_line_range(a:1, a:2))
        else
            let content = s:at_prompt(floaterm#enhance#get_file_abspath())
        endif
    elseif a:type == 'file'
        let content = s:at_prompt(floaterm#enhance#get_file_abspath())
    elseif a:type == 'dir'
        let content = s:at_prompt(floaterm#enhance#get_file_absdir())
    elseif a:type == 'cr'
        let content = "\r"
    else
        return
    endif
    if empty(content)
        return
    endif
    call floaterm#terminal#open_existing(ai_bufnr)
    call floaterm#terminal#send(ai_bufnr, [content], 0)
    if a:stary_curr
        call floaterm#enhance#wincmdp()
    endif
endfunction
" --------------------------------------------------------------
" send file path with line range to latest AI terminal
" --------------------------------------------------------------
function! floaterm#ai#send_line_range(stay_curr, ...) abort
    if a:0 >= 2
        let firstline = a:1
        let lastline = a:2
    else
        let firstline = line('.')
        let lastline = firstline
    endif
    call s:send_prompt('range', a:stay_curr, firstline, lastline)
endfunction
" send file
function! floaterm#ai#send_file(stay_curr) abort
    call s:send_prompt('file', a:stay_curr)
endfunction
" send dir
function! floaterm#ai#send_dir(stay_curr) abort
    call s:send_prompt('dir', a:stay_curr)
endfunction
" send a newline
function! floaterm#ai#send_cr(stay_curr) abort
    call s:send_prompt('cr', a:stay_curr)
endfunction
" --------------------------------------------------------------
" fzf file picker with root dir files -> send paths to latest AI terminal
" --------------------------------------------------------------
function! floaterm#ai#fzf_file_sink(ai_bufnr, stay_curr, lines) abort
    let ai_bufnr = a:ai_bufnr
    if empty(a:lines)
        call floaterm#enhance#showmsg('No file selected', 1)
    else
        call floaterm#terminal#open_existing(ai_bufnr)
        call floaterm#terminal#send(ai_bufnr, [s:at_prompt(a:lines)], 0)
        if a:stay_curr
            call floaterm#enhance#wincmdp()
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
