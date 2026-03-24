" Language: Zig
" Author: Takahiro Yoshihara <tacahiroy@gmail.com>
" License: The MIT License

function! funky#ft#zig#filters()
  let filters = [
        \ { 'pattern': '\v^[\t ]*(pub[\t ]+)?fn[\t ]+',
        \   'formatter': []
        \ }
  \ ]
  return filters
endfunction
