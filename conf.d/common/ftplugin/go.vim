setlocal commentstring=//\ %s
command! GoCommands call FzfCallCommands('GoCommands', 'Go')
nnoremap <buffer><silent><M-M> :GoCommands<Cr>
if Installed('vim-go')
    nnoremap <buffer><silent>gl :GoDefPop<Cr>
    nnoremap <buffer><silent><leader>A :GoImports<Cr>
    if AdvCompEngine()
        nnoremap <buffer><silent>gx :GoDoc<Cr>
    else
        nnoremap <buffer><silent><C-g> :GoDef<Cr>
        nnoremap <buffer><silent><M-/> :GoReferrers<Cr>
        nnoremap <buffer><silent><M-.> :GoImplements<Cr>
        nnoremap <buffer><silent>gh :GoCallers<Cr>
    endif
endif
" NOTE: below in order to be comparable with vscode-neovim
if Installed('coc.nvim')
    nmap <buffer>qtj :CocCommand go.tags.add json<cr>
    nmap <buffer>qty :CocCommand go.tags.add yaml<cr>
    nmap <buffer>qtx :CocCommand go.tags.clear<cr>
endif
inoremap <buffer>:: :=
