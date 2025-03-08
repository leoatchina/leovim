" ---------------------------------------
" autoread modified file outside (neo)vim
" ---------------------------------------
set autoread
autocmd BufRead acwrite set ma
if has('nvim') || !HAS_GUI()
    autocmd FocusGained * :silent! !
endif
" -----------------------------------
" swap exists ignore
" -----------------------------------
autocmd SwapExists * let v:swapchoice = 'o'
" --------------------------
" goto last visited line
" --------------------------
autocmd BufReadPost * silent! normal g`"
" --------------------------
" number
" --------------------------
set number
if !exists('g:vscode')
    set relativenumber
    nnoremap <leader>n :set relativenumber! relativenumber? \| set number<Cr>
    nnoremap <leader>N :set norelativenumber \| set nonu! nonu?<Cr>
    augroup numbertoggle
        autocmd!
        autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu | endif
        autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set nornu | endif
        if exists(':tnoremap')
            autocmd CmdlineLeave * if &nu && mode() != "i" | set rnu | endif
            autocmd CmdlineEnter * if &nu | set nornu | endif
        endif
        if has('nvim')
            autocmd TermLeave,TermClose * if &nu && mode() != "i" | set rnu | endif
            autocmd TermEnter,TermOpen  * if &nu | set nornu | endif
        endif
    augroup END
endif
" -----------------------------------
" hightlight todo note
" -----------------------------------
augroup SPECIALSTINGS
    autocmd!
    autocmd Syntax * call matchadd('Todo', '\v\W\zs' . g:todo_patterns . '(\(.{-}\))?:?', -1)
    autocmd Syntax * call matchadd('Todo', '\v\W\zs' . g:note_patterns . '(\(.{-}\))?:?', -2)
augroup END
" -----------------------------------
" not automatical add comments when o/O
" -----------------------------------
augroup NoAddComment
    autocmd!
    autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
augroup END
" --------------------------
" file templates
" --------------------------
autocmd BufNewFile .lintr          0r $CONF_D_DIR/templates/lintr.spec
autocmd BufNewFile .Rprofile       0r $CONF_D_DIR/templates/Rprofile.spec
autocmd BufNewFile .gitconfig      0r $CONF_D_DIR/templates/gitconfig.spec
autocmd BufNewFile .gitignore      0r $CONF_D_DIR/templates/gitignore.spec
autocmd BufNewFile .wildignore     0r $CONF_D_DIR/templates/wildignore.spec
autocmd BufNewFile .radian_profile 0r $CONF_D_DIR/templates/radian_profile.spec
