setlocal commentstring=#\ %s
au BufWritePre <buffer> :%retab
if pack#installed('vim-quickui')
    au BufNew,BufEnter,BufNewFile,BufRead * nnoremap gx :call quickui#tools#python_help("")<Cr>
endif
inoremap <buffer> >>    ->
inoremap <buffer> <M-a> # %%
inoremap <buffer> <M-e> # STEP
inoremap <buffer> <M-m> # In[]<Left>
