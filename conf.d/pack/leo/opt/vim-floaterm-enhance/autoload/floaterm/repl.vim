" -------------------------------------
" XXX: idx/get/set
" -------------------------------------
function! floaterm#repl#create_idx(...) abort
    if a:0 && type(a:1) == type('') && a:1
        let ft = a:1
    else
        let ft = &ft
    endif
    if a:0 && type(a:2) == type(0) && a:2
        let bufnr = a:2
    else
        let bufnr = winbufnr(winnr())
    endif
    return ft . '-' . bufnr
endfunction
function! floaterm#repl#get_repl_bufnr(...) abort
    if !exists('t:floaterm_repl_dict')
        return 0
    endif
    if a:0 && type(a:1) == type('') && a:1
        let idx = a:1
    else
        let idx = floaterm#repl#create_idx()
    endif
    if !has_key(t:floaterm_repl_dict, idx)
        return 0
    endif
    let bufnr = t:floaterm_repl_dict[idx]
    if index(floaterm#buflist#gather(), bufnr) < 0
        call remove(t:floaterm_repl_dict, idx)
        return 0
    else
        return bufnr
    endif
endfunction
function! floaterm#repl#set_repl_bufnr(...) abort
    if !exists('t:floaterm_repl_dict')
        let t:floaterm_repl_dict = {}
    endif
    if a:0 && type(a:1) == type('')
        let idx = a:1
    else
        let idx = floaterm#repl#create_idx()
    endif
    if a:0 > 1 && type(a:2) == type(0)
        let prog_bufnr = a:2
    elseif exists('t:floaterm_program_bufnr')
        let prog_bufnr = t:floaterm_program_bufnr
    else
        let prog_bufnr = 0
    endif
    if prog_bufnr
        let t:floaterm_repl_dict[idx] = prog_bufnr
    endif
endfunction
" -------------------------------------
" get repl programs for filetype
" -------------------------------------
function! floaterm#repl#get_ft_parsed_programs(...) abort
    if a:0 && type(a:1) == type('')
        let ft = trim(a:1)
    else
        let ft = &ft
    endif
    if !exists('g:floaterm_repl_programs') || !has_key(g:floaterm_repl_programs, ft)
        return []
    else
        return floaterm#enhance#parse_programs(get(g:floaterm_repl_programs, ft, []), 'REPL')
    endif
endfunction
" -------------------------------------
" start repl (internal function)
" -------------------------------------
function! floaterm#repl#_active_or_run(now) abort
    let ft = &ft
    let repl_bufnr = floaterm#repl#get_repl_bufnr()
    if repl_bufnr
        call floaterm#enhance#showmsg(printf("REPL for %s already started", winbufnr(winnr())))
    else
        let programs = floaterm#repl#get_ft_parsed_programs(ft)
        if empty(programs)
            call floaterm#enhance#showmsg("No REPL program available for " . ft, 1)
            return
        endif
        " XXX: -1:没有run 过， 0 :run cmd but fail,  > 0 -> floaterm_bufnr
        let t:floaterm_program_bufnr = -1
        if a:now
            let [cmd, opts, type] = programs[0]
            call floaterm#enhance#cmd_run(cmd, opts, type)
            call floaterm#repl#set_repl_bufnr()
        else
            call floaterm#enhance#fzf_run(programs, 'FloatermREPL')
            call timer_start(0, {-> floaterm#repl#set_repl_bufnr()})
        endif
    endif
endfunction
" -------------------------------------
" start repl (auto select program)
" -------------------------------------
function! floaterm#repl#start_now() abort
    call floaterm#repl#_active_or_run(v:true)
endfunction
" -------------------------------------
" start repl (choose program interactively)
" -------------------------------------
function! floaterm#repl#start_choose() abort
    call floaterm#repl#_active_or_run(v:false)
endfunction
" -------------------------------------
" set repl program for each filetype
" -------------------------------------
function! floaterm#repl#update_program(ft, programs, ...) abort
    let ft = a:ft
    if !exists('g:floaterm_repl_programs')
        let g:floaterm_repl_programs = {}
    endif
    let opts = a:0 && type(a:1) == type('') ? a:1 : ''
    if type(a:programs) == type('')
        let programs = [a:programs]
    elseif type(a:programs) == type([])
        let programs = a:programs
    else
        return
    endif
    if !has_key(g:floaterm_repl_programs, ft)
        let g:floaterm_repl_programs[ft] = []
    endif
    for cmd in programs
        if type(cmd) != type('')
            continue
        endif
        let cmd = trim(cmd)
        if empty(cmd)
            continue
        endif
        let lst = split(cmd, ' ')
        if !executable(lst[0])
            continue
        endif
        let entry = [cmd, opts, 'REPL']
        let replaced = v:false
        let i = 0
        while i < len(g:floaterm_repl_programs[ft])
            if g:floaterm_repl_programs[ft][i][0] ==# cmd
                let g:floaterm_repl_programs[ft][i] = entry
                let replaced = v:true
                break
            endif
            let i += 1
        endwhile
        if !replaced
            call add(g:floaterm_repl_programs[ft], entry)
        endif
    endfor
endfunction
" -------------------------------------
" mark
" -------------------------------------
function! floaterm#repl#mark() range abort
    try
        if mode() =~# '^[vV]' || mode() ==# "\<C-v>"
            let t:floaterm_repl_marked_lines = getline(a:firstline, a:lastline)
            echom "Visual selection marked."
        else
            let [start, end] = floaterm#enhance#get_block()
            let t:floaterm_repl_marked_lines = getline(start, end)
            echom "Block code marked."
        endif
    catch /.*/
        echom "Error mark lines."
    endtry
endfunction
" Using quickfix to show marked contents
function! floaterm#repl#show_mark() abort
    if empty(get(t:, 'floaterm_repl_marked_lines', []))
        echo "t:floaterm_repl_marked_lines is None"
        return
    endif
    " Clear quickfix list
    call setqflist([])
    " Get current buffer number for location reference
    let bufnr = bufnr('%')
    " Prepare quickfix entries
    let qf_entries = []
    let line_nr = 1
    for line in t:floaterm_repl_marked_lines
        call add(qf_entries, {
            \ 'bufnr': bufnr,
            \ 'lnum': line_nr,
            \ 'text': line,
            \ 'type': 'I'
            \ })
        let line_nr += 1
    endfor
    " Set quickfix list with entries
    call setqflist(qf_entries)
    " Open quickfix window
    copen
    " Set title for quickfix window
    let w:quickfix_title = 'REPL Marked contents'
endfunction
" sent marked contents
function! floaterm#repl#send_mark() abort
    if get(t:, 'floaterm_repl_marked_lines', []) == []
        echom "t:floaterm_repl_marked_lines is empty"
    else
        let repl_bufnr = floaterm#repl#get_repl_bufnr()
        if repl_bufnr
            call floaterm#repl#send_contents(t:floaterm_repl_marked_lines, &ft, repl_bufnr, 1, line('.') , 0)
        endif
    endif
endfunction
" -------------------------------------
" send only one word
" -------------------------------------
function! floaterm#repl#send_word() range abort
    if mode() =~# '^[vV]' || mode() ==# "\<C-v>"
        let word = trim(floaterm#enhance#get_visual_select())
    else
        let word = expand('<cword>')
    endif
    if empty(word)
        call floaterm#enhance#showmsg('cword is empty', 1)
        return
    endif
    let repl_bufnr = floaterm#repl#get_repl_bufnr()
    if repl_bufnr
        call floaterm#terminal#send(repl_bufnr, [word])
    endif
endfunction
" ------------------------------------------------------
" Send a newline to REPL or start REPL if not running
" ------------------------------------------------------
function! floaterm#repl#send_cr_or_start() abort
    let repl_bufnr = floaterm#repl#get_repl_bufnr()
    if repl_bufnr
        call floaterm#terminal#send(repl_bufnr, [""])
    else
        call floaterm#repl#start_now()
    endif
endfunction
" ------------------------------------------------------
" Send clear command to REPL
" ------------------------------------------------------
function! floaterm#repl#send_clear() abort
    let repl_bufnr = floaterm#repl#get_repl_bufnr()
    if repl_bufnr
        if has_key(g:floaterm_repl_clear, &ft) && g:floaterm_repl_clear[&ft] != ''
            call floaterm#terminal#send(repl_bufnr, [g:floaterm_repl_clear[&ft]])
        endif
    else
        call floaterm#enhance#showmsg("Start REPL first to send clear signal.")
    endif
endfunction
" ------------------------------------------------------
" Send exit command to REPL
" ------------------------------------------------------
function! floaterm#repl#send_exit() abort
    let repl_bufnr = floaterm#repl#get_repl_bufnr()
    if repl_bufnr > 0
        if has_key(g:floaterm_repl_exit, &ft) && g:floaterm_repl_exit[&ft] != ''
            call floaterm#terminal#send(repl_bufnr, [g:floaterm_repl_exit[&ft]])
        endif
    else
        call floaterm#enhance#showmsg("Start REPL first to send exit signal.")
    endif
endfunction
" -------------------------------------------
" core function send_contents. contents is
" the codes/scripts want to send
" -------------------------------------------
function! floaterm#repl#send_contents(contents, ft, repl_bufnr, keep_curr, jump_line, vmode) abort
    let comment = floaterm#enhance#get_comment(a:ft)
    let contents = []
    for line in a:contents
        if line =~# "^\s*" . comment || line =~# "^\s*$"
            continue
        endif
        call add(contents, line)
    endfor
    if len(contents) > 0
        if len(contents) > 1 && contents[-1] =~# '^\s\+' && a:ft ==# 'python'
            call add(contents, "")
        endif
        call floaterm#terminal#send(a:repl_bufnr, contents)
    endif
    if a:keep_curr == 0
        execute "normal! " . a:jump_line . 'G'
        normal! j
        let t_col = line("$")
        let c_col = line('.')
        let line = getline('.')
        while (line =~# "^\s*" . comment || line =~# "^\s*$") && c_col < t_col
            normal! j
            let c_col = line('.')
            let line = getline('.')
        endwhile
    elseif a:keep_curr && a:vmode
        execute "normal! " . a:jump_line . 'G'
    endif
    if !has('nvim')
        redraw
    endif
endfunction
" -------------------------------------------
" sent current line or selected contents to repl
" -------------------------------------------
function! floaterm#repl#_send_range(first, last, repl_bufnr, keep_curr, ...) abort
    let firstline = a:first
    let lastline = a:last
    if firstline == lastline
        let contents = [getline(firstline)]
    else
        let contents = getline(firstline, lastline)
    endif
    if a:0 && a:1
        let vmode = 1
    else
        let vmode = 0
    endif
    if empty(contents)
        call floaterm#enhance#showmsg('No contents selected.')
        return
    elseif get(g:, 'floaterm_repl_showsend', 0)
        call floaterm#enhance#showmsg(printf("Sent L%s-L%s all %s lines", firstline, lastline, len(contents)))
    endif
    " XXX: lastline is the jump_line when keep_curr == 0
    call floaterm#repl#send_contents(contents, &ft, a:repl_bufnr, a:keep_curr, lastline, vmode)
endfunction
" core function
function! floaterm#repl#send(keep_curr) range abort
    " Normal case - send code contents
    let repl_bufnr = floaterm#repl#get_repl_bufnr()
    if repl_bufnr == 0
        call floaterm#enhance#showmsg("Do REPLFloatermStart at first.")
        return
    endif
    " Auto detect visual mode
    if mode() =~# '^[vV]' || mode() ==# "\<C-v>"
        let vmode = 1
        let [firstline] = getpos("'<")[1:1]
        let [lastline] = getpos("'>")[1:1]
    else
        let vmode = 0
        let firstline = a:firstline
        let lastline = a:lastline
    endif
    if firstline == 0 || lastline == 0 || firstline > lastline
        return
    endif
    call floaterm#repl#_send_range(firstline, lastline, repl_bufnr, a:keep_curr, vmode)
endfunction
" ----------------------------------------------
" Send border
" ------------------------------------------------------
function! floaterm#repl#send_border(border, keep_curr) abort
    let repl_bufnr = floaterm#repl#get_repl_bufnr()
    if repl_bufnr == 0
        call floaterm#enhance#showmsg("Do REPLFloatermStart at first.")
        return
    endif
    if index(['begin', 'end', 'all', 'block'], a:border) >= 0
        let border = a:border
    else
        let border = 'block'
    endif
    if border == 'all'
        let [firstline, lastline] = floaterm#enhance#get_all()
    elseif border == 'begin'
        let [firstline, lastline] = floaterm#enhance#get_begin()
    elseif border == 'end'
        let [firstline, lastline] = floaterm#enhance#get_end()
    elseif border == 'block'
        let [firstline, lastline] = floaterm#enhance#get_block()
    else
        return
    endif
    call floaterm#repl#_send_range(firstline, lastline, repl_bufnr, a:keep_curr)
endfunction
