" Language: CSS
" Author: Ansel Santosa <anstosa@gmail.com>
" License: The MIT License

function! funky#ft#css#filters()
    let filters = [
                \ { 'pattern': '\v\s*[^{]+\s*\{',
                \   'formatter': ['\v^\s*|\s*\{.*', '', 'g'] }
                \ ]
    return filters
endfunction
