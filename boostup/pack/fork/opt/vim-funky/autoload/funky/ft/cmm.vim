" Language: trace32
" Author: yalin.wang
" License: The MIT License

function! funky#ft#cmm#filters()
    let filters = [
                \ { 'pattern': '\m^\w\+:$',
                \   'formatter': []}
                \ ]
    return filters
endfunction
