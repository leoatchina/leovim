" -------------------------------------------
" get formly visual select
" -------------------------------------------
function! s:trim(str) abort
    return substitute(a:str, "^\s\+\|\s\+$", "", "g")
endfunction
function! s:get_visual_select() abort
    let [line_begin, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let contents = getline(line_begin, line_end)
    if len(contents) == 0
        return ""
    endif
    let contents[-1] = contents[-1][:column_end - (&selection == "inclusive" ? 1 : 2)]
    let contents[0] = contents[0][column_start - 1:]
    return join(contents, "\n")
endfunction
" echo cmdline message, this function is from github.com/skywind3000/vim-preview
function! s:showmsg(content, ...) abort
    let saveshow = &showmode
    set noshowmode
    let wincols = &columns
    let statusline = (&laststatus==1 && winnr('$')>1) || (&laststatus==2)
    let reqspaces_lastline = (statusline || !&ruler) ? 12 : 29
    let width = len(a:content)
    let limit = wincols - reqspaces_lastline
    let l:content = a:content
    if width + 1 > limit
        let l:content = strpart(l:content, 0, limit - 1)
        let width = len(l:content)
    endif
    " prevent scrolling caused by multiple echo
    redraw | echo '' | redraw
    if a:0 > 0 && a:1 > 0
        echohl ErrorMsg
        echo l:content
        echohl NONE
    else
        echohl Type
        echo l:content
        echohl NONE
    endif
    if saveshow != 0
        set showmode
    endif
endfunc
" -------------------------------------
" get repl buf nr
" -------------------------------------
function! s:get_bufnr(idx) abort
    if exists('t:floaterm_repl_termnames') && has_key(t:floaterm_repl_termnames, a:idx)
        let termname = t:floaterm_repl_termnames[a:idx]
        let bufnr = floaterm#terminal#get_bufnr(termname)
        return [bufnr, termname]
    else
        return [-1, '']
    endif
endfunction
" -------------------------------------
" update repl terminal name
" -------------------------------------
function! s:update_termname(ft, bufnr, termname) abort
    if !exists('t:floaterm_repl_termnames')
        let t:floaterm_repl_termnames = {}
    endif
    let idx = a:ft . a:bufnr
    let t:floaterm_repl_termnames[idx] = a:termname
endfunction
" -------------------------------------
" get comment
" -------------------------------------
function! s:get_comment(ft) abort
    if !has_key(g:floaterm_repl_block_mark, a:ft) || empty(g:floaterm_repl_block_mark[a:ft])
        let g:floaterm_repl_block_mark[a:ft] = g:floaterm_repl_block_mark['default']
    endif
    if type(g:floaterm_repl_block_mark[a:ft]) == type([])
        let comment = split(g:floaterm_repl_block_mark[a:ft][0], " ")[0]
    else
        let comment = split(g:floaterm_repl_block_mark[a:ft], " ")[0]
    endif
    return comment
endfunction
" -------------------------------------------
" get border functions
" -------------------------------------------
" Get range from beginning to current line
function! s:get_begin() abort
    let curr_line = line('.')
    let start = 1
    return [1, curr_line == 1 ? 1 : curr_line - 1]
endfunction
" Get range from current line to end
function! s:get_end() abort
    let curr_line = line('.')
    let end = line("$")
    return [curr_line, end]
endfunction
" Get range of entire file
function! s:get_all() abort
    return [1, line("$")]
endfunction
" Get range of current code block
function! s:get_block() abort
    let ft = &ft
    let comment = s:get_comment(ft)
    if type(g:floaterm_repl_block_mark[ft]) == v:t_list
        let lst = []
        for each in g:floaterm_repl_block_mark[ft]
            call add(lst, '^' . each)
        endfor
        let search_str = join(lst, '\|')
    else
        let search_str = '^' . g:floaterm_repl_block_mark[ft]
    endif
    " Find block start position
    let start = search(search_str, 'nbW')
    if start == 0
        let start = 1
    elseif getline(start)[0] ==# comment
        let start += 1
    endif
    " Find block end position
    let end = search(search_str, 'nW')
    if end == 0
        let end = line("$")
    endif
    if getline(end)[0] ==# comment && end > start
        let end -= 1
    endif
    return [start, end]
endfunction
" Original function, kept for backward compatibility, but calls new functions
function! s:get_border(...) abort
    if a:0 > 0
        if index(['begin', 'end', 'all', 'block'], a:1) >= 0
            let border = a:1
        else
            let border = 'block'
        endif
    else
        let border = 'block'
    endif

    if border == 'all'
        return s:get_all()
    elseif border == 'begin'
        return s:get_begin()
    elseif border == 'end'
        return s:get_end()
    else " block
        return s:get_block()
    endif
endfunction
" -------------------------------------
" choose a program to run repl
" -------------------------------------
function! s:choose_program(lst) abort
    let cmds = a:lst
    if len(cmds) == 0
        return ""
    endif
    let cnt = 0
    let contents = []
    let title = "Which REPL program"
    for cmd in cmds
        let cnt += 1
        call add(contents, '&' . cnt . ' '. cmd)
    endfor
    if &rtp=~#'vim-quickui'
        let opts = {'title': title, 'index': g:quickui#listbox#cursor, 'w': 64}
        let idx = quickui#listbox#inputlist(contents, opts)
        if idx >= 0
            return cmds[idx]
        endif
    else
        let cnt += 1
        if a:0 >= 3 && a:3 != ''
            call add(contents, '&' . a:3)
        else
            call add(contents, '&0None')
        endif
        let content = join(contents, "\n")
        let idx = confirm(title, content, cnt)
        if idx > 0 && idx < cnt
            return cmds[idx-1]
        endif
    endif
    return ""
endfunction
" -------------------------------------------
" core function
" -------------------------------------------
function! s:send_contents(contents, ft, repl_bufnr, keep, jump_line, vmode) abort
    let comment = s:get_comment(a:ft)
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
" -------------------------------------
" set repl program for each filetype
" -------------------------------------
function! floaterm#repl#add_program(ft, ...) abort
    let ft = a:ft
    for cmd in a:000
        let cmd = s:trim(cmd)
        let lst = split(cmd, ' ')
        if executable(lst[0])
            if !has_key(g:floaterm_repl_programs, ft)
                let g:floaterm_repl_programs[ft] = []
            endif
            if len(lst) > 1
                let cmd = join(lst, ' ')
            endif
        else
            continue
        endif
        if count(g:floaterm_repl_programs[ft], cmd) == 0
            call add(g:floaterm_repl_programs[ft], cmd)
        endif
    endfor
endfunction
" ---------------------------------------------
" update repl position, must do check at first
" ---------------------------------------------
function! floaterm#repl#update_open_position() abort
    let open_position = get(g:, 'floaterm_repl_open_position', 'auto')
    if open_position == 'auto'
        if &columns > &lines * 3
            let open_position = 'right'
        else
            let open_position = 'bottom'
        endif
    elseif index(['right', 'bottom'], open_position) < 0
        let open_position = "right"
    endif
    if open_position == 'right'
        let g:floaterm_repl_new_cmd = "FloatermNew --wintype=vsplit --position=right --width="
    else
        let g:floaterm_repl_new_cmd = "FloatermNew --wintype=split --position=bottom --height="
    endif
    let g:floaterm_repl_new_cmd = g:floaterm_repl_new_cmd . string(get(g:, 'floaterm_repl_ratio', 0.38))
endfunction
" -------------------------------------
" start repl
" -------------------------------------
function! floaterm#repl#start(choose_program) abort
    let ft = &filetype
    let choose_program = a:choose_program
    if !has_key(g:floaterm_repl_programs, ft) || len(get(g:floaterm_repl_programs, ft, [])) == 0
        call s:showmsg(printf("REPL program for %s not set or installed, please install and add it g:floaterm_repl_programs.", ft), 1)
        return v:false
    endif
    let b:floaterm_repl_curr_bufnr = winbufnr(winnr())
    let idx = ft . b:floaterm_repl_curr_bufnr
    let [repl_bufnr, termname] = s:get_bufnr(idx)
    if repl_bufnr > 0
        call s:showmsg(printf("REPL for %s already started", b:floaterm_repl_curr_bufnr))
        return v:false
    endif
    try
        if choose_program
            let program = s:choose_program(g:floaterm_repl_programs[ft])
        else
            let program = g:floaterm_repl_programs[ft][0]
        endif
    catch /.*/
        let program = ""
    endtry
    if empty(program)
        return v:false
    endif
    if empty(termname) || repl_bufnr <= 0
        let termname = printf('#%s|%s!%S', b:floaterm_repl_curr_bufnr, ft, toupper(split(program, " ")[0]))
        call s:update_termname(ft, b:floaterm_repl_curr_bufnr, termname)
        let floatermnew_cmd = printf('%s --name=%s --title=%s %s', g:floaterm_repl_new_cmd, termname, termname, program)
        execute floatermnew_cmd
    else
        call floaterm#terminal#open_existing(repl_bufnr)
    endif
    if winnr() > 0
        wincmd p
        if has('nvim')
            stopinsert
        endif
    endif
    return v:true
endfunction
" -------------------------------------
" send only one word
" -------------------------------------
function! floaterm#repl#send_word(visual) abort
    if a:visual
        let word = s:trim(s:get_visual_select())
    else
        let word = expand('<cword>')
    endif
    if empty(word)
        call s:showmsg('cword is empty', 1)
        return
    endif
    let ft = &filetype
    let curr_bufnr = get(b:, 'floaterm_repl_curr_bufnr', winbufnr(winnr()))
    let idx = ft . curr_bufnr
    let [repl_bufnr, termname] = s:get_bufnr(idx)
    if repl_bufnr > 0
        call floaterm#terminal#send(repl_bufnr, [word])
    endif
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
            let [start, end] = s:get_border('block')
            let t:floaterm_repl_marked_lines = getline(start, end)
            echom "Block code marked."
        endif
    catch /.*/
        echom "Error mark."
    endtry
endfunction
" Using quickfix to show marked contents
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
" sent marked contents
function! floaterm#repl#send_mark()
    if get(t:, 'floaterm_repl_marked_lines', []) == []
        echom "t:floaterm_repl_marked_lines is empty"
    else
        let ft = &filetype
        let curr_bufnr = get(b:, 'floaterm_repl_curr_bufnr', winbufnr(winnr()))
        let idx = ft . curr_bufnr
        let [repl_bufnr, termname] = s:get_bufnr(idx)
        if repl_bufnr > 0
            call s:send_contents(t:floaterm_repl_marked_lines, ft, repl_bufnr, 1, line('.') , 0)
        endif
    endif
endfunction
" ------------------------------------------------------
" Send a newline to REPL or start REPL if not running
" ------------------------------------------------------
function! floaterm#repl#send_newline() abort
    let ft = &filetype
    let curr_bufnr = get(b:, 'floaterm_repl_curr_bufnr', winbufnr(winnr()))
    let idx = ft . curr_bufnr
    let [repl_bufnr, termname] = s:get_bufnr(idx)
    if repl_bufnr > 0
        call floaterm#terminal#send(repl_bufnr, [""])
    else
        if floaterm#repl#start(0)
            call s:showmsg("Starting REPL for " . ft)
        else
            call s:showmsg("Start repl failed.", 1)
        endif
    endif
endfunction
" ------------------------------------------------------
" Send clear command to REPL
" ------------------------------------------------------
function! floaterm#repl#send_clear() abort
    let ft = &filetype
    let curr_bufnr = get(b:, 'floaterm_repl_curr_bufnr', winbufnr(winnr()))
    let idx = ft . curr_bufnr
    let [repl_bufnr, termname] = s:get_bufnr(idx)

    if repl_bufnr > 0
        if has_key(g:floaterm_repl_clear, ft) && g:floaterm_repl_clear[ft] != ''
            call floaterm#terminal#send(repl_bufnr, [g:floaterm_repl_clear[ft]])
        endif
    else
        call s:showmsg("Start REPL first to send clear signal.")
    endif
endfunction
" ------------------------------------------------------
" Send exit command to REPL
" ------------------------------------------------------
function! floaterm#repl#send_exit() abort
    let ft = &filetype
    let curr_bufnr = get(b:, 'floaterm_repl_curr_bufnr', winbufnr(winnr()))
    let idx = ft . curr_bufnr
    let [repl_bufnr, termname] = s:get_bufnr(idx)
    if repl_bufnr > 0
        if has_key(g:floaterm_repl_exit, ft) && g:floaterm_repl_exit[ft] != ''
            call floaterm#terminal#send(repl_bufnr, [g:floaterm_repl_exit[ft]])
        endif
    else
        call s:showmsg("Start REPL first to send exit signal.")
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
    let ft = &filetype
    let curr_bufnr = get(b:, 'floaterm_repl_curr_bufnr', winbufnr(winnr()))
    let idx = ft . curr_bufnr
    let [repl_bufnr, termname] = s:get_bufnr(idx)
    if repl_bufnr < 0
        call s:showmsg("Do REPLFloatermStart at first.")
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
        call s:showmsg('No contents selected.')
        return
    elseif get(g:, 'floaterm_repl_showsend', 0)
        call s:showmsg(printf("%s,%s %slines", line_begin, line_end, len(contents)))
    endif
    call s:send_contents(contents, ft, repl_bufnr, a:keep, line_end, vmode)
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
        let [line_begin, line_end] = s:get_all()
    elseif border == 'line_begin'
        let [line_begin, line_end] = s:get_begin()
    elseif border == 'end'
        let [line_begin, line_end] = s:get_end()
    else " block
        let [line_begin, line_end] = s:get_block()
    endif
    call floaterm#repl#send(line_begin, line_end, keep)
endfunction
