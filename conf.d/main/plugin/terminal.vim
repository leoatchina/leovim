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
else
    nnoremap <silent><M-h>D :tab terminal<CR>cd ~/.leovim.d<tab><CR>
endif
tnoremap <silent><C-v> <C-\><C-n>
tnoremap <silent><M-q> <C-\><C-n>:ConfirmQuit<Cr>
tnoremap <silent><M-w> <C-\><C-n>:tabclose<Cr>
tnoremap <silent><M-W> <C-\><C-n>:tabonly<Cr>i
" ---------------------------------------------------------
" floaterm: settings in cfg/floaterm.vim, bootstrap keys here
" ---------------------------------------------------------
command! FloatermCommands call FzfCallCommands('FloatermCommands', 'Floaterm')
nnoremap <silent>\f: :FloatermCommands<Cr>
" ------------------------------
" find key for floaterm
" ------------------------------
function! s:bind_keymap(mapvar, command) abort
    if !utils#has_map(a:mapvar, 'n')
        execute printf('nnoremap <silent>%s :%s<CR>', a:mapvar, a:command)
    endif
    execute printf('inoremap <silent>%s <C-o>:%s<CR>', a:mapvar, a:command)
    execute printf('tnoremap <silent>%s <C-\><C-n>:%s<CR>', a:mapvar, a:command)
endfunction
function! s:floaterm_new_list()
    if floaterm#buflist#curr() <= 0
        execute('FloatermNew --cwd=<C-R>=utils#get_dir(expand("%"))<CR>')
    else
        FloatermFzfList
    endif
endfunction
command! TermNewOrFzfList call s:floaterm_new_list()
call s:bind_keymap('<M-->', 'FloatermToggle')
call s:bind_keymap('<M-_>', 'FloatermHide')
call s:bind_keymap('<M-{>', 'FloatermPrev')
call s:bind_keymap('<M-}>', 'FloatermNext')
call s:bind_keymap('<M-+>', 'FloatermOpenPos')
call s:bind_keymap('<M-=>', 'TermNewOrFzfList')
