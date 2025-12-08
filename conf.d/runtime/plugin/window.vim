" Skip in VSCode environment
if utils#is_vscode()
    finish
endif
" open in vsplit/split
nnoremap <Tab>] :vsplit<Space>
nnoremap <Tab>[ :split<Space>
" ------------------------
" Previous Window Control
" ------------------------
function! PreviousCursor(mode)
    if winnr('$') <= 1
        return
    endif
    noautocmd silent! wincmd p
    if a:mode == 'quit'
        if &buftype ==# 'terminal' || &buftype ==# 'prompt'
            quit!
        else
            exec "normal! \<C-w>q"
        endif
    elseif a:mode == 'ctrlo'
        exec "normal! \<C-o>"
    elseif a:mode == 'ctrlu'
        exec "normal! \<C-u>"
    elseif a:mode == 'ctrld'
        exec "normal! \<C-d>"
    elseif a:mode == 'ctrle'
        exec "normal! \<C-e>"
    elseif a:mode == 'ctrly'
        exec "normal! \<C-y>"
    elseif a:mode == 'ctrlm'
        exec "normal! \<C-m>"
    elseif a:mode == 'ctrlh'
        exec "normal! \<C-h>"
    elseif a:mode == 'ctrlj'
        exec "normal! \<C-j>"
    elseif a:mode == 'ctrlk'
        exec "normal! \<C-k>"
    elseif a:mode == 'ctrll'
        exec "normal! \<C-l>"
    endif
    noautocmd silent! wincmd p
endfunction
nnoremap <silent><M-Q> :call PreviousCursor('quit')<Cr>
nnoremap <silent><M-U> :call PreviousCursor('ctrlu')<Cr>
nnoremap <silent><M-D> :call PreviousCursor('ctrld')<Cr>
nnoremap <silent><M-E> :call PreviousCursor('ctrle')<Cr>
nnoremap <silent><M-Y> :call PreviousCursor('ctrly')<Cr>
inoremap <silent><M-U> <C-o>:call PreviousCursor('ctrlu')<Cr>
inoremap <silent><M-D> <C-o>:call PreviousCursor('ctrld')<Cr>
inoremap <silent><M-E> <C-o>:call PreviousCursor('ctrle')<Cr>
inoremap <silent><M-Y> <C-o>:call PreviousCursor('ctrly')<Cr>
" -----------------------------------
" Adjust window panel smartly
" -----------------------------------
let g:adjust_size = get(g:, 'adjust_size', 4)
nnoremap <C-w><Right> <C-w>5>
nnoremap <C-w><Left>  <C-w>5<
nnoremap <C-w><Up>    <C-w>5+
nnoremap <C-w><Down>  <C-w>5-
function! s:winnr(direction)
    let c_winnr = winnr()
    try
        let d_winnr = winnr(a:direction)
    catch
        execute "noautocmd silent! wincmd " . a:direction
        let d_winnr = winnr()
        noautocmd silent! wincmd p
    endtry
    if c_winnr == d_winnr
        return 0
    else
        return d_winnr
    endif
endfunction
function! SmartResize(line, move) abort
    let line = a:line
    let move = a:move
    let h_winnr = s:winnr('h')
    let l_winnr = s:winnr('l')
    let k_winnr = s:winnr('k')
    let j_winnr = s:winnr('j')
    let cmd = ''
    " adjust left most vsplit line
    if line == 'h'
        if move == 'h'
            if h_winnr
                let cmd = printf('vertical %sresize -%d', h_winnr, g:adjust_size)
            elseif l_winnr
                let cmd = printf('vertical resize -%d', g:adjust_size)
            endif
        elseif move == 'l'
            if h_winnr
                let cmd = printf('vertical %sresize +%d', h_winnr, g:adjust_size)
            elseif l_winnr
                let cmd = printf('vertical resize +%d', g:adjust_size)
            endif
        endif
    " adjust right most vsplit line
    elseif line == 'l'
        if move == 'l'
            if l_winnr
                let cmd = printf('vertical resize +%d', g:adjust_size)
            elseif h_winnr
                let cmd = printf('vertical resize -%d', g:adjust_size)
            endif
        elseif move == 'h'
            if l_winnr
                let cmd = printf('vertical resize -%d', g:adjust_size)
            elseif h_winnr
                let cmd = printf('vertical resize +%d', g:adjust_size)
            endif
        endif
    " adjust up most split line
    elseif line == 'k'
        if move == 'k'
            if k_winnr
                let cmd = printf('%sresize -%d', k_winnr, g:adjust_size)
            elseif j_winnr
                let cmd = printf('resize -%d', g:adjust_size)
            endif
        elseif move == 'j'
            if k_winnr
                let cmd = printf('%sresize +%d', k_winnr, g:adjust_size)
            elseif j_winnr
                let cmd = printf('resize +%d', g:adjust_size)
            endif
        endif
    " adjust down most split line
    elseif line == 'j'
        if move == 'j'
            if j_winnr
                let cmd = printf('resize +%d', g:adjust_size)
            elseif k_winnr
                let cmd = printf('resize -%d', g:adjust_size)
            endif
        elseif move == 'k'
            if j_winnr
                let cmd = printf('resize -%d', g:adjust_size)
            elseif k_winnr
                let cmd = printf('resize +%d', g:adjust_size)
            endif
        endif
    endif
    if empty('cmd')
        return
    else
        noautocmd silent! execute cmd
    endif
endfunction
nnoremap <silent><Tab>h :call SmartResize('h', 'h')<Cr>
nnoremap <silent><Tab>l :call SmartResize('h', 'l')<Cr>
nnoremap <silent>\a     :call SmartResize('l', 'h')<Cr>
nnoremap <silent>\d     :call SmartResize('l', 'l')<Cr>
nnoremap <silent><Tab>k :call SmartResize('k', 'k')<Cr>
nnoremap <silent><Tab>j :call SmartResize('k', 'j')<Cr>
nnoremap <silent>\w     :call SmartResize('j', 'k')<Cr>
nnoremap <silent>\s     :call SmartResize('j', 'j')<Cr>
" ------------------------
" winbar
" ------------------------
if has('patch-8.0.1129') && !has('nvim')
    function! s:toggle_winbar(open) abort
        if utils#is_ftbt_ignored() || &ft =~ 'fern'
            return
        else
            let fname = utils#expand("%:t", 1)
            let ename = utils#escape(fname)
            if a:open
                if index(getcompletion('WinBar.', 'menu'), ename) < 0
                    execute "nnoremenu 1.00 WinBar." .  ename . ' :echo '. fname
                endif
            else
                if index(getcompletion('WinBar.', 'menu'), ename) >= 0
                    execute 'unmenu WinBar.' . ename
                endif
            endif
        endif
    endfunction
    command! OpenWinBar call s:toggle_winbar(1)
    command! CloseWinBar call s:toggle_winbar(0)
    augroup WindowBarGroup
        autocmd!
        autocmd WinNew,WinEnter,TabNew,TabEnter,BufReadPost * OpenWinBar
        autocmd WinClosed,WinLeave,TabClosed,TabLeave,BufLeave * CloseWinBar
    augroup END
elseif has('nvim') && pack#installed_coc()
    lua require('cfg/coc_symboline')
endif
