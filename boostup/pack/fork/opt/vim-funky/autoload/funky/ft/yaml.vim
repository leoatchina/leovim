" Language: YAML
" Author: dusans
" License: The MIT License

function! funky#ft#yaml#filters()
    let filters = [
                \ { 'pattern': '\v\C^\s*.*:',
                \   'formatter': ['\v\C^\s*', '', ''] }
                \ ]
    return filters
endfunction
