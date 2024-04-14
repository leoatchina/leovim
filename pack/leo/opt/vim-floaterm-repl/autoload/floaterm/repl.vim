" get formly visual select
function! s:trim(str) abort
    return substitute(a:str, "^\s\+\|\s\+$", "", "g")
endfunction
function! s:get_visual_select() abort
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ""
    endif
    let lines[-1] = lines[-1][:column_end - (&selection == "inclusive" ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction
" echo cmdline message, this function is from github.com/skywind3000/vim-preview
function! s:showmsg(content, ...)
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
" get border
" -------------------------------------------
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
    let ft = &ft
    let comment = s:get_comment(ft)
    if border == 'all'
        let lst = [1, line("$")]
    else
        let curr_line = line('.')
        if border == 'begin'
            let start = 1
            let lst =[1, curr_line == 1 ? 1 : curr_line - 1]
        elseif border == 'end'
            let end = line("$")
            let lst = [curr_line, end]
        " block
        else
            if type(g:floaterm_repl_block_mark[ft]) == v:t_list
                let lst = []
                for each in g:floaterm_repl_block_mark[ft]
                    call add(lst, '^' . each)
                endfor
                let search_str = join(lst, '\|')
            else
                let search_str = '^' . g:floaterm_repl_block_mark[ft]
            endif
            " start
            let start = search(search_str, 'nbW')
            if start == 0
                let start = 1
            elseif getline(start)[0] ==# comment
                let start += 1
            endif
            " end
            let end = search(search_str, 'nW')
            if end == 0
                let end = line("$")
            endif
            if getline(end)[0] ==# comment && end > start
                let end -= 1
            endif
            let lst = [start, end]
        endif
    endif
    return lst
endfunction
" choose a program to run repl
function! s:choose_program(lst) abort
    let cmds = a:lst
    if len(cmds) == 0
        return ""
    endif
    let cnt = 0
    let lines = []
    let title = "Which REPL program"
    for cmd in cmds
        let cnt += 1
        call add(lines, '&' . cnt . ' '. cmd)
    endfor
    if &rtp=~#'vim-quickui'
        let opts = {'title': title, 'index': g:quickui#listbox#cursor, 'w': 64}
        let idx = quickui#listbox#inputlist(lines, opts)
        if idx >= 0
            return cmds[idx]
        endif
    else
        let cnt += 1
        if a:0 >= 3 && a:3 != ''
            call add(lines, '&' . a:3)
        else
            call add(lines, '&0None')
        endif
        let content = join(lines, "\n")
        let idx = confirm(title, content, cnt)
        if idx > 0 && idx < cnt
            return cmds[idx-1]
        endif
    endif
    return ""
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
        let g:floaterm_repl_new_cmd = "FloatermNew --wintype=vsplit --postion=right --width="
    else
        let g:floaterm_repl_new_cmd = "FloatermNew --wintype=split --postion=bottom --height="
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
function! floaterm#repl#quickui_mark()
    if get(t:, 'floaterm_repl_marked_lines', []) == []
        echo "t:floaterm_repl_marked_lines is None"
    else
        call quickui#textbox#open(t:floaterm_repl_marked_lines, {"close":"button", "title": "repl_marked_lines"})
    endif
endfunction
" -------------------------------------------
" core function
" -------------------------------------------
function! s:send(lines, ft, repl_bufnr, keep, jump_line, vmode) abort
    let comment = s:get_comment(a:ft)
    let lines = []
    for line in a:lines
        if line =~# "^\s*" . comment || line =~# "^\s*$"
            continue
        endif
        call add(lines, line)
    endfor
    if len(lines) > 0
        if len(lines) > 1 && lines[-1] =~# '^\s\+' && a:ft ==# 'python'
            call add(lines, "")
        endif
        call floaterm#terminal#send(a:repl_bufnr, lines)
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
" sent marked lines
" -------------------------------------------
function! floaterm#repl#send_mark()
    if get(t:, 'floaterm_repl_marked_lines', []) == []
        echom "t:floaterm_repl_marked_lines is empty"
    else
        let ft = &filetype
        let curr_bufnr = get(b:, 'floaterm_repl_curr_bufnr', winbufnr(winnr()))
        let idx = ft . curr_bufnr
        let [repl_bufnr, termname] = s:get_bufnr(idx)
        if repl_bufnr > 0
            call s:send(t:floaterm_repl_marked_lines, ft, repl_bufnr, 1, line('.') , 0)
        endif
    endif
endfunction
" -------------------------------------------
" sent current line or selected lines to repl
" -------------------------------------------
function! floaterm#repl#send(line1, line2, keep, ...) range abort
    if a:0 && a:1 > 0
        let vmode = 1
    else
        let vmode = 0
    endif
    let line1 = a:line1
    let line2 = a:line2
    let keep = a:keep
    let ft = &filetype
    let curr_bufnr = get(b:, 'floaterm_repl_curr_bufnr', winbufnr(winnr()))
    let idx = ft . curr_bufnr
    let [repl_bufnr, termname] = s:get_bufnr(idx)
    " --------------------------------------
    " line1 == line2 == 0 send enter
    " --------------------------------------
    if line1 == 0 && line2 == 0
        if repl_bufnr > 0
            call floaterm#terminal#send(repl_bufnr, [""])
        else
            if floaterm#repl#start(0)
                call s:showmsg("Starting REPL for " . ft)
            else
                call s:showmsg("Start repl failed.", 1)
            endif
        endif
        return
    " --------------------------------------
    " line2 == 0 means send clear
    " --------------------------------------
    elseif line2 == 0
        if repl_bufnr > 0
            if has_key(g:floaterm_repl_clear, ft) && g:floaterm_repl_clear[ft] != ''
                call floaterm#terminal#send(repl_bufnr, [g:floaterm_repl_clear[ft]])
            endif
        else
            call s:showmsg("Start REPL first to send clear signal.")
        endif
        return
    " --------------------------------------
    " line1 == 0 means send exit
    " --------------------------------------
    elseif line1 == 0
        if repl_bufnr > 0
            if has_key(g:floaterm_repl_exit, ft) && g:floaterm_repl_exit[ft] != ''
                call floaterm#terminal#send(repl_bufnr, [g:floaterm_repl_exit[ft]])
            endif
        else
            call s:showmsg("Start REPL first to send exit signal.")
        endif
        return
    endif
    " --------------------------------------
    " normally send
    " --------------------------------------
    if repl_bufnr < 0
        call s:showmsg("Do REPLFloatermStart at first.")
    else
        if vmode
            let [line1] = getpos("'<")[1:1]
            let [line2] = getpos("'>")[1:1]
        endif
        if line1 == 0 || line2 == 0 || line1 > line2
            return
        endif
        " NOTE: if visual selected,  line('.') == 1, otherwise row where cursor located
        if line1 == line2
            let lines = [getline(line1)]
        else
            let lines = getline(line1, line2)
        endif
        if empty(lines)
            call s:showmsg('No lines selected.')
            return
        elseif get(g:, 'floaterm_repl_showsend', 0)
            call s:showmsg(printf("%s,%s %slines", line1, line2, len(lines)))
        endif
        call s:send(lines, ft, repl_bufnr, keep, line2, vmode)
    endif
endfunction
function! floaterm#repl#send_border(border, keep) abort
    let keep = a:keep
    if index(['begin', 'end', 'all', 'block'], a:border) >= 0
        let border = a:border
    else
        let border = 'block'
    endif
    let [begin, end] = s:get_border(border)
    call floaterm#repl#send(begin, end, keep)
endfunction
