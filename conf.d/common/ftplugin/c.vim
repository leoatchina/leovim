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
    if pack#installed_adv()
        nnoremap <buffer>gx :Cppman <C-r>=utils#expand('<cword>')<Cr>
        xnoremap <buffer>gx :<C-u>Cppman <C-r>=utils#get_visual_selection()<Cr>
    else
        nnoremap <buffer>K :Cppman <C-r>=utils#expand('<cword>')<Cr>
        xnoremap <buffer>K :<C-u>Cppman <C-r>=utils#get_visual_selection()<Cr>
    endif
endif
inoremap <buffer>!! !=
