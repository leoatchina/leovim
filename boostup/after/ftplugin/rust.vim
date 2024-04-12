setlocal commentstring=//\ %s
if Installed('rust.vim')
    command! RustCommands call FzfCallCommands('RustCommands', 'Rust')
    nnoremap <buffer><silent><M-M> :RustCommands<Cr>
endif
if InstalledCoc()
    nnoremap <buffer>\<Space> :CocCommand rust-analyzer.
endif
inoremap <buffer>!! !=
inoremap <buffer><< <-
inoremap <buffer>>> ->
inoremap <buffer>?? =>
