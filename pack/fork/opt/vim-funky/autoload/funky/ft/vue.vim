" Language: Vuejs
" Author: timfeirg
" License: The MIT License

function! funky#ft#vue#filters()
    return funky#ft#javascript#filters()
endfunction

function! funky#ft#vue#post_extract_hook(list)
    return funky#ft#javascript#post_extract_hook(a:list)
endfunction
