" Language: C++ (cpp)
" Author: pydave, unc0
" License: The MIT License

function! funky#ft#cpp#filters()
    " cpp is too hard to parse (and style varies wildly), so just look for
    " something that starts in the first column, has brackets, and the
    " first bracket is preceeded by a word. If you put a space before your
    " functions, then you're out of luck because this eliminates most text
    " false positives.
    let filters = [
                \ { 'pattern': '\v^%(\w|:).*\s*%(\w|:)\_[\t ]*\(',
                \   'formatter': [] }
                \ ]
    return filters
endfunction
