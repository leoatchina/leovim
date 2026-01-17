" -------------------------------------
" get repl buf nr
" -------------------------------------
function! floaterm#repl#create_idx(...) abort
    if a:0 && type(a:1) == type(0) && a:1
        let bufnr = a:1
    else
        let bufnr = winbufnr(winnr())
    endif
    return &ft . '-' . bufnr
endfunction
function! floaterm#repl#get_repl_bufnr(idx) abort
    if exists('t:floaterm_repl_terms') && has_key(t:floaterm_repl_terms, a:idx)
        let termname = t:floaterm_repl_terms[a:idx]
        let bufnr = floaterm#terminal#get_bufnr(termname)
        if bufnr
            return [bufnr, termname]
        else
            call remove(t:floaterm_repl_terms, a:idx)
            return [0, '']
        endif
    else
        return [0, '']
    endif
endfunction
" -------------------------------------
" set repl terminal name
" -------------------------------------
function! floaterm#repl#set_termname(ft, bufnr, termname) abort
    if !exists('t:floaterm_repl_terms')
        let t:floaterm_repl_terms = {}
    endif
    let idx = floaterm#repl#create_idx(a:bufnr)
    let t:floaterm_repl_terms[idx] = a:termname
endfunction
" -------------------------------------
" get repl programs for filetype
" -------------------------------------
function! floaterm#repl#get_ft_programs(ft) abort
    let l:entries = get(g:floaterm_repl_programs, a:ft, [])
    let l:result = []
    for entry in l:entries
        if type(entry) != type([]) || len(entry) < 2
            continue
        endif
        let cmd = entry[0]
        let optstr = floaterm#enhance#parse_opt(entry[1])
        call add(l:result, [cmd, optstr, 'REPL'])
    endfor
    return l:result
endfunction
" -------------------------------------
" start repl (internal function)
" -------------------------------------
function! floaterm#repl#_start(ft, start_now) abort
    if !exists('g:floaterm_repl_programs') || !has_key(g:floaterm_repl_programs, a:ft) || empty(g:floaterm_repl_programs[a:ft])
        call floaterm#enhance#showmsg(printf("REPL program for %s not set or installed, please install and add it via floaterm#repl#update_program().", a:ft), 1)
        return
    endif
    let win_bufnr = winbufnr(winnr())
    let idx = floaterm#repl#create_idx(win_bufnr)
    let [repl_bufnr, termname] = floaterm#repl#get_repl_bufnr(idx)
    if repl_bufnr
        call floaterm#enhance#showmsg(printf("REPL for %s already started", win_bufnr))
        return
    endif
    try
        if empty(termname) || !repl_bufnr
            let programs = floaterm#repl#get_ft_programs(a:ft)
            if empty(programs)
                call floaterm#enhance#showmsg("No REPL program available for " . a:ft, 1)
                return
            endif
            if a:start_now
                let [cmd, opts, type] = programs[0]
                call floaterm#enhance#run_cmd(cmd, opts, type)
            else
                call floaterm#enhance#select_program(programs, 'FloatermREPL')
            endif
        else
            call floaterm#terminal#open_existing(repl_bufnr)
            " let termname = printf('#%s|%s!%S', win_bufnr, a:ft, toupper(split(programs[0][0], " ")[0]))
            " call floaterm#repl#set_termname(a:ft, win_bufnr, termname)
        endif
    catch /.*/
        call floaterm#enhance#showmsg("Error occurred when choosing REPL program", 1)
        return
    endtry
endfunction
" -------------------------------------
" start repl (auto select program)
" -------------------------------------
function! floaterm#repl#start_now() abort
    call floaterm#repl#_start(&filetype, v:true)
endfunction
" -------------------------------------
" start repl (choose program interactively)
" -------------------------------------
function! floaterm#repl#start_choose() abort
    call floaterm#repl#_start(&filetype, v:false)
endfunction
" -------------------------------------
" set repl program for each filetype
" -------------------------------------
function! floaterm#repl#update_program(ft, programs, ...) abort
    let ft = a:ft
    if !exists('g:floaterm_repl_programs')
        let g:floaterm_repl_programs = {}
    endif
    let optstr = a:0 && type(a:1) == type('') ? a:1 : ''
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
        let entry = [cmd, optstr, 'REPL']
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
function! floaterm#repl#mark(visual) range abort
    try
        if a:visual
            let t:floaterm_repl_marked_lines = getline("'<", "'>")
            echom "Visual selection marked."
        else
            let [start, end] = s:get_block()
            let t:floaterm_repl_marked_lines = getline(start, end)
            echom "Block code marked."
        endif
    catch /.*/
        echom "Error mark."
    endtry
endfunction
" -------------------------------------
" Using quickfix to show marked contents
" -------------------------------------
function! floaterm#repl#show_mark()
    if get(t:, 'floaterm_repl_marked_lines', []) == []
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
" -------------------------------------
" sent marked contents
" -------------------------------------
function! floaterm#repl#send_mark()
    if get(t:, 'floaterm_repl_marked_lines', []) == []
        echom "t:floaterm_repl_marked_lines is empty"
    else
        let idx = floaterm#repl#create_idx()
        let [repl_bufnr, termname] = floaterm#repl#get_repl_bufnr(idx)
        if repl_bufnr > 0
            call floaterm#repl#send_contents(t:floaterm_repl_marked_lines, ft, repl_bufnr, 1, line('.') , 0)
        endif
    endif
