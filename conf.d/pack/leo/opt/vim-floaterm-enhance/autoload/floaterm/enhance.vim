" -------------------------------------------
" get_visual_select
" -------------------------------------------
function! floaterm#enhance#get_visual_select() abort
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
" -------------------------------------------
" get border functions
" -------------------------------------------
" Get range from begin line to current
function! floaterm#enhance#get_begin() abort
    let curr_line = line('.')
    return [1, curr_line == 1 ? 1 : curr_line - 1]
endfunction
" Get range from current line to end
function! floaterm#enhance#get_end() abort
    let curr_line = line('.')
    let end = line("$")
    return [curr_line, end]
endfunction
" Get range of entire file
function! floaterm#enhance#get_all() abort
    return [1, line("$")]
endfunction
" Get range of current code block
function! floaterm#enhance#get_block() abort
    let ft = &ft
    let comment = floaterm#enhance#get_comment(ft)
    if type(g:floaterm_repl_block_mark[ft]) == type([])
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
" -------------------------------------
" get comment
" -------------------------------------
function! floaterm#enhance#get_comment(...) abort
    if a:0
        let ft = a:1
    else
        let ft = &filetype
    endif
    if !has_key(g:floaterm_repl_block_mark, ft) || empty(g:floaterm_repl_block_mark[ft])
        let g:floaterm_repl_block_mark[ft] = g:floaterm_repl_block_mark['default']
    endif
    if type(g:floaterm_repl_block_mark[ft]) == type([])
        let comment = split(g:floaterm_repl_block_mark[ft][0], " ")[0]
    else
        let comment = split(g:floaterm_repl_block_mark[ft], " ")[0]
    endif
    return comment
endfunction
" --------------------------------------------------------------
" echo cmdline message
" XXX:this function is from github.com/skywind3000/vim-preview
" --------------------------------------------------------------
function! floaterm#enhance#showmsg(content, ...) abort
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
endfunction

" --------------------------------------------------------------
" floaterm fzf list
" --------------------------------------------------------------
function! floaterm#enhance#term_open(line) abort
    let bufnr = str2nr(matchstr(a:line, '^\d\+'))
    if bufnr <= 0
        call floaterm#enhance#showmsg('Invalid floaterm selection', 1)
        return
    endif
    call floaterm#terminal#open_existing(bufnr)
endfunction

