" Language: Rust
" Author: Takahiro Yoshihara
" License: The MIT License

function! funky#ft#rust#filters()
    let filters = [
                \ { 'pattern': '\m\Cfn[\t ]\+',
                \   'formatter': [] }
                \ ]
    return filters
endfunction
