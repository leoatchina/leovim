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
command! FloatermSpecial call s:floaterm_select_pos()
function! s:floaterm_list() abort
    let bufs = floaterm#buflist#gather()
    let cnt = len(bufs)
    if cnt == 0
        let no_msg = "No floaterm windows"
        if pack#installed('vim-quickui')
            call quickui#textbox#open([no_msg], {})
        else
            call preview#errmsg(no_msg)
        endif
        return
    endif
    let content = []
    for bufnr in bufs
        let title = getbufvar(bufnr, 'floaterm_title')
        if title ==# "floaterm($1/$2)"
            let cur = index(bufs, bufnr) + 1
            let title = substitute(title, '$1', cur, 'gm')
            let title = substitute(title, '$2', cnt, 'gm')
        endif
        let postion = getbufvar(bufnr, 'floaterm_position')
        let wintype = getbufvar(bufnr, 'floaterm_wintype')
        let cmd     = getbufvar(bufnr, 'floaterm_cmd')
        let open_cmd = printf('call floaterm#terminal#open_existing(%s)', bufnr)
        if pack#installed('vim-quickui')
            let title = title . "@" . wintype . '/' .  postion . ' ' .  cmd
            let line = [title, open_cmd]
        else
            let title = title . "@" . wintype . '/' .  postion
            let line = {}
            let line.bufnr = bufnr
            let line.text = title
            let line.pattern = open_cmd
        endif
        call add(content, line)
    endfor
    if pack#installed('vim-quickui')
        let opts = {'title': 'All floaterm buffers', 'w': 64}
        call quickui#listbox#open(content, opts)
    else
        call setqflist(content)
        execute "belowright copen" . g:asyncrun_open
    endif
endfunc
command! FloatermList call s:floaterm_list()
