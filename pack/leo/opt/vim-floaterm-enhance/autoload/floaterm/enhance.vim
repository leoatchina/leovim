" -------------------------------------------
" basic functions
" -------------------------------------------
function! floaterm#enhance#trim(str) abort
    return substitute(a:str, "^\s\+\|\s\+$", "", "g")
endfunction
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
" echo cmdline message, this function is from github.com/skywind3000/vim-preview
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
endfunc
" -------------------------------------------
" get border functions
" -------------------------------------------
" Get range from begin line to current
function! floaterm#enhance#get_begin() abort
    let curr_line = line('.')
    let start = 1
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
" -------------------------------------
" get comment
" -------------------------------------
function! floaterm#enhance#get_comment(ft) abort
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

