let s:regs_alpha = map(range(char2nr('a'), char2nr('z')), 'nr2char(v:val)')
if has('clipboard')
    if has('unix')
        let s:regs_special = ['+', '*', '"']
    else
        let s:regs_special = ['*','"']
    endif
else
    let s:regs_special = ['"']
endif

function! fzf#registers#list()
    redir => tmp
    silent registers
    redir END
    let reg_lst = split(tmp, '\n')
    if reg_lst[0][0] ==# '-'
        return reg_lst[1:]
    else
        return map(copy(reg_lst[1:]), 'v:val[6:]')
    endif
endfunction

" NOTE: reg[0] is the name of register
function! fzf#registers#source(...)
    let alpha_only = a:0 && a:1 == 1
    let result = []
    let result_begin = []
    let regs_added = []
    for reg in fzf#registers#list()
        if alpha_only && index(s:regs_alpha, reg[0]) < 0 && index(s:regs_special, reg[0]) < 0
            continue
        endif
        if alpha_only && reg[0] =~ '"'
            call insert(result_begin, reg, 0)
        elseif reg[0] =~ '*' || reg[0] =~ '+'
            if alpha_only
                call insert(result_begin, reg, 0)
            else
                call insert(result, reg, 0)
            endif
        else
            call add(result, reg)
            if alpha_only
                call add(regs_added, reg[0])
            endif
        endif
    endfor
    if alpha_only
        return result_begin + filter(copy(s:regs_special), 'index(map(copy(result_begin), "v:val[0]"), v:val) < 0') + filter(copy(s:regs_alpha), 'index(copy(regs_added), v:val) < 0') + result
    else
        return result
    endif
endfunction

function! fzf#registers#paste(select) dict
    let reg = a:select[0]
    if self.visual
        let cmd = 'gv"' . reg . self.paste
    else
        let cmd = '"' . reg . self.paste
    endif
    call feedkeys(cmd)
endfunction

let s:action_a_letters = ['{', '[', '(', '<', 'S', 'A']
function! fzf#registers#yank(select) dict
    let reg = a:select[0]
    if self.visual > 0
        let cmd = 'gv"' . reg . 'y'
    else
        let action = self.action
        if len(action) == 1
            if index(s:action_a_letters, action) >= 0
                let action = 'ya' . action
            else
                let action = 'yi' . action
            endif
        endif
        let cmd = '"' . reg . action
    endif
    call feedkeys(cmd)
endfunction
