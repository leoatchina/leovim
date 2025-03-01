" --------------------------
" autoclose_ft_buf
" --------------------------
let g:autoclose_ft_buf = [
            \ 'netrw', 'coc-explorer', 'fern', 'nvimtree',
            \ 'qf', 'preview', 'loclist', 'rg', 'outline',
            \ 'vista', 'tagbar', 'vista_kind',
            \ 'leaderf', 'fzf', 'help', 'man', 'startify',
            \ 'gitcommit', 'fugitive', 'fugtiveblame', 'gitcommit',
            \ 'vimspector', 'vimspectorprompt',
            \ 'terminal', 'floaterm', 'popup',
            \ 'dropbar', 'dropbar_preview',
            \ ]
function! s:autoclose(...) abort
    let ft = tolower(getbufvar(winbufnr(winnr()), '&ft'))
    let bt = tolower(getbufvar(winbufnr(winnr()), '&bt'))
    if winnr("$") <= 1 && a:0 && a:1
        return index(g:autoclose_ft_buf, ft) >= 0 || index(g:autoclose_ft_buf, bt) >= 0
    elseif !a:0 || a:1 == 0
        return ft == '' || index(g:autoclose_ft_buf, ft) >= 0 || index(g:autoclose_ft_buf, bt) >= 0
    else
        return 0
    endif
endfunction
function! CheckIgnoreFtBt() abort
    return s:autoclose(0)
endfunction
function! AutoCloseFtBt() abort
    return s:autoclose(1)
endfunction
augroup AutoCloseFtBt
    autocmd!
    autocmd BufWinEnter * if AutoCloseFtBt() | q! | endif
augroup END
" -----------------------------------
" swap exists ignore
" -----------------------------------
autocmd SwapExists * let v:swapchoice = 'o'
" -----------------------------------
" autoread modified file outside (neo)vim
" -----------------------------------
set autoread
autocmd BufRead acwrite set ma
if has('nvim') || !HAS_GUI()
    autocmd FocusGained * :silent! !
endif
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
" helpful
" --------------------------
au FileType vim,lua,help nnoremap <M-M> :HelpfulVersion<Space>
