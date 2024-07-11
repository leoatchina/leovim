setlocal commentstring=//\ %s
command! CDM cd %:h | exec 'cd' fnameescape(fnamemodify(findfile("pom.xml", escape(expand('%:p:h'), ' ') . ";"), ':h'))
nnoremap cdm :CDM<CR>
inoremap <buffer>!! !=
if Installed('nvim-java')
    command! JavaCommands call FzfCallCommands('JavaCommands', 'Java')
    nnoremap <buffer><silent><M-M> :JavaCommands<Cr>
endif
