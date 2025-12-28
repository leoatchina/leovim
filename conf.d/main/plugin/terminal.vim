" Skip in VSCode environment
if utils#is_vscode() || g:has_terminal == 0
    finish
endif
" --------------------------
" basic terminal map
" --------------------------
tmap <expr><C-r> '<C-\><C-n>"'.nr2char(getchar()).'pi'
" --------------------------
" open terminal
" --------------------------
if has('nvim')
    command! TermPackD tabe | call termopen([&shell], {'cwd': utils#expand('~/.leovim.d')})
    nnoremap <silent><M-h>D :TermPackD<Cr>i
    nnoremap <silent>_ :tabnew<Cr>:terminal<Cr>i
else
    nnoremap <silent><M-h>D :tab terminal<CR>cd ~/.leovim.d<tab><CR>
    nnoremap <silent>_ :tab terminal<Cr>
endif
tnoremap <silent><C-v> <C-\><C-n>
tnoremap <silent><M-q> <C-\><C-n>:ConfirmQuit<Cr>
tnoremap <silent><M-w> <C-\><C-n>:tabclose<Cr>
tnoremap <silent><M-W> <C-\><C-n>:tabonly<Cr>i
" ---------------------------------------------------------
" floaterm
" ---------------------------------------------------------
let g:floaterm_open_command = 'drop'
let g:floaterm_wintype  = 'split'
let g:floaterm_position = 'belowright'
let g:floaterm_height = 0.3
if utils#is_win()
    if has('nvim')
        let g:floaterm_shell = 'pwsh.exe'
    else
        let g:floaterm_shell = 'cmd.exe'
    endif
elseif executable('zsh') && has('nvim') && pack#installed_adv()
    let g:floaterm_shell = 'zsh'
endif
command! FloatermCommands call FzfCallCommands('FloatermCommands', 'Floaterm')
nnoremap <silent><Tab>: :FloatermCommands<Cr>
" ---------------------------------------------------------
" enhanced functions and commands
" ---------------------------------------------------------
let s:floaterm_parameters = {}
let s:floaterm_parameters.right = " --wintype=vsplit --width=0.382"
let s:floaterm_parameters.belowright = " --wintype=split --height=0.3"
if g:has_popup_floating
    let s:floaterm_parameters.center = " --wintype=float --width=0.618 --height=0.618"
    let s:floaterm_parameters.topright = " --wintype=float --width=0.45 --height=0.618"
    let s:floaterm_parameters.bottomright = " --wintype=float --width=0.45 --height=0.3"
endif
function! s:floaterm_select_pos()
    let positions = ['Right', 'Belowright', 'Center', 'Topright', 'BottomRight']
    if g:has_popup_floating == 0
        let positions = positions[:1]
    endif
    let title = 'Choose a Floaterm Position'
    let pos = tolower(utils#choose_one(positions, title, 0))
    if empty(pos)
        return
    endif
    let position = " --position=" . pos
    let cmd = "FloatermNew" . s:floaterm_parameters[pos] . position
    execute cmd
endfunction
command! FloatermOpenPos call s:floaterm_select_pos()
" find key for floaterm
function! s:bind_keymap(mapvar, command) abort
    if !utils#has_map(a:mapvar, 'n')
        execute printf('nnoremap <silent>%s :%s<CR>', a:mapvar, a:command)
    endif
    execute printf('inoremap <silent>%s <C-o>:%s<CR>', a:mapvar, a:command)
    execute printf('tnoremap <silent>%s <C-\><C-n>:%s<CR>', a:mapvar, a:command)
endfunction
call s:bind_keymap('<M-->', 'FloatermToggle')
call s:bind_keymap('<M-_>', 'FloatermKill')
call s:bind_keymap('<M-{>', 'FloatermPrev')
call s:bind_keymap('<M-}>', 'FloatermNext')
call s:bind_keymap('<M-+>', 'FloatermOpenPos')
call s:bind_keymap('<M-=>', 'FloatermFzfList')
