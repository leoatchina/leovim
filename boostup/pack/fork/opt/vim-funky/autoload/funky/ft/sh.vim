" Language: shell script (sh)
" Author: Takahiro Yoshihara
" License: The MIT License

function! s:is_valid_sh_type(shtype)
    " shtype is not a kinda shell
    if exists('*funky#ft#' . a:shtype . '#is_kinda_sh')
        return funky#ft#{a:shtype}#is_kinda_sh()
    else
        return 0
    endif
endfunction

function! funky#ft#sh#filters()
    let shtype = get(g:, 'funky_sh_type', 'bash')

    " note: like this code is very slow: runtime! fzf/funky/{shtype}.vim
    execute 'runtime! fzf/funky/' . shtype . '.vim'

    " shtype is not kind of a shell
    if !s:is_valid_sh_type(shtype)
        let shtype = 'bash'
    endif

    if exists('*funky#ft#' . shtype . '#filters')
        return funky#ft#{shtype}#filters()
    else
        return funky#ft#bash#filters()
    endif
endfunction
