setlocal commentstring=//\ %s
command! CDM cd %:h | exec 'cd' fnameescape(fnamemodify(findfile("pom.xml", utils#escape(utils#expand('%:p:h'), ' ') . ";"), ':h'))
nnoremap cdm :CDM<CR>
inoremap <buffer>!! !=
if utils#is_installed('nvim-java')
    command! JavaCommands call FzfCallCommands('JavaCommands', 'Java')
    nnoremap <buffer><silent><M-M> :JavaCommands<Cr>
endif
