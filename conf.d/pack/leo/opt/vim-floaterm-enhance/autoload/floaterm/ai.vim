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
" AI helpers for vim-floaterm-enhance
" --------------------------------------------------------------
function! floaterm#ai#get_parsed_programs() abort
    return floaterm#enhance#parse_programs(get(g:, 'floaterm_ai_programs', []), 'AI')
endfunction

function! floaterm#ai#_active_or_run(now) abort
    let ai_bufnr = floaterm#ai#get_ai_bufnr()
    if ai_bufnr
        call floaterm#enhance#showmsg(printf("REPL for %s already started", winbufnr(winnr())))
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
            call timer_start(0, {-> floaterm#repl#update_ai_bufnr(t:floaterm_program_bufnr)})
        endif
    endif
endfunction

" --------------------------------------------------------------
" send file path with line range to latest AI terminal
" --------------------------------------------------------------
function! floaterm#ai#send_file_line_range() abort
    let curr_bufnr = floaterm#ai#get_ai_bufnr()
    if !curr_bufnr
        call floaterm#enhance#showmsg('No AI floaterm window found', 1)
        return
    endif
    let range_str = '@'.floaterm#enhance#get_file_line_range() . ' '
    call floaterm#terminal#send(curr_bufnr, [range_str], 0)
endfunction
