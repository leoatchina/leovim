" Language: Thrift
" Author: timfeirg
" License: The MIT License

function! funky#ft#thrift#filters()
    let filters = [
                \ { 'pattern': '\m\C^[\t ]*\(struct\|service\)[\t ]\+',
                \   'formatter': [] },
                \ ]
    return filters
endfunction
