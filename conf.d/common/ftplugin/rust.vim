setlocal commentstring=//\ %s
if Installed('rust.vim')
    command! RustCommands call FzfCallCommands('RustCommands', 'RustLsp', 'Rust')
    nnoremap <buffer><silent><M-M> :RustCommands<Cr>
endif
if PlannedCoc()
    nnoremap <buffer>q<Cr> :CocCommand rust-analyzer.
endif
inoremap <buffer>!! !=
inoremap <buffer><< <-
inoremap <buffer>>> ->
inoremap <buffer>?? =>
