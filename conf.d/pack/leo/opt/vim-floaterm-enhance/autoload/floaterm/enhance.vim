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

function! floaterm#enhance#term_list() abort
    if !exists('*fzf#run')
        call floaterm#enhance#showmsg('fzf.vim is required for FloatermList', 1)
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
        let title = getbufvar(bufnr, 'floaterm_title')
        if title ==# 'floaterm($1/$2)'
            let cur = index(bufs, bufnr) + 1
            let title = substitute(title, '$1', cur, 'gm')
            let title = substitute(title, '$2', cnt, 'gm')
        endif
        if empty(title)
            let title = printf('floaterm(%d/%d)', index(bufs, bufnr) + 1, cnt)
        endif
        let position = getbufvar(bufnr, 'floaterm_position')
        let wintype = getbufvar(bufnr, 'floaterm_wintype')
        let cmd = getbufvar(bufnr, 'floaterm_cmd')
        let display = printf('%4d %s@%s/%s!%s', bufnr, title, wintype, position, cmd)
        call add(source, display)
    endfor
    let spec = {
                \ 'source': source,
                \ 'sink': function('floaterm#enhance#term_open'),
                \ 'options': ['--prompt', 'floaterm> ', '--layout=reverse-list'],
                \ }
    call fzf#run(fzf#wrap('FloatermList', spec, 0))
endfunction

" --------------------------------------------------------------
" get file absolute path
" --------------------------------------------------------------
function! floaterm#enhance#get_file_abspath() abort
    return '@' . fnamemodify(expand('%'), ':p')
endfunction

function! floaterm#enhance#get_file_absdir() abort
    return '@' . fnamemodify(expand('%'), ':p:h')
endfunction

" --------------------------------------------------------------
" get current line and selected lines in format @file#L1-L10
" --------------------------------------------------------------
function! floaterm#enhance#get_file_line_range(start, end) range abort
    let range = '@' . floaterm#enhance#get_file_abspath() . '#L' . a:start
    if a:start != a:end
        let range .= '-L' . a:end
    endif
    return range
endfunction

" --------------------------------------------------------------
" fzf select and run programs
" --------------------------------------------------------------
function! floaterm#enhance#select_program(programs, prompt, ...) abort
    if !exists('*fzf#run')
        call floaterm#enhance#showmsg('fzf.vim is required for FloatermProgram', 1)
        return
    endif
    if empty(a:programs)
        call floaterm#enhance#showmsg('No programs provided', 1)
        return
    endif
    let prompt = a:prompt
    let l:wincmdp = a:0 > 1 && type(a:2) == type(v:true) ? a:2 : v:true
    let l:source = []
    let l:done = v:false
    let l:selected = v:null
    let l:program_map = {}
    for item in a:programs
        if type(item) != type([]) || len(item) < 2
            continue
        endif
        let cmd = item[0]
        let opts = item[1]
        if len(item) >= 3
            let type = item[2]
        else
            let type = 'PROG'
        endif
        let display = printf('%s|%s %s', cmd, type, opts)
        let l:program_map[display] = [cmd, type, opts]
        call add(l:source, display)
    endfor
    if empty(l:source)
        call floaterm#enhance#showmsg('No valid programs available', 1)
        return
    endif

    function! s:_floaterm_program_finish() abort closure
        if !l:done
            return
        endif
        if !empty(l:selected) && has_key(l:program_map, l:selected)
            let [cmd, type , opts] = l:program_map[l:selected]
            let command = printf('FloatermNew %s %s', opts, cmd)
            try
                call execute(command)
                let t:floaterm_program_bufnr = floaterm#buflist#curr()
                call floaterm#config#set(t:floaterm_program_bufnr, 'program', type)
                if l:wincmdp
                    wincmd p
                endif
            catch /.*/
                call floaterm#enhance#showmsg('Failed to run program: ' . cmd, 1)
            endtry
        else
            let t:floaterm_program_bufnr = v:null
        endif
    endfunction

    function! s:_floaterm_program_sink(selection) abort closure
        let l:done = v:true
        if empty(a:selection) || !has_key(l:program_map, a:selection)
            let l:selected = v:null
        else
            let l:selected = a:selection
        endif
        call timer_start(0, {-> s:_floaterm_program_finish()})
        return
    endfunction
    function! s:_floaterm_program_exit(code) abort closure
        let l:done = v:true
        let l:selected = v:null
        call timer_start(0, {-> s:_floaterm_program_finish()})
    endfunction
    let l:spec = {
                \ 'source': l:source,
                \ 'sink': function('s:_floaterm_program_sink'),
                \ 'exit': function('s:_floaterm_program_exit'),
                \ 'options': ['--prompt', prompt . '> ', '--layout=reverse-list'],
                \ }
    call fzf#run(fzf#wrap('FloatermProgram', l:spec, 0))
endfunction
" -------------------------------------
" parse floaterm options
" -------------------------------------
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
    let wintype_opt = ''
    let title_opt = ''
    function! _parse(optstr, parse) abort
        let optstr = a:optstr
        let parse = a:parse
        if type(optstr) != type('') || type(parse) != type('') || index(['wintype', 'position', 'title'], parse) < 0
            return ''
        endif
        let key = '--' . parse
        let pat = key . '\%([[:space:]]\|=\)\zs\S\+'
        return matchstr(optstr, pat)
    endfunction

    if a:0 && type(a:1) == type('')
        let pos = _parse(a:1, 'position')
        if !empty(pos)
            if index(basic_postions, pos) >= 0 && !has('nvim')
                let open_position = pos
            elseif index(all_postions, pos) >= 0
                let open_position = pos
            endif
        endif
        let wintype = _parse(a:1, 'wintype')
        if !empty(wintype) && index(wintypes, wintype) >= 0
            let wintype_opt = '--wintype=' . wintype
        endif
        let title = _parse(a:1, 'title')
        if !empty(title)
            let title_opt = '--title=' . title
        endif
    endif

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
    " todo, adjust this part
    if open_position ==# 'right' && empty(wintype_opt)
        let wintype_opt = '--wintype=vsplit'
        return printf(' --position=right --width=%s %s %s', prog_ratio, wintype_opt, title_opt)
    elseif open_position ==# 'bottom' && empty(wintype_opt)
        let wintype_opt = '--wintype=split'
        return printf(' --position=bottom --height=%s %s %s', prog_ratio, wintype_opt, title_opt)
    elseif wintype_opt == '--wintype=float'
        if open_position == 'auto'
            let open_position = 'topright'
        endif
        return printf(' --position=%s --wintype=float --width=%s --height=%s %s', open_position, float_ratio, float_ratio, title_opt)
    else
        return printf(' --position=%s %s %s', open_position, wintype_opt, title_opt)
    endif
endfunction
