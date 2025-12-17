setlocal nowrap
setlocal norelativenumber
setlocal foldcolumn=0 colorcolumn= cursorline
" 避免 quickfix 预览触发 E325 交互提示, Buffer-local: only affect this quickfix buffer
autocmd SwapExists <buffer> let v:swapchoice = 'e'
inoremap <silent><buffer><C-c> <ESC>
nnoremap <silent><buffer>q :q!<Cr>
nnoremap <silent><buffer>Q :q!<Cr>
nnoremap <silent><buffer>J <Nop>
nnoremap <silent><buffer>K <Nop>
nnoremap <silent><buffer>p <Nop>
nnoremap <silent><buffer>P <Nop>
nnoremap <silent><buffer><C-h> <Nop>
nnoremap <silent><buffer><M-c> <Nop>
nnoremap <silent><buffer><M-C> <Nop>
nnoremap <silent><buffer><M-.> <Nop>
nnoremap <silent><buffer><M-/> <Nop>
nnoremap <silent><buffer><M-?> <Nop>
nnoremap <silent><buffer><M-'> <Nop>
nnoremap <silent><buffer><M-"> <Nop>
if !pack#installed('nvim-bqf')
    nnoremap <silent><buffer>P :PreviewQuickfix<Cr>
    nnoremap <silent><buffer><C-m> :PreviewQuickfix e<Cr>
    nnoremap <silent><buffer><C-g> :PreviewQuickfix e<Cr>:QuickfixClose<Cr>
    nnoremap <silent><buffer><C-]> :PreviewQuickfix vsplit<Cr>
    nnoremap <silent><buffer><C-x> :PreviewQuickfix split<Cr>
    nnoremap <silent><buffer><C-t> :PreviewQuickfix tabe<Cr>
    if pack#installed('vim-quickui')
        nnoremap <silent><buffer>K :call quickui#tools#preview_quickfix()<Cr>
        nnoremap <silent><buffer>n j:call quickui#tools#preview_quickfix()<Cr>
        nnoremap <silent><buffer>p k:call quickui#tools#preview_quickfix()<Cr>
    endif
endif
