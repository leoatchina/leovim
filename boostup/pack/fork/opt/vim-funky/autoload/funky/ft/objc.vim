" Language: Objective-C (objc)
" Author: tokorom
" License: The MIT License

function! funky#ft#objc#filters()
    let filters = [
                \ { 'pattern': '\m\C^\(-\|+\)\s*([a-zA-Z0-9<> *]\+)\s*.*',
                \   'formatter': [] }
                \ ]

    " Add the cpp filters
    call extend(filters, funky#ft#cpp#filters())

    return filters
endfunction
