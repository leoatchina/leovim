setlocal commentstring=//\ %s
if Installed('rust.vim')
    command! RustCommands call FzfCallCommands('RustCommands', 'RustLsp', 'Rust')
    nnoremap <buffer><silent><M-M> :RustCommands<Cr>
endif
if PlannedCoc()
    nnoremap <buffer>\<Space> :CocCommand rust-analyzer.
endif
if Installed('vim-floaterm') && executable('cargo')
    if WINDOWS() || executable('gnome-terminal') && HAS_GUI()
        nnoremap <buffer><M-"> :call SmartRunTerm("time cargo run", "external")<Cr>
    endif
endif
inoremap <buffer>!! !=
inoremap <buffer><< <-
inoremap <buffer>>> ->
inoremap <buffer>?? =>
