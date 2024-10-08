" File: autoload/funky/utils.vim
" Author: Takahiro Yoshihara <leoatchina@gmail.com>
" License: The MIT License
" Copyright (c) 2014 Takahiro Yoshihara

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

if get(g:, 'funky_utils_loaded', 0)
    finish
endif
let g:funky_utils_loaded = 1

let s:saved_cpo = &cpo
set cpo&vim

let s:li = funky#literals#new()

function! s:is_windows()
    return has('win32') || has('win64')
endfunction

let s:fu = {}

function! funky#utils#new()
    return deepcopy(s:fu)
endfunction

function! funky#utils#buffers()
    redir => ilist
    silent! ls
    redir END
    let lst = split(ilist, "\n")
    let buffers = {}
    for each in lst
        let sp = split(each)[:2]
        let buffers[sp[0]] = sp[2][1:-2]
    endfor
    return buffers
endfunction

function! s:fu.build_path(...)
    if a:0 == 0 | return '' | endif
    let sp = '/'
    if s:is_windows()
        if exists('+shellslash')
            let sp = (&shellslash ? '/' : '\')
        endif
    endif
    return join(a:000, sp)
endfunction

function! s:fu.fname(bufnr, ...)
    let path = fnamemodify(bufname(a:bufnr), ':p')
    if a:0
        if a:1 == 'f'
            " file name only
            return fnamemodify(path, ':p:t')
        elseif a:1 == 'd'
            " dir name only
            return fnamemodify(path, ':p:h')
        endif
    endif
    return path
endfunction

function! s:fu.is_real_file(bufnr)
    if &buftype =~# '\v^(nofile|quickfix|help)$' | return 0 | endif
    let path = fnamemodify(bufname(a:bufnr), ':p')
    silent call self.debug(path . ': ' . filereadable(path))
    return filereadable(path)
endfunction

function! s:fu.debug(...)
    if !g:funky#is_debug | return | endif
    if a:0 == 0 | return | endif
    echomsg '[DEBUG]' . join(a:000, '')
endfunction

function! s:fu.split_line(line)
    return split(a:line, s:li.pat_meta_for_split())
endfunction

let &cpo = s:saved_cpo
unlet s:saved_cpo
