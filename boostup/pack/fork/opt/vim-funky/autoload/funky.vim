" File: autoload/funky.vim
" Description: a simple function navigator
" Author: Takahiro Yoshihara
" License: The MIT License

" Copyright (c) 2012-2015 Takahiro Yoshihara

" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:

" The above copyright notice and this permission notice shall be included in all
" copies or substantial portions of the Software.

" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
" SOFTWARE.

if get(g:, 'funky_loaded', 0)
    finish
endif
let g:funky_loaded = 1

let s:save_cpo = &cpo
set cpo&vim

let s:li = funky#literals#new()


" Object: s:filters
let s:filters = {}
let s:filters.filetypes = {}

function! s:filters.load(ft)
    return self.filetypes[a:ft]
endfunction

function! s:filters.save(ft, filters)
    let self.filetypes[a:ft] = a:filters
endfunction

" script local funcs
function! s:error(msg)
    echohl ErrorMsg | echomsg a:msg | echohl NONE
    let v:errmsg  = a:msg
endfunction

function! s:load_buffer_by_name(bufnr)
    execute 'keepalt buffer ' . bufname(a:bufnr)
endfunction

function! s:filetype(bufnr)
    return getbufvar(a:bufnr, '&l:filetype')
endfunction

function! s:has_filter(ft)
    let func = 'autoload/funky/ft/' . a:ft . '.vim'
    return !empty(globpath(&runtimepath, func))
endfunction

function! s:has_post_extract_hook(ft)
    return exists('*funky#ft#' . a:ft . '#post_extract_hook')
endfunction

function! s:has_strippers(ft)
    return exists('*funky#ft#' . a:ft . '#strippers')
endfunction

function! s:filters_by_filetype(ft, bufnr)
    let filters = []
    let filters = funky#ft#{a:ft}#filters()
    call s:filters.save(a:ft, filters)
    return filters
endfunction

function! s:definition(line)
    return matchstr(a:line, '^.*\ze\t#')
endfunction

function! s:buflnum(line)
    return matchstr(a:line, '\zs\t#.\+$')
endfunction

function! s:sort_candidates(a, b)
    let line1 = str2nr(matchstr(a:a, '\d\+$'), 10)
    let line2 = str2nr(matchstr(a:b, '\d\+$'), 10)
    return line1 == line2 ? 0 : line1 > line2 ? 1 : -1
endfunction

function! s:sort_mru(a, b)
    let a = a:a
    let b = a:b
    return a[1] == b[1] ? 0 : a[1] > b[1] ? 1 : -1
endfunction

function! s:str2def(line)
    return matchstr(a:line, '^.*\ze\t#')
endfunction

function! s:uniq(list)
    return exists('*uniq') ? uniq(a:list) : a:list
endfunction

function! s:is_nudist(ft)
    return index(s:nudists, a:ft) >= 0
endfunction

function! s:be_naked(lines, strippers)
    let ls = []

    for l in a:lines
        let [lstr, rstr] = s:fu.split_line(l)
        for s in a:strippers
            if lstr =~# s.pattern
                let lstr = get(matchlist(lstr, s.pattern), s.position)
                break
            end
        endfor
        call add(ls, lstr . rstr)
    endfor
    return ls
endfunction

function! funky#buflisted()
    let filter =  'buflisted(v:val) && '
    let filter .= 'getbufvar(v:val, "&filetype") != "" && '
    let filter .= 'getbufvar(v:val, "&filetype") != "qf" && '
    let filter .= 'getbufvar(v:val, "&buftype") != "terminal" && '
    let filter .= 'getbufvar(v:val, "&file") =~ ""'
    return filter(range(1, bufnr('$')),  filter)
endfunction

" Provides a list of strings to search in
" Return: List
function! funky#funky(all)
    " buffer is active when this function is invoked
    try
        " NOTE: To prevent fzf error. this is a bug on fzf itself, perhaps?
        let saved_ei = &eventignore
        let &eventignore = 'BufLeave'

        let bufnr = bufnr('')
        let winnr = winnr()
        let pos = getpos('.')

        if a:all
            let bufs = funky#buflisted()
        else
            let bufs = [bufnr]
        endif

        let funkies = funky#candidates(bufs)
        " goto former postisn
        execute 'buffer ' . bufname(bufnr)
        execute winnr . 'wincmd w'
        call setpos('.', pos)
        return funkies
    finally
        let &eventignore = saved_ei
    endtry
