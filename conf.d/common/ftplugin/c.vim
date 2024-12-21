setlocal commentstring=//\ %s
" for a.vim
if Installed('a.vim')
    nnoremap <buffer>qa :A<Cr>
    nnoremap <buffer>qs :AS<Cr>
    nnoremap <buffer>qv :AV<Cr>
    nnoremap <buffer>qt :AT<Cr>
    nnoremap <buffer>qn :AN<Cr>
endif
" ccls
if Installed('vim-ccls')
    command! CclsCommands call FzfCallCommands('CclsCommands', 'Ccls')
    nnoremap <buffer><M-M> :CclsCommands<Cr>
endif
" cppman
if Installed('vim-cppman')
    if AdvCompEngine()
        nnoremap <buffer>gx :Cppman <C-r>=expand('<cword>')<Cr>
        xnoremap <buffer>gx :<C-u>Cppman <C-r>=GetVisualSelection()<Cr>
    else
        nnoremap <buffer>K :Cppman <C-r>=expand('<cword>')<Cr>
        xnoremap <buffer>K :<C-u>Cppman <C-r>=GetVisualSelection()<Cr>
    endif
endif
inoremap <buffer>!! !=
