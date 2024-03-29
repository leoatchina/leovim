" Language: Groovy
" Author: leoatchina <leoatchina@gmail.com>
" License: The MIT License

function! funky#ft#groovy#filters()
    let p = '\m\C^[\t ]*'
    let p .= '\('
    let p .= 'def[\t ]\+\w\+([^)]*)[\t ]*\n*{'
    let p .= '\|'
    let p .= 'stage[\t ]*([^)]*)'
    let p .= '\)'

    let filters = [
                \ { 'pattern': p,
                \   'formatter': ['^[\t ]*', '', ''] }
                \ ]
    return filters
endfunction
