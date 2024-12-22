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
xnoremap <M-V> <Esc>`.``gvp``P
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
if PlannedFzf()
    PlugAddOpt 'fzf-registers'
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
" Yank a line without leading whitespaces and line break
nnoremap <leader>yu mp_yg_`p
" Copy a line without leading whitespaces and line break to clipboard
nnoremap <leader>yw mp_"*yg_`p
if has('clipboard')
    " Copy file path
    nnoremap <leader>yp :let @*=Expand("%:p")<cr>:echo '-= File path copied=-'<Cr>
    " Copy file name
    nnoremap <leader>yf :let @*=Expand("%:t")<cr>:echo '-= File name copied=-'<Cr>
    " Copy bookmark position reference
    nnoremap <leader>ym :let @*=Expand("%:p").':'.line(".").':'.col(".")<cr>:echo '-= Cursor bookmark copied=-'<cr>'
else
    " Copy file path
    nnoremap <leader>yp :let @"=Expand("%:p")<cr>:echo '-= File path copied=-'<Cr>
    " Copy file name
    nnoremap <leader>yf :let @"=Expand("%:t")<cr>:echo '-= File name copied=-'<Cr>
    " Copy bookmark position reference
    nnoremap <leader>ym :let @"=Expand("%:p").':'.line(".").':'.col(".")<cr>:echo '-= Cursor bookmark copied=-'<cr>'
endif
" ------------------------
" pastemode toggle
" ------------------------
inoremap <M-I> <C-\><C-o>:set nopaste \| echo "nopaste"<Cr>
nnoremap <M-I> :set nopaste! nopaste?<CR>
