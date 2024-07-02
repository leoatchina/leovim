setlocal commentstring=//\ %s
command! GoCommands call FzfCallCommands('GoCommands', 'Go')
if Installed('vim-go')
    let g:go_doc_balloon = 0
    let g:go_def_mapping_enabled = 0
    nnoremap <buffer><silent>gl :GoDefPop<Cr>
    nnoremap <buffer><silent>,d :GoDeclsDir<Cr>
    nnoremap <buffer><silent>,c :GoCoverage<Cr>
    nnoremap <buffer><silent>,a :GoAlternate<Cr>
    nnoremap <buffer><silent><M-?> :GoImpl<Cr>
    nnoremap <buffer><silent><M-M> :GoCommands<Cr>
    nnoremap <buffer><silent><leader>A :GoImports<Cr>
    if !AdvCompEngine()
        nnoremap <buffer><silent><C-g> :GoDef<Cr>
        nnoremap <buffer><silent><M-/> :GoReferrers<Cr>
        nnoremap <buffer><silent><M-.> :GoImplements<Cr>
        nnoremap <buffer><silent>gh :GoCallers<Cr>
    endif
endif
" NOTE: below in order to be comparable with vscode-neovim
if Installed('coc.nvim')
    nmap <buffer>,tj :CocCommand go.tags.add json<cr>
    nmap <buffer>,ty :CocCommand go.tags.add yaml<cr>
    nmap <buffer>,tx :CocCommand go.tags.clear<cr>
endif
if Installed('vim-floaterm') && executable('go')
    nnoremap <buffer><M-B> :call SmartRunTerm(printf("time go build -o %s/build/ %s", GetRootDir(), GetRootDir()), "smart")<Cr>
endif
inoremap <buffer>:: :=
inoremap <buffer>!! !=
