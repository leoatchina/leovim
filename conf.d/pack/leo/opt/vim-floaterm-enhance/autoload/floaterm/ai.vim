function! floaterm#ai#get_ai_bufnr(...) abort
    let t:floaterm_ai_bufnrs = get(t:, 'floaterm_ai_bufnrs', [])
    let all_bufnrs = floaterm#buflist#gather()
    if empty(all_bufnrs) || empty(t:floaterm_ai_bufnrs)
        let t:floaterm_ai_bufnrs = []
        return -1
    endif
    let ai_bufnr = (a:0 && a:1 > 0) ? a:1 : -1
    if ai_bufnr > 0 && index(t:floaterm_ai_bufnrs, ai_bufnr) >= 0 && index(all_bufnrs, ai_bufnr) >= 0
        return ai_bufnr
    endif
    call filter(t:floaterm_ai_bufnrs, {_, v -> index(all_bufnrs, v) >= 0})
    if empty(t:floaterm_ai_bufnrs)
        return -1
    endif
    return t:floaterm_ai_bufnrs[0]
endfunction

" --------------------------------------------------------------
" fzf file picker with root dir files -> send paths to latest AI terminal
" --------------------------------------------------------------
function! floaterm#ai#fzf_file_sink(lines) abort
    if empty(a:lines)
        call floaterm#enhance#showmsg('No file selected', 1)
        return
    endif
    let curr_bufnr = floaterm#buflist#curr()
    if curr_bufnr <= 0
        call floaterm#enhance#showmsg('No floaterm window found', 1)
        return
    endif
    let msg = ''
    for file_path in a:lines
        let msg .= ' @' . file_path
    endfor
    call floaterm#terminal#send(curr_bufnr, [msg], 0)
endfunction

function! floaterm#ai#fzf_file_list() abort
    if !exists('*fzf#run')
        call floaterm#enhance#showmsg('fzf.vim is required for file picker', 1)
        return
    endif
    let ai_bufnr = floaterm#ai#
    let root_dir = floaterm#path#get_root()
    let relative_dir = substitute(floaterm#enhance#get_file_absdir(), '^' . root_dir . '/', '', '')
    call fzf#vim#files(root_dir, fzf#vim#with_preview({
                \ 'sink*': function('floaterm#ai#fzf_file_sink'),
                \ 'options': ['--multi', '--prompt', 'FloatermFzfFile> ', '--query', relative_dir]
                \ }), 0)
endfunction

" --------------------------------------------------------------
" AI helpers for vim-floaterm-enhance
" --------------------------------------------------------------
function! floaterm#ai#fzf_run_sink(line) abort
    let idx = str2nr(matchstr(a:line, '^\s*\d\+'))
    if idx <= 0
        call floaterm#enhance#showmsg('Invalid AI program selection', 1)
        return
    endif
    let programs = floaterm#ai#get_programs()
    if idx > len(programs)
        call floaterm#enhance#showmsg('Invalid AI program selection', 1)
        return
    endif
    call floaterm#ai#start(programs[idx - 1])
endfunction

function! floaterm#ai#fzf_run() abort
    if !exists('*fzf#run')
        call floaterm#enhance#showmsg('fzf.vim is required for FloatermAiFzfRun', 1)
        return
    endif
    let programs = floaterm#ai#get_programs()
    if empty(programs)
        call floaterm#enhance#showmsg('No AI programs configured', 1)
        return
    endif
    let source = []
    let idx = 1
    for item in programs
        let opts = empty(item.opts) ? '' : ' ' . item.opts
        call add(source, printf('%3d %s -> %s%s', idx, item.name, item.cmd, opts))
        let idx += 1
    endfor
    let spec = {
                \ 'source': source,
                \ 'sink': function('floaterm#ai#fzf_run_sink'),
                \ 'options': ['--prompt', 'FloatermAi> ', '--layout=reverse-list']
                \ }
    call fzf#run(fzf#wrap('FloatermAiFzfRun', spec, 0))
