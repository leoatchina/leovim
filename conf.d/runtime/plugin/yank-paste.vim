" ------------------------------------
" M-x/BS
" ------------------------------------
nnoremap <M-x> x
xnoremap <M-x> x
nnoremap <Del> x
xnoremap <Del> x
nnoremap <M-X> X
xnoremap <M-X> X
inoremap <M-X> <BS>
cnoremap <M-X> <BS>
cnoremap <C-y> <C-r>"
nnoremap <S-Insert> P
xnoremap <S-Insert> P
cnoremap <S-insert> <C-r>"
inoremap <S-Insert> <C-r>"
inoremap <M-x> <Del>
cnoremap <M-x> <Del>
" switch 2 words
xnoremap X <Esc>`.``gvp``P
" ------------------------------------
" registers plugins with fzf
" ------------------------------------
cnoremap <M-v> <C-r>"
inoremap <M-v> <C-r>"
if g:has_terminal == 1
    tnoremap <M-v> <C-\><C-n>""pa
elseif g:has_terminal == 2
    tnoremap <M-v> <C-_>""
endif
if utils#is_planned_fzf()
    PlugOpt 'fzf-registers'
    nnoremap <silent><M-v> :FzfRegisterPaste<Cr>
    inoremap <silent><M-v> <C-o>:FzfRegisterPaste<Cr>
    xnoremap <silent><M-v> :<C-u>FzfRegisterPasteV<Cr>
    xnoremap <silent><M-y> :<C-u>FzfRegisterYankV<Cr>
    for letter in ['{', '}', '[', ']', '(', ')', '<', '>', '"', "'", '.', 's', 'S', 'a', 'A', 'l', 'n', 't', 'w', 'u', 'v', 'b', 'c', 'k']
        execute printf("nnoremap <silent><M-y>%s :FzfRegisterYank %s<Cr>", letter, letter)
        execute printf("inoremap <silent><M-y>%s <C-o>:FzfRegisterYank %s<Cr>", letter, letter)
    endfor
else
    nnoremap <silent><M-v> :registers<Cr>
endif
" ------------------------
" paste
" ------------------------
nnoremap \pw viwp
for i in range(4)
    execute printf('nnoremap \p%s viw"%sp', i , i)
    execute printf('xnoremap \p%s "%sp', i , i)
endfor
nnoremap \p` viw"0p
xnoremap \p` "0p
" ------------------------
" pastemode toggle
" ------------------------
inoremap <C-x><C-i> <C-\><C-o>:set paste<Cr>
onoremap <C-w><C-i> :set paste<CR>
nnoremap <C-w><C-i> :set paste<Cr>
xnoremap <C-w><C-i> :set paste<Cr>
augroup AutoPasteMode
    autocmd!
    autocmd InsertLeave,CmdlineLeave * set nopaste
augroup END
" -------------------------------
" clipboard from remote to local
" -------------------------------
if exists("##TextYankPost") && utils#is_unix()
    function! s:raw_echo(str)
        if filewritable('/dev/fd/2') && !utils#has_gui()
            call writefile([a:str], '/dev/fd/2', 'b')
        else
            call system("!echo " . shellescape(a:str))
            redraw!
        endif
    endfunction
    function! s:copy() abort
        let c = join(v:event.regcontents,"\n")
        if len(utils#trim(c)) == 0
            return
        endif
        let c64 = system("base64", c)
        if $TMUX == ''
            let s = "\e]52;c;" . utils#trim(c64) . "\x07"
        else
            let s = "\ePtmux;\e\e]52;c;" . utils#trim(c64) . "\x07\e\\"
        endif
        call s:raw_echo(s)
    endfunction
    autocmd TextYankPost * call s:copy()
endif
