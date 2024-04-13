setlocal commentstring=//\ %s
if Installed('vim-go')
    let g:go_doc_balloon = 0
    let g:go_def_mapping_enabled = 0
    let g:go_doc_keywordprg_enabled = !InstalledAdvCompEng()
    command! GoCommands call FzfCallCommands('GoCommands', 'Go')
    nnoremap <buffer><silent>gl :GoCallees<Cr>
    nnoremap <buffer><silent>gh :GoCallers<Cr>
    nnoremap <buffer><silent><C-g> :GoDef<Cr>
    nnoremap <buffer><silent><M-?> :GoImpl<Cr>
    nnoremap <buffer><silent><M-.> :GoImplements<Cr>
    nnoremap <buffer><silent><M-/> :GoReferrers<Cr>
    nnoremap <buffer><silent>,d :GoDeclsDir<Cr>
    nnoremap <buffer><silent>,c :GoCoverage<Cr>
    nnoremap <buffer><silent>,a :GoAlternate<Cr>
    if InstalledAdvCompEng()
        nnoremap <buffer><silent>gx :GoDoc<Cr>
    endif
    nnoremap <buffer><silent><M-M> :GoCommands<Cr>
endif
if InstalledCoc()
    nmap <buffer>gtj :CocCommand go.tags.add json<cr>
    nmap <buffer>gty :CocCommand go.tags.add yaml<cr>
    nmap <buffer>gtx :CocCommand go.tags.clear<cr>
endif
if Installed('vim-floaterm') && executable('go')
    nnoremap <buffer><M-B> :call SmartRunTerm("go build", "smart")<Cr>
    nnoremap <buffer><M-R> :call SmartRunTerm("go run", "smart")<Cr>
    nnoremap <buffer><M-T> :call SmartRunTerm("go build && go run", "tab")<Cr>
    nnoremap <buffer><M-'> :call SmartRunTerm("go run", "tab")<Cr>
    if HAS_GUI()
        nnoremap <buffer><M-"> :call SmartRunTerm("go run", "external")<Cr>
    endif
endif
inoremap <buffer>:: :=
inoremap <buffer>!! !=
