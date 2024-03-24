" Language: Ruby (ruby)
" Author: Takahiro Yoshihara <leoatchina@gmail.com>
" License: The MIT License

let s:fu = funky#getutils()
let s:pat = {}

function! funky#ft#ruby#filters()
    let s:pat.method = '\m\C^[\t ]*def[\t ]\+\(\w\+\)'

    let filters = [
                \ { 'pattern': s:pat.method,
                \   'formatter': []}
                \ ]

    if get(g:, 'funky_ruby_requires', 0)
        call extend(filters, [
                    \ { 'pattern': '\m\C^[\t ]*require\(_relative\)\?[\t ]\+\S\+',
                    \   'formatter': [] }]
                    \ )
    endif

    if get(g:, 'funky_ruby_classes', 1)
        call extend(filters, [
                    \ { 'pattern': '\m\C^[\t ]*class[\t ]\+\S\+',
                    \   'formatter': [] }]
                    \ )
    endif

    if get(g:, 'funky_ruby_modules', 1)
        call extend(filters, [
                    \ { 'pattern': '\m\C^[\t ]*module[\t ]\+\S\+',
                    \   'formatter': [] }]
                    \ )
    endif

    if get(g:, 'funky_ruby_access', 1)
        call extend(filters, [
                    \ { 'pattern': '\m\C^[\t ]*\(private\|protected\|public\)[\t ]*$',
                    \   'formatter': ['\S\+', '&', ''] }]
                    \ )
    endif

    if get(g:, 'funky_ruby_rspec', 1)
        call extend(filters, [
                    \ { 'pattern': '\m\C^[\t ]*\(describe\|context\|feature\|scenario\|it\)[\t ]\+\S\+',
                    \   'formatter': [] }]
                    \ )
    endif

    if get(g:, 'funky_ruby_rake_words', 1)
        call extend(filters, [
                    \ { 'pattern': '\m\C^[\t ]*task[\t ]\+\S\+',
                    \   'formatter': ['\m\C^[\t ]*', '', ''] }]
                    \ )
    endif

    if get(g:, 'funky_ruby_chef_words', 0)
        call extend(filters, funky#ft#chef#filters())
    endif

    return filters
endfunction

" Tells how to strip clothes
function! funky#ft#ruby#strippers()
    return [ {'pattern': s:pat.method, 'position': 1 } ]
endfunction
