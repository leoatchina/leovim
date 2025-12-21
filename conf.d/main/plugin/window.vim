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
nnoremap <silent><M-Q> :call utils#pre_curosr('quit')<Cr>
nnoremap <silent><M-U> :call utils#pre_curosr('ctrlu')<Cr>
nnoremap <silent><M-D> :call utils#pre_curosr('ctrld')<Cr>
nnoremap <silent><M-E> :call utils#pre_curosr('ctrle')<Cr>
nnoremap <silent><M-Y> :call utils#pre_curosr('ctrly')<Cr>
inoremap <silent><M-U> <C-o>:call utils#pre_curosr('ctrlu')<Cr>
inoremap <silent><M-D> <C-o>:call utils#pre_curosr('ctrld')<Cr>
inoremap <silent><M-E> <C-o>:call utils#pre_curosr('ctrle')<Cr>
inoremap <silent><M-Y> <C-o>:call utils#pre_curosr('ctrly')<Cr>
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
nnoremap <silent><Tab>h :call utils#smart_resize('h', 'h')<Cr>
nnoremap <silent><Tab>l :call utils#smart_resize('h', 'l')<Cr>
nnoremap <silent>\a     :call utils#smart_resize('l', 'h')<Cr>
nnoremap <silent>\d     :call utils#smart_resize('l', 'l')<Cr>
nnoremap <silent><Tab>k :call utils#smart_resize('k', 'k')<Cr>
nnoremap <silent><Tab>j :call utils#smart_resize('k', 'j')<Cr>
nnoremap <silent>\w     :call utils#smart_resize('j', 'k')<Cr>
nnoremap <silent>\s     :call utils#smart_resize('j', 'j')<Cr>
" ------------------------
" winbar
" ------------------------
if has('patch-8.0.1129') && !has('nvim')
    function! s:toggle_winbar(open) abort
        if utils#is_ignored() || &ft =~ 'fern'
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