endfunction
" -------------------------------------
" send only one word
" -------------------------------------
function! floaterm#repl#send_word(visual) abort
    if a:visual
        let word = trim(floaterm#enhance#get_visual_select())
    else
        let word = expand('<cword>')
    endif
    if empty(word)
        call floaterm#enhance#showmsg('cword is empty', 1)
        return
    endif
    let idx = floaterm#repl#create_idx()
    let [repl_bufnr, termname] = floaterm#repl#get_repl_bufnr(idx)
    if repl_bufnr > 0
        call floaterm#terminal#send(repl_bufnr, [word])
    endif
endfunction
" ------------------------------------------------------
" Send a newline to REPL or start REPL if not running
" ------------------------------------------------------
function! floaterm#repl#send_newline() abort
    let idx = floaterm#repl#create_idx()
    let [repl_bufnr, termname] = floaterm#repl#get_repl_bufnr(idx)
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
    let idx = floaterm#repl#create_idx()
    let [repl_bufnr, termname] = floaterm#repl#get_repl_bufnr(idx)
    if repl_bufnr > 0
        if has_key(g:floaterm_repl_clear, ft) && g:floaterm_repl_clear[ft] != ''
            call floaterm#terminal#send(repl_bufnr, [g:floaterm_repl_clear[ft]])
        endif
    else
        call floaterm#enhance#showmsg("Start REPL first to send clear signal.")
    endif
endfunction
" ------------------------------------------------------
" Send exit command to REPL
" ------------------------------------------------------
function! floaterm#repl#send_exit() abort
    let idx = floaterm#repl#create_idx()
    let [repl_bufnr, termname] = floaterm#repl#get_repl_bufnr(idx)
    if repl_bufnr > 0
        if has_key(g:floaterm_repl_exit, ft) && g:floaterm_repl_exit[ft] != ''
            call floaterm#terminal#send(repl_bufnr, [g:floaterm_repl_exit[ft]])
        endif
    else
        call floaterm#enhance#showmsg("Start REPL first to send exit signal.")
    endif
endfunction
" -------------------------------------------
" core function send_contents. contents is
" the codes/scripts want to send
" -------------------------------------------
function! floaterm#repl#send_contents(contents, ft, repl_bufnr, keep, jump_line, vmode) abort
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
    if a:keep == 0
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
    elseif a:keep && a:vmode
        execute "normal! " . a:jump_line . 'G'
    endif
    if !has('nvim')
        redraw
    endif
endfunction
" -------------------------------------------
" sent current line or selected contents to repl
" -------------------------------------------
function! floaterm#repl#send(line_begin, line_end, keep, ...) range abort
    if a:0 && a:1 > 0
        let vmode = 1
    else
        let vmode = 0
    endif
    " Send newline - both line_begin and line_end are 0
    if a:line_begin == 0 || a:line_end == 0
        return
    endif
    " Normal case - send code contents
    let idx = floaterm#repl#create_idx()
    let [repl_bufnr, termname] = floaterm#repl#get_repl_bufnr(idx)
    if repl_bufnr < 0
        call floaterm#enhance#showmsg("Do REPLFloatermStart at first.")
        return
    endif
    let line_begin = a:line_begin
    let line_end = a:line_end
    if vmode
        let [line_begin] = getpos("'<")[1:1]
        let [line_end] = getpos("'>")[1:1]
    endif
    if line_begin == 0 || line_end == 0 || line_begin > line_end
        return
    endif
    " NOTE: if visual selected, line('.') == 1, otherwise row where cursor located
    if line_begin == line_end
        let contents = [getline(line_begin)]
    else
        let contents = getline(line_begin, line_end)
    endif
    if empty(contents)
        call floaterm#enhance#showmsg('No contents selected.')
        return
    elseif get(g:, 'floaterm_repl_showsend', 0)
        call floaterm#enhance#showmsg(printf("%s,%s %slines", line_begin, line_end, len(contents)))
    endif
    call floaterm#repl#send_contents(contents, &ft, repl_bufnr, a:keep, line_end, vmode)
endfunction
" ------------------------------------------------------
" Send border
" ------------------------------------------------------
function! floaterm#repl#send_border(border, keep) abort
    let keep = a:keep
    if index(['begin', 'end', 'all', 'block'], a:border) >= 0
        let border = a:border
    else
        let border = 'block'
    endif
    if border == 'all'
        let [line_begin, line_end] = floaterm#enhance#get_all()
    elseif border == 'line_begin'
        let [line_begin, line_end] = floaterm#enhance#get_begin()
    elseif border == 'end'
        let [line_begin, line_end] = floaterm#enhance#get_end()
    " block
    else
        let [line_begin, line_end] = floaterm#enhance#get_block()
    endif
    call floaterm#repl#send(line_begin, line_end, keep)
endfunction
