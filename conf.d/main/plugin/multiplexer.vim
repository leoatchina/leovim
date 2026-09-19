" Skip in VSCode environment
if utils#is_vscode()
    finish
endif
if pack#installed('vim-tmux-navigator')
    let g:tmux_navigator_no_mappings = 1
    nnoremap <silent><M-H> :TmuxNavigateLeft<cr>
    nnoremap <silent><M-J> :TmuxNavigateDown<cr>
    nnoremap <silent><M-K> :TmuxNavigateUp<cr>
    nnoremap <silent><M-L> :TmuxNavigateRight<cr>
    inoremap <silent><M-H> <C-o>:TmuxNavigateLeft<cr>
    inoremap <silent><M-J> <C-o>:TmuxNavigateDown<cr>
    inoremap <silent><M-K> <C-o>:TmuxNavigateUp<cr>
    inoremap <silent><M-L> <C-o>:TmuxNavigateRight<cr>
    if g:has_terminal
        tnoremap <silent><M-H> <C-\><C-n>:TmuxNavigateLeft<cr>
        tnoremap <silent><M-J> <C-\><C-n>:TmuxNavigateDown<cr>
        tnoremap <silent><M-K> <C-\><C-n>:TmuxNavigateUp<cr>
        tnoremap <silent><M-L> <C-\><C-n>:TmuxNavigateRight<cr>
        tnoremap <silent><C-w><C-w> <C-\><C-n>:TmuxNavigatePrevious<cr>
    endif
elseif pack#installed('vim-herdr-navigation')
    function! s:HerdrFocus(dir) abort
        let l:herdr = empty($HERDR_BIN_PATH) ? 'herdr' : $HERDR_BIN_PATH
        call system(shellescape(l:herdr) . ' pane focus --direction ' . a:dir . ' --current')
    endfunction
    function! multiplexer#Navigate(wincmd, dir) abort
        let l:prev = winnr()
        execute 'noautocmd silent! wincmd ' . a:wincmd
        sleep 100m
        if winnr() == l:prev
            " No Vim window that way: cross into the herdr pane.
            call s:HerdrFocus(a:dir)
        endif
    endfunction
    command! MultiplexerNavigateLeft call multiplexer#Navigate('h', 'left')
    command! MultiplexerNavigateDown call multiplexer#Navigate('j', 'down')
    command! MultiplexerNavigateUp call multiplexer#Navigate('k', 'up')
    command! MultiplexerNavigateRight call multiplexer#Navigate('l', 'right')
    nnoremap <silent><M-H> :MultiplexerNavigateLeft<cr>
    nnoremap <silent><M-J> :MultiplexerNavigateDown<cr>
    nnoremap <silent><M-K> :MultiplexerNavigateUp<cr>
    nnoremap <silent><M-L> :MultiplexerNavigateRight<cr>
    inoremap <silent><M-H> <C-o>:MultiplexerNavigateLeft<cr>
    inoremap <silent><M-J> <C-o>:MultiplexerNavigateDown<cr>
    inoremap <silent><M-K> <C-o>:MultiplexerNavigateUp<cr>
    inoremap <silent><M-L> <C-o>:MultiplexerNavigateRight<cr>
    if g:has_terminal
        tnoremap <silent><M-H> <C-\><C-n>:MultiplexerNavigateLeft<cr>
        tnoremap <silent><M-J> <C-\><C-n>:MultiplexerNavigateDown<cr>
        tnoremap <silent><M-K> <C-\><C-n>:MultiplexerNavigateUp<cr>
        tnoremap <silent><M-L> <C-\><C-n>:MultiplexerNavigateRight<cr>
        tnoremap <C-w><C-w> <C-\><C-n><C-w><C-w>
    endif
else
    nnoremap <M-H> <C-w><C-h>
    nnoremap <M-J> <C-w><C-j>
    nnoremap <M-K> <C-w><C-k>
    nnoremap <M-L> <C-w><C-l>
    inoremap <M-H> <C-o><C-w><C-h>
    inoremap <M-J> <C-o><C-w><C-j>
    inoremap <M-K> <C-o><C-w><C-k>
    inoremap <M-L> <C-o><C-w><C-l>
    if g:has_terminal
        tnoremap <M-H> <C-\><C-n><C-w><C-h>
        tnoremap <M-J> <C-\><C-n><C-w><C-j>
        tnoremap <M-K> <C-\><C-n><C-w><C-k>
        tnoremap <M-L> <C-\><C-n><C-w><C-l>
        tnoremap <C-w><C-h> <C-\><C-n><C-w><C-h>
        tnoremap <C-w><C-j> <C-\><C-n><C-w><C-j>
        tnoremap <C-w><C-k> <C-\><C-n><C-w><C-k>
        tnoremap <C-w><C-l> <C-\><C-n><C-w><C-l>
        tnoremap <C-w><C-w> <C-\><C-n><C-w><C-w>
    endif
endif

