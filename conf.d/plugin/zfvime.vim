if !Installed('ZFVimIM')
    finish
endif
let g:ZFVimIM_cachePath=$HOME.'/.vim/ZFVimIM'
let g:ZFVimIM_key_pageUp = ['-']
let g:ZFVimIM_key_pageDown = ['=']
let g:ZFVimIM_key_chooseL = ['[']
let g:ZFVimIM_key_chooseR = [']']
augroup ZFVIM
    autocmd!
    autocmd FileType * if ZFVimIME_started() | setlocal omnifunc= | endif
augroup END
" ----------------------------
" input method loop
" ----------------------------
function! s:show_input()
    let ime_name = ZFVimIME_IMEName()
    if ime_name == ''
        let ime_name = 'english'
    elseif ime_name == 'pinyin'
        let ime_name = '拼音'
    elseif ime_name == 'wubi'
        let ime_name = '五笔'
    endif
    if empty(get(g:, 'ZFVimIM_symbolMap', {}))
        let punctuation = '[Eng] punctuation'
    else
        let punctuation = '【中文】标点'
    endif
    let msg = printf('%s with %s', ime_name, punctuation)
    call preview#cmdmsg(msg, 1)
endfunction
function! ZFVimIMELoop(type)
    if Installed('ZFVimIM_wubi_base') && a:type
        if ZFVimIME_IMEName() == 'wubi'
            call ZFVimIME_keymap_next_n()
        elseif ZFVimIME_IMEName() == 'pinyin'
            call ZFVimIME_keymap_next_n()
            call ZFVimIME_keymap_toggle_n()
        else
            call ZFVimIME_keymap_toggle_n()
        endif
    else
        call ZFVimIME_keymap_toggle_n()
    endif
    let ime_name = ZFVimIME_IMEName()
    if ime_name == ''
        let ime_name = 'english'
    endif
    call s:show_input()
endfunction
function! ZFVimPunctuation()
    if !exists('g:ZFVimIM_symbolMap') || empty(g:ZFVimIM_symbolMap)
        let g:ZFVimIM_symbolMap = {
                    \  '`' : ['·'],
                    \  '!' : ['！'],
                    \  '$' : ['￥'],
                    \  '^' : ['……'],
                    \  '_' : ['——'],
                    \  '(' : ['（'],
                    \  ')' : ['）'],
                    \  '[' : ['【'],
                    \  ']' : ['】'],
                    \  '<' : ['《'],
                    \  '>' : ['》'],
                    \  '\' : ['、'],
                    \  '/' : ['、'],
                    \  ';' : ['；'],
                    \  ':' : ['：'],
                    \  ',' : ['，'],
                    \  '.' : ['。'],
                    \  '?' : ['？'],
                    \  "'" : ['‘', '’'],
                    \  '"' : ['“', '”'],
                    \  ' ' : [''],
                    \  '-' : [''],
                    \  '0' : [''],
                    \  '1' : [''],
                    \  '2' : [''],
                    \  '3' : [''],
                    \  '4' : [''],
                    \  '5' : [''],
                    \  '6' : [''],
                    \  '7' : [''],
                    \  '8' : [''],
                    \  '9' : [''],
                    \ }
    else
        let g:ZFVimIM_symbolMap = {}
    endif
    call s:show_input()
endfunction
let g:ZFVimIM_keymap = 0
inoremap <expr><silent> ;; ZFVimIME_keymap_toggle_i()
nnoremap <silent><M-z> :call ZFVimIMELoop(1)<Cr>
inoremap <silent><M-z> <C-o>:call ZFVimIMELoop(1)<Cr>
nnoremap <silent><M-Z> :call ZFVimPunctuation()<Cr>
inoremap <silent><M-Z> <C-o>:call ZFVimPunctuation()<Cr>
" ----------------------------
" dbinit
" ----------------------------
if Require('wubi')
    function! s:myLocalDb()
        let wubi = ZFVimIM_dbInit(
                    \ {
                        \ 'name':'wubi',
                        \ 'priority':1
                        \ }
                        \ )
        let pinyin = ZFVimIM_dbInit(
                    \ {
                        \ 'name':'pinyin',
                        \ 'priority':2
                        \ }
                        \ )
    endfunction
    autocmd User ZFVimIM_event_OnDbInit call s:myLocalDb()
endif
" ----------------------------
" input in commandline
" ----------------------------
function! ZF_Setting_cmdEdit()
    let cmdtype = getcmdtype()
    if cmdtype != ':' && cmdtype != '/'
        return ''
    endif
    call feedkeys("\<c-c>q" . cmdtype . 'k0' . (getcmdpos() - 1) . 'li', 'nt')
    return ''
endfunction
cnoremap <silent><expr> :: ZF_Setting_cmdEdit()
" ----------------------------
" input in terminal
" ----------------------------
if has('terminal') || has('nvim')
    function! PassToTerm(text)
        let @t = a:text
        if has('nvim')
            call feedkeys('"tpa', 'nt')
        else
            call feedkeys("a\<c-w>\"t", 'nt')
        endif
        redraw!
    endfunction
    command! -nargs=* PassToTerm :call PassToTerm(<q-args>)
    tnoremap :: <c-\><c-n>q:a:PassToTerm<space>
endif
