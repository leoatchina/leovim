" Skip in VSCode environment
if utils#is_vscode()
    finish
endif
if pack#planned('vim-tmux-navigator')
    let g:tmux_navigator_no_mappings = 1
    nnoremap <silent><M-H> :TmuxNavigateLeft<cr>
    nnoremap <silent><M-L> :TmuxNavigateRight<cr>
    nnoremap <silent><M-J> :TmuxNavigateDown<cr>
    nnoremap <silent><M-K> :TmuxNavigateUp<cr>
    inoremap <silent><M-H> <C-o>:TmuxNavigateLeft<cr>
    inoremap <silent><M-L> <C-o>:TmuxNavigateRight<cr>
    inoremap <silent><M-J> <C-o>:TmuxNavigateDown<cr>
    inoremap <silent><M-K> <C-o>:TmuxNavigateUp<cr>
    if g:has_terminal
        tnoremap <silent><M-H> <C-\><C-n>:TmuxNavigateLeft<cr>
        tnoremap <silent><M-L> <C-\><C-n>:TmuxNavigateRight<cr>
        tnoremap <silent><M-J> <C-\><C-n>:TmuxNavigateDown<cr>
        tnoremap <silent><M-K> <C-\><C-n>:TmuxNavigateUp<cr>
        tnoremap <silent><C-w><C-w> <C-\><C-n>:TmuxNavigatePrevious<cr>
    endif
else
    nnoremap <M-H> <C-w><C-h>
    nnoremap <M-L> <C-w><C-l>
    nnoremap <M-J> <C-w><C-j>
    nnoremap <M-K> <C-w><C-k>
    inoremap <M-H> <C-o><C-w><C-h>
    inoremap <M-L> <C-o><C-w><C-l>
    inoremap <M-J> <C-o><C-w><C-j>
    inoremap <M-K> <C-o><C-w><C-k>
    if g:has_terminal
        tnoremap <M-H> <C-\><C-n><C-w><C-h>
        tnoremap <M-L> <C-\><C-n><C-w><C-l>
        tnoremap <M-J> <C-\><C-n><C-w><C-j>
        tnoremap <M-K> <C-\><C-n><C-w><C-k>
        tnoremap <C-w><C-w> <C-\><C-n><C-w><C-w>
    endif
endif