endfunction

" --------------------------------------------------------------
" start ai prg and insert bufnr
" --------------------------------------------------------------
function! floaterm#ai#insert_ai_bufnr(bufnr) abort
    let t:floaterm_ai_bufnrs = get(t:, 'floaterm_ai_bufnrs', [])
    call filter(t:floaterm_ai_bufnrs, {_, v -> v != a:bufnr})
    call insert(t:floaterm_ai_bufnrs, a:bufnr, 0)
endfunction

function! floaterm#ai#normalize_program(entry) abort
    if type(a:entry) == type('')
        let cmd = trim(a:entry)
        return empty(cmd) ? {} : {'cmd': cmd, 'opts': '', 'name': cmd}
    elseif type(a:entry) == type([])
        let cmd = trim(get(a:entry, 0, ''))
        if empty(cmd)
            return {}
        endif
        let opts = get(a:entry, 1, '')
        if type(opts) != type('')
            let opts = string(opts)
        endif
        let opts = trim(opts)
        let name = get(a:entry, 2, cmd)
        if type(name) != type('')
            let name = string(name)
        endif
        let name = trim(name)
        if empty(name)
            let name = cmd
        endif
        return {'cmd': cmd, 'opts': opts, 'name': name}
    endif
    return {}
endfunction

function! floaterm#ai#choose_program(programs) abort
    if len(a:programs) == 0
        return {}
    endif
    let contents = []
    let cnt = 0
    let title = "Which AI program"
    for item in a:programs
        let cnt += 1
        let opts = empty(item.opts) ? '' : ' ' . item.opts
        let display = printf('%s -> %s%s', item.name, item.cmd, opts)
        call add(contents, '&' . cnt . ' '. display)
    endfor
    if exists('*QuickThemeChange')
        let opts = {'title': title, 'index': g:quickui#listbox#cursor, 'w': 64}
        let idx = quickui#listbox#inputlist(contents, opts)
        if idx >= 0
            return a:programs[idx]
        endif
    else
        let cnt += 1
        call add(contents, '&0 Cancel')
        let content = join(contents, "\n")
        let idx = confirm(title, content, cnt)
        if idx > 0 && idx < cnt
            return a:programs[idx-1]
        endif
    endif
    return {}
endfunction

function! floaterm#ai#get_program() abort
    let raw = get(g:, 'floaterm_ai_programs', [])
    let programs = []
    for entry in raw
        let prog = floaterm#ai#normalize_program(entry)
        if !empty(prog)
            call add(programs, prog)
        endif
    endfor
    if empty(programs)
        return {}
    endif
    return floaterm#ai#choose_program(programs)
endfunction

function! floaterm#ai#start() abort
    let program = floaterm#ai#get_program()
    if empty(program)
        call floaterm#enhance#showmsg('No AI programs configured', 1)
        return -1
    endif
    let opts = empty(program.opts) ? '' : program.opts
    let cmd = 'FloatermNew'
    if !empty(opts)
        let cmd .= ' ' . opts
    endif
    let term_title = program.name
    let term_name = substitute(program.name, '\s\+', '_', 'g')
    let cmd .= printf(' --name=%s --title=%s %s', term_name, term_title, program.cmd)
    execute cmd
    let new_bufnr = floaterm#buflist#curr()
    if new_bufnr > 0
        call floaterm#ai#insert_ai_bufnr(new_bufnr)
    endif
    return new_bufnr
endfunction

" --------------------------------------------------------------
" send file path with line range to latest AI terminal
" --------------------------------------------------------------
function! floaterm#ai#send_file_line_range() abort
    let range_str = floaterm#enhance#get_file_line_range()
    let curr_bufnr = floaterm#ai#get_ai_bufnr()
    if curr_bufnr <= 0
        call floaterm#enhance#showmsg('No AI floaterm window found', 1)
        return
    endif
    call floaterm#terminal#send(curr_bufnr, [range_str], 0)
endfunction
