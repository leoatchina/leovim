" Language: Proto
" Author: timfeirg
" License: The MIT License

function! funky#ft#proto#filters()
    let filters = [
                \ { 'pattern': '\m\C^[\t ]*\(message\|service\)[\t ]\+',
                \   'formatter': [] },
                \ ]
    return filters
endfunction
