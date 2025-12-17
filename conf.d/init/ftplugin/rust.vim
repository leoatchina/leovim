setlocal commentstring=//\ %s
if plug#installed('rust.vim')
    command! RustCommands call FzfCallCommands('RustCommands', 'RustLsp', 'Rust')
    nnoremap <buffer><silent><M-M> :RustCommands<Cr>
endif
if plug#installed_coc()
    nnoremap <buffer>q<Cr> :CocCommand rust-analyzer.
endif
inoremap <buffer>!! !=
inoremap <buffer><< <-
inoremap <buffer>>> ->
inoremap <buffer>?? =>
