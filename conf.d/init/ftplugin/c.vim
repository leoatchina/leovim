setlocal commentstring=//\ %s
" for a.vim
if pack#installed('a.vim')
    nnoremap <buffer>Ma :A<Cr>
    nnoremap <buffer>Ms :AS<Cr>
    nnoremap <buffer>Mv :AV<Cr>
    nnoremap <buffer>Mt :AT<Cr>
    nnoremap <buffer>Mn :AN<Cr>
endif
" cppman
if pack#installed('vim-cppman')
    nnoremap <buffer>gK :Cppman <C-r>=utils#expand('<cword>')<Cr>
    xnoremap <buffer>gK :<C-u>Cppman <C-r>=utils#get_visual()<Cr>
endif
inoremap <buffer>!! !=
