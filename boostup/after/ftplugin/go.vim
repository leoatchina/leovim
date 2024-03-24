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
inoremap <buffer>:: :=
inoremap <buffer>!! !=