function! floaterm#enhance#term_fzflist() abort
    if !exists('*fzf#run')
        call floaterm#enhance#showmsg('fzf.vim is required for FloatermFzfList', 1)
        return
    endif
    let bufs = floaterm#buflist#gather()
    if empty(bufs)
        call floaterm#enhance#showmsg('No floaterm windows', 1)
        return
    endif
    let cnt = len(bufs)
    let source = []
    for bufnr in bufs
        let title = floaterm#config#get(bufnr, 'title')
        if title ==# 'floaterm($1/$2)'
            let cur = index(bufs, bufnr) + 1
            let title = substitute(title, '$1', cur, 'gm')
            let title = substitute(title, '$2', cnt, 'gm')
        endif
        if empty(title)
            let title = printf('floaterm(%d/%d)', index(bufs, bufnr) + 1, cnt)
        endif
        let position = floaterm#config#get(bufnr, 'position')
        let wintype = floaterm#config#get(bufnr, 'wintype')
        let cmd = trim(floaterm#config#get(bufnr, 'cmd'))
        let program = floaterm#config#get(bufnr, 'program', 'PROG')
        let display = printf("%s#%d\t%s!%s@%s/%s", program, bufnr, title, cmd, wintype, position)
        call add(source, display)
    endfor
    let spec = {
                \ 'source': source,
                \ 'sink': function('floaterm#enhance#term_open'),
                \ 'options': ['--prompt', 'floaterm> ', '--layout=reverse-list'],
                \ }
    call fzf#run(fzf#wrap('FloatermFzfList', spec, 0))
endfunction

" --------------------------------------------------------------
" get file path/dir/line range
" --------------------------------------------------------------
function! floaterm#enhance#get_file_absdir() abort
    return substitute(expand('%:p:h', 1), '\', '/', 'g')
endfunction
function! floaterm#enhance#get_file_abspath() abort
    return substitute(expand('%:p', 1), '\', '/', 'g')
endfunction
function! floaterm#enhance#get_file_line_range(start, end) abort
    let range = floaterm#enhance#get_file_abspath() . '#L' . a:start
    if a:start != a:end
        let range .= '-L' . a:end
    endif
    return range
endfunction
" -------------------------------------
" parse floaterm options
" -------------------------------------
function! floaterm#enhance#get_opt_param(optstr, check) abort
    let optstr = a:optstr
    let check = a:check
    if type(optstr) != type('') || type(check) != type('') || index(['wintype', 'position', 'title', 'width', 'height'], check) < 0
        return ''
    endif
    let key = '--' . check
    let pat = key . '\%([[:space:]]\|=\)\zs\S\+'
    return matchstr(optstr, pat)
endfunction
function! floaterm#enhance#parse_opt(...) abort
    let col_row_ratio = get(g:, 'floaterm_prog_col_row_ratio', 3)
    let prog_ratio = get(g:, 'floaterm_prog_ratio', 0.38)
    let float_ratio = get(g:, 'floaterm_prog_float_ratio', 0.45)
    " postions
    let basic_postions = ['auto', 'center', 'right', 'bottom', 'left', 'top', 'leftabove', 'aboveleft', 'rightbelow', 'belowright', 'botright']
    let float_postions = ['topleft', 'topright', 'bottomleft', 'bottomright', 'cusor']
    let all_postions = basic_postions + float_postions
    let open_position = get(g:, 'floaterm_prog_open_postion', 'auto')
    " wintypes
    if has('nvim')
        let wintypes = ['split', 'vsplit', 'float']
    else
        let wintypes = ['split', 'vsplit']
    endif
    let autoclose_opt = ''
    let width_opt = ''
    let height_opt = ''
    let title_opt = ''
    let wintype_opt = ''
    if a:0 && type(a:1) == type('') && len(trim(a:1))
        let optstr = trim(a:1)
        " autoclose
        let autoclose = floaterm#enhance#get_opt_param(optstr, 'autoclose')
        if empty(autoclose)
            let autoclose_opt = '--autoclose=0'
        else
            let autoclose_opt = '--autoclose=' . autoclose
        endif
        " width
        let width = floaterm#enhance#get_opt_param(optstr, 'width')
        if !empty(width)
            let width_opt = '--width=' . width
        endif
        " height
        let height = floaterm#enhance#get_opt_param(optstr, 'height')
        if !empty(height)
            let height_opt = '--height=' . height
        endif
        " title
        let title = floaterm#enhance#get_opt_param(optstr, 'title')
        if !empty(title)
            let title_opt = '--title=' . title
        endif
        " wintype
        let wintype = floaterm#enhance#get_opt_param(optstr, 'wintype')
        if !empty(wintype) && index(wintypes, wintype) >= 0
            let wintype_opt = '--wintype=' . wintype
        else
            let wintype_opt = ''
        endif
        " NOTE: open_position
        let pos = floaterm#enhance#get_opt_param(optstr, 'position')
        if !empty(pos)
            if has('nvim') && index(all_postions, pos) >= 0
                let open_position = pos
            elseif index(basic_postions, pos) >= 0
                let open_position = pos
            else
                let open_position = 'auto'
            endif
        endif
    endif
    " setup width_height_opt
    if open_position ==# 'auto'
        if col_row_ratio > 0
            if &columns > &lines * col_row_ratio
                let open_position = 'right'
            else
                let open_position = 'bottom'
            endif
        else
            let open_position = 'right'
        endif
    endif
    if open_position == 'right' && empty(width_opt)
        let width_opt = '--width=' . prog_ratio
    elseif open_position == 'bottom' && empty(height_opt)
        let height_opt = '--height=' . prog_ratio
    else
        if empty(width_opt)
            let width_opt = '--width=' . float_ratio
        endif
        if empty(height_opt)
            let height_opt = '--height=' . float_ratio
        endif
    endif
    " setup misc_opt
    let misc_opt = printf('%s %s %s', width_opt, height_opt, autoclose_opt)
    " return result: NOTE, wintype must be the first one
    if wintype_opt ==# '--wintype=float'
        if open_position ==# 'auto'
            let open_position = 'topright'
        endif
    elseif open_position ==# 'right' && empty(wintype_opt)
        let wintype_opt = '--wintype=vsplit'
    elseif open_position ==# 'bottom' && empty(wintype_opt)
        let wintype_opt = '--wintype=split'
    endif
    let result = wintype_opt . printf(' --position=%s %s %s', open_position, title_opt, misc_opt)
    let result = substitute(result, '\s\+', ' ', 'g')
    return result
endfunction
" parse programs
function! floaterm#enhance#parse_programs(programs, type) abort
    if empty(a:programs)
        call floaterm#enhance#showmsg(printf('No %s programs configured', a:type), 1)
        return []
    endif
    let result = []
    let check_lst = []
    for entry in a:programs
        if type(entry) == type('')
            let entry = [entry, '']
        elseif type(entry) == type([]) && len(entry) >= 2
            let entry = entry[0:1]
        else
            continue
        endif
        let cmd = entry[0]
        if executable(split(cmd, " ")[0])
            let opts = floaterm#enhance#parse_opt(entry[1])
            let check = cmd . '-' . opts . '-' . a:type
            if index(check_lst, check) < 0
                call add(check_lst, check)
                call add(result, [cmd, opts, a:type])
            endif
        endif
    endfor
    return result
endfunction
" --------------------------------------------------------------
" fzf select and run programs
" --------------------------------------------------------------
function! floaterm#enhance#cmd_run(cmd, opts, type, callback, ...) abort
    let wincmdp = a:0 && type(a:1) == type(0) ? a:1 : 1
    let cmd = a:cmd
    let opts = a:opts
    let type = a:type
    let wintype = floaterm#enhance#get_opt_param(opts, 'wintype')
    let position = floaterm#enhance#get_opt_param(opts, 'position')
    " check all bufs to find if the floaterm has been opened
    let t:floaterm_enhance_bufnr = 0
    let check_string = printf("%s-%s-%s", cmd, wintype, position)
    for bufnr in floaterm#buflist#gather()
        let cmd = floaterm#config#get(bufnr, 'cmd', '')
        let wintype = floaterm#config#get(bufnr, 'wintype', '')
        let position = floaterm#config#get(bufnr, 'position', '')
        if check_string ==# printf("%s-%s-%s", cmd, wintype, position)
            let t:floaterm_enhance_bufnr = bufnr
            call call(a:callback, [t:floaterm_enhance_bufnr])
            return
        endif
    endfor
    " if not found, open nen
    call execute(printf('FloatermNew %s %s', opts, cmd))
    sleep 100m
    let t:floaterm_enhance_bufnr = floaterm#buflist#curr()
    call floaterm#config#set(t:floaterm_enhance_bufnr, 'program', a:type)
    call call(a:callback, [t:floaterm_enhance_bufnr])
    if wincmdp
        wincmd p
        if has('nvim')
            stopinsert
        endif
    endif
endfunction

function! floaterm#enhance#fzf_run(programs, prompt, callback, ...) abort
    if !exists('*fzf#run')
        call floaterm#enhance#showmsg('fzf.vim is required for FloatermProgram', 1)
        return
    endif
    if empty(a:programs)
        call floaterm#enhance#showmsg('No programs provided', 1)
        return
    endif
    let prompt = a:prompt
    let l:wincmdp = a:0 && type(a:1) == type(0) ? a:1 : 1
    let l:source = []
    let l:done = v:false
    let l:selected = v:null
    let l:program_map = {}
    for item in a:programs
        if type(item) != type([]) || len(item) < 3
            continue
        endif
        let cmd = item[0]
        let opts = item[1]
        let type = item[2]
        let display = printf('%s|%s %s', type, cmd, opts)
        let l:program_map[display] = [cmd, opts, type]
        call add(l:source, display)
    endfor
    if empty(l:source)
        call floaterm#enhance#showmsg('No valid programs available', 1)
        return
    endif
    " sink to select
    function! s:floaterm_program_sink(selection) abort closure
        if empty(a:selection) || !has_key(l:program_map, a:selection)
            let l:selected = v:null
        else
            let l:selected = a:selection
        endif
        call s:floaterm_program_finish()
    endfunction
    " exit
    function! s:floaterm_program_exit(code) abort closure
        let l:selected = v:null
        call s:floaterm_program_finish()
    endfunction
    " finish and call
    function! s:floaterm_program_finish() abort closure
        if empty(l:selected)
            return
        else
            let [cmd, opts, type] = l:program_map[l:selected]
            call floaterm#enhance#cmd_run(cmd, opts, type, a:callback, l:wincmdp)
        endif
    endfunction
    " fzf run spect
    let l:spec = {
                \ 'source': l:source,
                \ 'sink': function('s:floaterm_program_sink'),
                \ 'exit': function('s:floaterm_program_exit'),
                \ 'options': ['--prompt', prompt . '> ', '--layout=reverse-list'],
                \ }
    call fzf#run(fzf#wrap('FloatermProgram', l:spec, 0))
endfunction
