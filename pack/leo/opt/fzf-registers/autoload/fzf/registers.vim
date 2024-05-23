" NOTE: select[0] is the name of register
let s:regs_alpha = map(range(char2nr('a'), char2nr('z')), 'nr2char(v:val)')
let s:regs_special = ['+', '*', '"']
function! fzf#registers#source(...)
    let alpha_only = a:0 && a:1 > 0
    let regs_added = []
    if exists('*execute')
        let reg_lst = split(execute('registers'), '\n')
    else
        redir => tmp
        silent registers
        redir END
        let reg_lst = split(tmp, '\n')
    endif
    let res = []
    let res_header = []
    for reg in reg_lst[1:]
        if reg_lst[0][0] !=# '-'
            let reg = reg[6:]
        endif
        if alpha_only && index(s:regs_alpha, reg[0]) < 0 && index(s:regs_special, reg[0]) < 0
            continue
        endif
        if alpha_only && reg[0] =~ '"'
            call insert(res_header, reg, 0)
        elseif reg[0] =~ '*' || reg[0] =~ '+'
            if alpha_only
                call insert(res_header, reg, 0)
            else
                call insert(res, reg, 0)
            endif
        else
            call add(res, reg)
            if alpha_only
                call add(regs_added, reg[0])
            endif
        endif
    endfor
    if alpha_only
        if has('clipboard')
            let res_header = res_header + filter(copy(s:regs_special), 'index(map(copy(res_header), "v:val[0]"), v:val) < 0')
        endif
        return res_header + filter(copy(s:regs_alpha), 'index(copy(regs_added), v:val) < 0') + res
    else
        return res
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
