let s:alphabet_list = [0] + map(range(char2nr('a'), char2nr('z')), 'nr2char(v:val)')
if has('clipboard')
    let s:alphabet_list = ["*"] + s:alphabet_list
endif
function! fzf#registers#source(...)
    let alpha = a:0 && a:1 > 0
    let alpha_regs = []
    if exists('*execute')
        let reg_lst = split(execute('registers'), '\n')
    else
        redir => reg
        silent registers
        redir END
        let reg_lst = split(reg, '\n')
    endif
    let lst = []
    for reg in reg_lst[1:]
        if reg_lst[0][0] !=# '-'
            let reg = reg[6:]
        endif
        if alpha && index(s:alphabet_list, reg[0]) < 0
            continue
        endif
        if reg[0] =~ '+'
            call insert(lst, reg, 0)
        elseif reg[0] =~ '*'
            call insert(lst, reg, 0)
        else
            call add(lst, reg)
            if alpha
                call add(alpha_regs, reg[0])
            endif
        endif
    endfor
    if alpha
        return filter(copy(s:alphabet_list), 'index(alpha_regs, v:val) < 0') + lst
    else
        return lst
    endif
endfunction

" NOTE: select[0] is the name of register
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
" NOTE: select[0] is the name of register
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
