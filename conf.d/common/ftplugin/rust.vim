setlocal commentstring=//\ %s
if utils#is_installed('rust.vim')
    command! RustCommands call FzfCallCommands('RustCommands', 'RustLsp', 'Rust')
    nnoremap <buffer><silent><M-M> :RustCommands<Cr>
endif
if utils#is_installed_coc()
    nnoremap <buffer>q<Cr> :CocCommand rust-analyzer.
endif
inoremap <buffer>!! !=
inoremap <buffer><< <-
inoremap <buffer>>> ->
inoremap <buffer>?? =>
