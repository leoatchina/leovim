" Language: PHP
" Author: robmiller
" License: The MIT License

let s:li = funky#literals#new()
let s:pat = {}

function! funky#ft#php#filters()
    let s:pat.func = '\v^\s*\w*%(\s*\w*)\s*function\s+[&]*(\w+)\s*\(.*$'

    let filters = [
                \ { 'pattern': s:pat.func,
                \   'formatter': ['\m\C^[\t ]*', '', ''] }
                \ ]

    if get(g:, 'funky_php_requires', 0)
        call extend(filters, [
                    \ { 'pattern': '\m\C\<require\(_once\)\?\([\t ]\+[''"]\|[\t ]*(\)',
                    \   'formatter': [] }]
                    \ )
    endif

    if get(g:, 'funky_php_includes', 0)
        call extend(filters, [
                    \ { 'pattern': '\m\C\<include\(_once\)\?\([\t ]\+[''"]\|[\t ]*(\)',
                    \   'formatter': [] }]
                    \ )
    endif

    return filters
endfunction

function! funky#ft#php#strippers()
    return [ { 'pattern': s:pat.func, 'position': 1 } ]
endfunction
