" Language: C# (cs)
" Author: Takahiro Yoshihara <leoatchina@gmail.com>
" License: The MIT License
" This is based on Java filter by pydave
" fzf/funky/ft/java.vim

function! funky#ft#cs#filters()
    let regex = '\v^\s+'                " preamble
    let regex .= '%(<\w+>\s+){0,3}'     " visibility, static, final
    let regex .= '%(\w|[<>[\]])+\s+'    " return type
    let regex .= '\w+\s*'               " method name
    let regex .= '\(\_[^\)]*\)'         " method parameters

    let filters = [
                \ { 'pattern': regex,
                \   'formatter': ['\v(^\s*)|(\s*\{.*\ze \t#)', '', 'g'] }
                \ ]
    return filters
endfunction