endfunction

function! funky#candidates(bufs)
    let funkies = []
    for bufnr in a:bufs
        call s:load_buffer_by_name(bufnr)
        let filetype = s:filetype(bufnr)
        for ft in split(filetype, '\.')
            if s:has_filter(ft)
                let filters = s:filters_by_filetype(ft, bufnr)
                let st = reltime()
                let funkies += funky#extract(bufnr, filters)
                call s:fu.debug('Extract: ' . len(funkies) . ' lines in ' . reltimestr(reltime(st)))
                if s:has_post_extract_hook(ft)
                    let funkies = funky#ft#{ft}#post_extract_hook(funkies)
                endif
                if s:is_nudist(ft) && s:has_strippers(ft)
                    let funkies = s:be_naked(funkies, funky#ft#{ft}#strippers())
                endif
            elseif get(s:, 'report_filter_error', 0)
                echoerr printf('%s: filters not exist', ft)
            endif
        endfor
    endfor
    return funkies
endfunction

function! funky#extract(bufnr, patterns)
    let funkies = []
    let winnr = bufwinnr(bufnr(''))
    try
        execute bufwinnr(a:bufnr) . 'wincmd w'
        let mru = []
        for c in a:patterns
            let offset = get(c, 'offset', 0)
            redir => ilist
            " using global is fast enough
            execute 'silent! global/' . c.pattern . '/echo printf("%s \t#%s:%d:%d", getline(line(".") + offset), "", a:bufnr, line(".") + offset)'
            redir END

            if ilist =~# s:li.pat_meta()
                for l in split(ilist, '\n')
                    let [lstr, rstr] = s:fu.split_line(l)
                    let formatter = c.formatter
                    let [pat, str, flags] = [get(formatter, 0, ''), get(formatter, 1, ''), get(formatter, 2, '')]
                    let filtered = substitute(lstr, pat, str, flags) . rstr
                    call add(funkies, filtered)
                endfor
            endif
        endfor
        let sorted = sort(funkies, function('s:sort_candidates'))
        let prior = map(sort(mru, function('s:sort_mru')), 'v:val[0]')
        let results = s:uniq(prior + sorted)
        return results
    finally
        execute winnr . 'wincmd w'
    endtry
endfunction

" It does an action after jump to a definition such as 'zxzz'
" In most of cases, this is used for opening folds.
function! funky#after_jump()
    let pattern = '^\m\C\(z[xoOv]\)\?\(z[zt]\)\?$'
    " parse setting.
    if empty(s:after_jump)
        return
    elseif type(s:after_jump) == type('')
        let action = s:after_jump
    elseif type(s:after_jump) == type({})
        let action = get(s:after_jump, &filetype,
                    \ get(s:after_jump, 'default', 'zxzz')
                    \ )
    else
        echoerr 'Invalid type for g:funky_after_jump, need a string or dict'
        return
    endif
    if empty(action) | return | endif
    " verify action string pattern.
    if action !~ pattern
        echoerr 'Invalid content in g:funcky_after_jump, need "z[xov]z[zt]"'
        return
    else
        let matched = matchlist(action, pattern)
        let [foldview, scrolling] = matched[1:2]
    endif
    if !&foldenable || foldlevel(line('.')) == 0
        let action = scrolling
    endif
    silent! execute 'normal! ' . action . '0'
endfunction

function! funky#getutils()
    return get(s:, 'fu', funky#utils#new())
endfunction

function! funky#getliterals()
    return get(s:, 'li', funky#literals#new())
endfunction

" ----------------------------------
" Configuration
" ----------------------------------
let g:funky#is_debug = get(g:, 'funky_debug', 0)

let s:errmsg = ''

" after jump action
let s:after_jump = get(g:, 'funky_after_jump', 'zxzz')
" 1: set the same filetype as source buffer
let s:syntax_highlight = get(g:, 'funky_syntax_highlight', 0)

let s:matchtype = get(g:, 'funky_matchtype', 'line')
if index(['line', 'path', 'tabs', 'tabe'], s:matchtype) < 0
    echoerr 'WARN: value "' . s:matchtype . '" not allowed for g:funky_matchtype.'
    let s:matchtype = 'line'
endif

let s:nudists = get(g:, 'funky_nudists', [])

let s:fu = funky#getutils()
let s:li = funky#getliterals()


" ----------------------------------
" set cpo
" ----------------------------------
let &cpo = s:save_cpo
unlet s:save_cpo
