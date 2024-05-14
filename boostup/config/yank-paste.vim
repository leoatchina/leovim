" ------------------------
" pastemode toggle
" ------------------------
inoremap <M-I> <C-\><C-o>:set nopaste<Cr>
nnoremap <M-I> :set nopaste! nopaste?<CR>
" ------------------------
" basic yank && paste
" ------------------------
nnoremap Y y$
nnoremap <Tab>y :0,-y<Cr>
nnoremap <Tab>Y vGy
function! YankBorder(...) abort
    if a:0 && a:1 > 0
        let y2end = 1
    else
        let y2end = 0
    endif
    let original_cursor_position = getpos('.')
    if has('clipboard')
        if y2end
            exec('normal! v$"*y')
            echo "Yank to line end to clipboard."
        else
            exec('normal! v^"*y')
            echo "Yank from line beginning to clipboard."
        endif
    else
        if y2end
            exec('normal! v$y')
            echo "Yank to line end."
        else
            exec('normal! v^y')
            echo "Yank from line beginning."
        endif
    endif
    call setpos('.', original_cursor_position)
endfunction
nnoremap <silent>,y :call YankBorder(0)<Cr>
nnoremap <silent>,Y :call YankBorder(1)<Cr>
if has('clipboard')
    if UNIX()
        nnoremap <leader>+ viw"+y
    else
        nnoremap <leader>+ viw"*y
    endif
endif
cnoremap <M-v> <C-r>"
inoremap <M-v> <C-r>"
if g:has_terminal == 1
    tnoremap <M-v> <C-\><C-n>""pa
elseif g:has_terminal == 2
    tnoremap <M-v> <C-_>""
endif
" M-x/BS
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
" del/bs
inoremap <M-x> <Del>
cnoremap <M-x> <Del>
" switch 2 words
xnoremap <M-V> <Esc>`.``gvp``P
" ------------------------------------
" registers plugins with fzf
" ------------------------------------
if InstalledFzf()
    PlugAddOpt 'fzf-registers'
    nnoremap <silent><M-v> :FzfRegisterPaste<Cr>
    inoremap <silent><M-v> <C-o>:FzfRegisterPaste<Cr>
    xnoremap <silent><M-v> :<C-u>FzfRegisterPasteV<Cr>
    xnoremap <silent><M-y> :<C-u>FzfRegisterYankV<Cr>
    for letter in ['{', '}', '[', ']', '(', ')', '<', '>', '"', "'", '.', 's', 'S', 'a', 'A', 'l', 'n', 't', 'w', 'u', 'v', 'b', 'c']
        execute printf("nnoremap <silent><M-y>%s :FzfRegisterYank %s<Cr>", letter, letter)
        execute printf("inoremap <silent><M-y>%s <C-o>:FzfRegisterYank %s<Cr>", letter, letter)
    endfor
else
    nnoremap <silent><M-v> :registers<Cr>
    if has('clipboard')
        nnoremap <M-y> "*y:echo "yanked to clipboard"<C>
        xnoremap <M-y> "*y:echo "yanked to clipboard"<C>
    endif
endif
" ------------------------
" paste
" ------------------------
nnoremap <leader>pw viwp
for i in range(10)
    execute printf('nnoremap <leader>p%s viw"%sp', i , i)
    execute printf('xnoremap <leader>p%s "%sp', i , i)
endfor
" Yank a line without leading whitespaces and line break
nnoremap <leader>yu mp_yg_`p
" Copy a line without leading whitespaces and line break to clipboard
nnoremap <leader>yw mp_"+yg_`P
" Copy file path
nnoremap <leader>yp :let @*=Expand("%:p")<cr>:echo '-= File path copied=-'<Cr>
" Copy file name
nnoremap <leader>yf :let @*=Expand("%:t")<cr>:echo '-= File name copied=-'<Cr>
" Copy bookmark position reference
nnoremap <leader>ym :let @*=Expand("%:p").':'.line(".").':'.col(".")<cr>:echo '-= Cursor bookmark copied=-'<cr>'
