" Language: Dart
" Author: Takahiro Yoshihara <leoatchina@gmail.com>
" License: The MIT License

function! funky#ft#dart#filters()
    let filters = [
                \ { 'pattern': '\v[\t ]*\w+[\t ]+(%(%(get|set)[\t ]+)|\w+[\t ]*\(.*\{)',
                \   'formatter': [] },
                \ ]
    return filters
endfunction
