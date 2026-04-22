setlocal commentstring=//\ %s
" for a.vim
if pack#installed('a.vim')
    nnoremap <buffer>qa :A<Cr>
    nnoremap <buffer>qs :AS<Cr>
    nnoremap <buffer>qv :AV<Cr>
    nnoremap <buffer>qt :AT<Cr>
    nnoremap <buffer>qn :AN<Cr>
endif
" ccls
if pack#installed('vim-ccls')
    command! CclsCommands call FzfCallCommands('CclsCommands', 'Ccls')
    nnoremap <buffer><M-M> :CclsCommands<Cr>
endif
" cppman
if pack#installed('vim-cppman')
    nnoremap <buffer><leader>gm :Cppman <C-r>=utils#expand('<cword>')<Cr>
    xnoremap <buffer><leader>gm :<C-u>Cppman <C-r>=utils#get_visual()<Cr>
endif
inoremap <buffer>!! !=
