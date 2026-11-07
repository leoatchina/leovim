" ---------------------------------------------------------
" floaterm
" ---------------------------------------------------------
" lazy-load bootstrap keys live in plugin/terminal.vim
let g:floaterm_open_command = 'drop'
let g:floaterm_wintype  = 'split'
let g:floaterm_position = 'belowright'
let g:floaterm_height = 0.3
if utils#is_win()
    let g:floaterm_shell = get(g:, 'floaterm_shell', 'cmd.exe')
elseif executable('zsh') && has('nvim')
    let g:floaterm_shell = get(g:, 'floaterm_shell', 'zsh')
else
    let g:floaterm_shell = get(g:, 'floaterm_shell', 'bash')
endif
" ---------------------------------------------------------
" enhanced functions and commands
" ---------------------------------------------------------
let g:floaterm#parameters = {}
let g:floaterm#parameters.right = " --wintype=vsplit --width=0.382"
let g:floaterm#parameters.belowright = " --wintype=split --height=0.3"
if g:has_popup_floating
    let g:floaterm#parameters.center = " --wintype=float --width=0.618 --height=0.618"
    let g:floaterm#parameters.topright = " --wintype=float --width=0.45 --height=0.618"
    let g:floaterm#parameters.bottomright = " --wintype=float --width=0.45 --height=0.3"
endif
function! floaterm#select_pos()
    let positions = ['Right', 'Belowright', 'Tab', 'Center', 'Topright', 'BottomRight']
    if g:has_popup_floating == 0
        let positions = positions[:2]
    endif
    let title = 'Choose a Terminal Position'
    let pos = tolower(utils#choose_one(positions, title, 0))
    if empty(pos)
        return
    endif
    if pos == 'tab'
        if has('nvim')
            tabnew | terminal
            call feedkeys('i')
        else
            tab terminal
        endif
    else
        let position = " --position=" . pos
        let cmd = "FloatermNew" . g:floaterm#parameters[pos] . position
        execute cmd
    endif
endfunction
command! FloatermOpenPos call floaterm#select_pos()
