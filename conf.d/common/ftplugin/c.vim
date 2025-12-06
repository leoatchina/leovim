setlocal commentstring=//\ %s
" for a.vim
if utils#is_installed('a.vim')
    nnoremap <buffer>qa :A<Cr>
    nnoremap <buffer>qs :AS<Cr>
    nnoremap <buffer>qv :AV<Cr>
    nnoremap <buffer>qt :AT<Cr>
    nnoremap <buffer>qn :AN<Cr>
endif
" ccls
if utils#is_installed('vim-ccls')
    command! CclsCommands call FzfCallCommands('CclsCommands', 'Ccls')
    nnoremap <buffer><M-M> :CclsCommands<Cr>
endif
" cppman
if utils#is_installed('vim-cppman')
    if utils#is_installed_adv()
        nnoremap <buffer>gx :Cppman <C-r>=utils#expand('<cword>')<Cr>
        xnoremap <buffer>gx :<C-u>Cppman <C-r>=utils#get_visual_selection()<Cr>
    else
        nnoremap <buffer>K :Cppman <C-r>=utils#expand('<cword>')<Cr>
        xnoremap <buffer>K :<C-u>Cppman <C-r>=utils#get_visual_selection()<Cr>
    endif
endif
inoremap <buffer>!! !=
