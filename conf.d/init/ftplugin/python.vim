setlocal commentstring=#\ %s
au BufWritePre <buffer> :%retab
if pack#installed('vim-quickui')
    au BufNew,BufEnter,BufNewFile,BufRead * nnoremap gx :call quickui#tools#python_help("")<Cr>
endif
inoremap <buffer> <M-a>  # %%
inoremap <buffer> <Esc>a # %%
inoremap <buffer> <M-e>  # STEP
inoremap <buffer> <Esc>e # STEP
inoremap <buffer> <M-m>  # In[]<Left>
inoremap <buffer> <Esc>m # In[]<Left>
inoremap <buffer> >> ->
