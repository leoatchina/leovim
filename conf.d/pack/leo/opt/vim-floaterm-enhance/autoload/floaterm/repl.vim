" -------------------------------------
" NOTE: idx/get/set
" -------------------------------------
function! floaterm#repl#get_repl_bufnr(...) abort
    if !exists('t:floaterm_repl_dict')
        return 0
    endif
    if a:0 && type(a:1) == type('') && a:1
        let idx = a:1
    else
        let idx = floaterm#enhance#create_idx()
    endif
    if !has_key(t:floaterm_repl_dict, idx)
        return 0
    endif
    let bufnr = t:floaterm_repl_dict[idx]
    if index(floaterm#buflist#gather(), bufnr) < 0
        call remove(t:floaterm_repl_dict, idx)
        return 0
    endif
    return bufnr
endfunction
function! floaterm#repl#set_repl_bufnr(bufnr, ...) abort
    if !exists('t:floaterm_repl_dict')
        let t:floaterm_repl_dict = {}
    endif
    if a:0 && type(a:1) == type('')
        let idx = a:1
    else
        let idx = floaterm#enhance#create_idx()
    endif
    let t:floaterm_repl_dict[idx] = a:bufnr
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
        let replaced = 0
        let i = 0
        while i < len(g:floaterm_repl_programs[ft])
            if g:floaterm_repl_programs[ft][i][0] ==# cmd
                let g:floaterm_repl_programs[ft][i] = entry
                let replaced = 1
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
function! floaterm#repl#start(now) abort
    let repl_bufnr = floaterm#repl#get_repl_bufnr()
    if repl_bufnr
        call floaterm#enhance#showmsg(printf("REPL for %s already started", winbufnr(winnr())))
        call floaterm#terminal#open_existing(repl_bufnr)
    else
        let programs = floaterm#repl#get_ft_parsed_programs(&ft)
        if empty(programs)
            call floaterm#enhance#showmsg("No REPL program available for " . &ft, 1)
            return
        endif
        if a:now
            let [cmd, opts, type] = programs[0]
            call floaterm#enhance#cmd_run(cmd, opts, type)
        else
            call floaterm#enhance#fzf_run(programs, 'FloatermREPL')
        endif
    endif
    call floaterm#enhance#wincmdp()
endfunction
" ----------------------------------------------------------------------------
" core function send_range. contents is the codes/scripts want to send
" ----------------------------------------------------------------------------
function! s:send_range(first, last, ft, repl_bufnr, stay_curr, vmode, ...) abort
    let repl_bufnr = a:repl_bufnr
    let firstline = a:first
    let lastline = a:last
    if a:0 && type(a:1) == type([])
        let raw_contents = a:1
        let has_range = 0
    else
        let has_range = 1
        if firstline == lastline
            let raw_contents = [getline(firstline)]
        else
            let raw_contents = getline(firstline, lastline)
        endif
    endif
    if empty(raw_contents)
        call floaterm#enhance#showmsg('No contents selected.')
        return
    elseif has_range && get(g:, 'floaterm_repl_showsend', 0)
        call floaterm#enhance#showmsg(printf("Sent L%s-L%s all %s lines", firstline, lastline, len(raw_contents)))
    endif
    let comment = floaterm#enhance#get_comment(a:ft)
    let contents = []
    for line in raw_contents
        if line =~# "^\s*" . comment || line =~# "^\s*$"
            continue
        endif
        call add(contents, line)
    endfor
    if !len(contents)
        if a:stay_curr == 0 && has_range
            execute "normal! " . lastline . 'Gj'
        endif
        return
    endif
    if len(contents) > 1 && contents[-1] =~# '^\s\+' && a:ft ==# 'python'
        call add(contents, "")
    endif
    call floaterm#terminal#open_existing(repl_bufnr)
    call floaterm#terminal#send(repl_bufnr, contents)
    call floaterm#enhance#wincmdp()
    if a:stay_curr == 0
        execute "normal! " . lastline . 'G'
        normal! j
        let t_col = line("$")
        let c_col = line('.')
        let line = getline('.')
        while (line =~# "^\s*" . comment || line =~# "^\s*$") && c_col < t_col
            normal! j
            let c_col = line('.')
            let line = getline('.')
        endwhile
    elseif a:stay_curr && a:vmode
        execute "normal! " . lastline . 'G'
    endif
    if !has('nvim')
        redraw
    endif
endfunction
" ------------------------------------------------------
" send line/border
" ------------------------------------------------------
function! floaterm#repl#send(border, stay_curr, ...) abort
    if mode() =~# '^[vV]' || mode() ==# "\<C-v>"
        let vmode = 1
    else
        let vmode = 0
    endif
    let repl_bufnr = floaterm#repl#get_repl_bufnr()
    if repl_bufnr == 0
        call floaterm#enhance#showmsg("Do REPLFloatermStart at first.")
        return
    endif
    " Check if line range is provided as arguments
    if a:0 >= 2
        let firstline = a:1
        let lastline = a:2
    else
        if index(['begin', 'end', 'all', 'block', 'line'], a:border) >= 0
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
        elseif border == 'line'
            let firstline = line('.')
            if vmode
                let lastline = line("'>")
                let firstline = line("'<")
            else
                let lastline = firstline
            endif
        else
            return
        endif
    endif
    if firstline == 0 || lastline == 0 || firstline > lastline
        return
    endif
    call s:send_range(firstline, lastline, &ft, repl_bufnr, a:stay_curr, vmode)
endfunction
" -------------------------------------
" helper: send content to repl and return to previous window
" -------------------------------------
function! s:send_content(repl_bufnr, content) abort
    let content = type(a:content) == type([]) ? a:content : [a:content]
    call floaterm#terminal#open_existing(a:repl_bufnr)
    call floaterm#terminal#send(a:repl_bufnr, content)
    call floaterm#enhance#wincmdp()
endfunction
" -------------------------------------
" send only one word
" -------------------------------------
function! floaterm#repl#send_word(...) abort
    if a:0 >= 2
        let lines = getline(a:1, a:2)
        let word = trim(join(lines, ' '))
    elseif mode() =~# '^[vV]' || mode() ==# "\<C-v>"
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
        call s:send_content(repl_bufnr, word)
    endif
endfunction
" ------------------------------------------------------
" Send clear command to REPL
" ------------------------------------------------------
function! floaterm#repl#send_clear() abort
    let repl_bufnr = floaterm#repl#get_repl_bufnr()
    if repl_bufnr
        if has_key(g:floaterm_repl_clear, &ft) && g:floaterm_repl_clear[&ft] != ''
            call s:send_content(repl_bufnr, g:floaterm_repl_clear[&ft])
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
    if repl_bufnr
        if has_key(g:floaterm_repl_exit, &ft) && g:floaterm_repl_exit[&ft] != ''
            call s:send_content(repl_bufnr, g:floaterm_repl_exit[&ft])
        endif
    else
        call floaterm#enhance#showmsg("Start REPL first to send exit signal.")
    endif
endfunction
" -------------------------------------
" mark
" -------------------------------------
function! floaterm#repl#send_mark() abort
    if get(t:, 'floaterm_repl_marked_lines', []) == []
        echom "t:floaterm_repl_marked_lines is empty"
    else
        let repl_bufnr = floaterm#repl#get_repl_bufnr()
        if repl_bufnr
            call s:send_content(repl_bufnr, t:floaterm_repl_marked_lines)
        endif
    endif
endfunction
function! floaterm#repl#mark(...) abort
    if a:0 >= 2
        let firstline = a:1
        let lastline = a:2
        let t:floaterm_repl_marked_lines = getline(firstline, lastline)
        echom "Range marked."
    elseif mode() =~# '^[vV]' || mode() ==# "\<C-v>"
        let t:floaterm_repl_marked_lines = getline(line("'<"), line("'>"))
        echom "Visual selection marked."
    else
        let [start, end] = floaterm#enhance#get_block()
        let t:floaterm_repl_marked_lines = getline(start, end)
        echom "Block code marked."
    endif
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
" --------------------------------------------------------
" Send a newline to REPL or start REPL if not running
" --------------------------------------------------------
function! floaterm#repl#send_cr_or_start(start, ...) abort
    let repl_bufnr = floaterm#repl#get_repl_bufnr()
    if repl_bufnr
        call s:send_content(repl_bufnr, "")
    elseif a:start
        call floaterm#repl#start(a:0 && a:1 ? 1 : 0)
    endif
endfunction
