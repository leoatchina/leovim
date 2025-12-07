function! textobj#viw() abort
    set iskeyword-=_ iskeyword-=#
    call timer_start(300, {-> execute("set iskeyword+=_  iskeyword+=#")})
    call feedkeys("viwo",'n')
endfunction

function! textobj#current_lina_a() abort
    normal! ^
    let head_pos = getpos('.')
    normal! $
    let tail_pos = getpos('.')
    return ['v', head_pos, tail_pos]
endfunction

function! textobj#current_line_i() abort
    normal! ^
    let head_pos = getpos('.')
    normal! g_
    let tail_pos = getpos('.')
    let non_blank_char_exists_p = getline('.')[head_pos[2] - 1] !~# '\s'
    return
                \ non_blank_char_exists_p
                \ ? ['v', head_pos, tail_pos]
                \ : 0
endfunction

function! textobj#block_a() abort
    let s:block_str = '^# In\[\d*\]\|^# %%\|^# STEP\d\+'
    let beginline = search(s:block_str, 'ebW')
    if beginline == 0
        normal! gg
    endif
    let head_pos = getpos('.')
    let endline  = search(s:block_str, 'eW')
    if endline == 0
        normal! G
    endif
    let tail_pos = getpos('.')
    return ['V', head_pos, tail_pos]
endfunction

function! textobj#block_i() abort
    let s:block_str = '^# In\[\d*\]\|^# %%\|^# STEP\d\+'
    let beginline = search(s:block_str, 'ebW')
    if beginline == 0
        normal! gg
        let beginline = 1
    else
        normal! j
    endif
    let head_pos = getpos('.')
    let endline = search(s:block_str, 'eW')
    if endline == 0
        normal! G
    elseif endline > beginline
        normal! k
    endif
    let tail_pos = getpos('.')
    return ['V', head_pos, tail_pos]
endfunction

