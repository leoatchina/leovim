" Skip in VSCode environment
if utils#is_vscode()
    finish
endif
" --------------------
" ZFIgnore
" --------------------
PlugOpt 'ZFVimJob'
function! s:ZFIgnore_LeaderF()
    let ignore = ZFIgnoreGet()
    let g:Lf_WildIgnore = {'file' : ignore['file'], 'dir' : ignore['dir']}
endfunction
autocmd User ZFIgnoreOnUpdate call s:ZFIgnore_LeaderF()
autocmd User ZFIgnoreOnUpdate let &wildignore = join(ZFIgnoreToWildignore(ZFIgnoreGet()), ',')
let g:ZFIgnoreOption_ZFDirDiff = {
            \ 'bin' : 0,
            \ 'media' : 0,
            \ 'ZFDirDiff' : 1,
            \ }
let g:ZFIgnore_ignore_gitignore_detectOption = {
            \ 'pattern' : '\.wildignore',
            \ 'path' : '',
            \ 'cur' : 1,
            \ 'parent' : 1,
            \ 'parentRecursive' : 0,
            \ }
PlugOpt 'ZFVimIgnore'
autocmd User ZFIgnoreOnToggle let &wildignore = join(ZFIgnoreToWildignore(ZFIgnoreGet()), ',')
" --------------------
" ZFVimBackup
" --------------------
let g:ZFBackup_autoEnable = 0
nnoremap <M-j><M-s> :ZFBackupSave<Cr>
nnoremap <M-j><M-l> :ZFBackupList<Cr>
nnoremap <M-j><M-d> :ZFBackupListDir<Cr>
nnoremap <M-j><M-m> :ZFBackupRemove<Cr>
nnoremap <M-j><M-r> :ZFBackupRemoveDir<Cr>
function! s:zfbackup_cleanup() abort
    let confirm = ChooseOne(['yes', 'no'], "Cleanup all ZFBackup files?")
    if confirm == 'yes'
        if utils#is_win()
            exec printf('!del %s\*.* /a /f /q', ZFBackup_backupDir())
        else
            exec printf('!rm -rf %s/*.*', ZFBackup_backupDir())
        endif
    endif
endfunction
nnoremap <silent><M-j><M-c> :call <SID>zfbackup_cleanup()<Cr>
function! s:zfbackup_savedir() abort
    let confirm = ChooseOne(['yes', 'no'], "Save current dir using ZFBackup?")
    if confirm == 'yes'
        call preview#cmdmsg("Start to save files under current dir", 1)
        ZFBackupSaveDir
    endif
endfunction
nnoremap <silent><M-j><M-b> :call <SID>zfbackup_savedir()<Cr>
PlugOpt 'ZFVimBackup'
" --------------------
" ZFVimIM
" --------------------
if !pack#installed('ZFVimIM')
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
function! ZFVimIMELoop(...)
    if pack#installed('ZFVimIM_wubi_base') && a:0 && a:1
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
let g:ZFVimIM_keymap = 0
inoremap <expr><silent>;; ZFVimIME_keymap_toggle_i()
inoremap <silent>,, <C-o>:call ZFVimIMELoop(1)<Cr>
nnoremap <silent>;; :call ZFVimIMELoop()<Cr>
nnoremap <silent>,, :call ZFVimIMELoop(1)<Cr>
" -------------------------
" punctuation
" -------------------------
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
nnoremap <silent>;, :call ZFVimPunctuation()<Cr>
nnoremap <silent>,; :call ZFVimPunctuation()<Cr>
inoremap <silent>;, <C-o>:call ZFVimPunctuation()<Cr>
inoremap <silent>,; <C-o>:call ZFVimPunctuation()<Cr>
" ----------------------------
" dbinit
" ----------------------------
if pack#require('wubi')
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
