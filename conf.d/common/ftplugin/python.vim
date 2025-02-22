setlocal commentstring=#\ %s
au BufWritePre <buffer> :%retab
if Installed('vim-quickui')
    au BufNew,BufEnter,BufNewFile,BufRead * nnoremap gx :call quickui#tools#python_help("")<Cr>
endif
inoremap <buffer>>> ->
inoremap <buffer><M-e> # %%
inoremap <buffer><M-d> # STEP
inoremap <buffer><M-m> # In[]<Left>
