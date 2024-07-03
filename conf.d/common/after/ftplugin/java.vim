setlocal commentstring=//\ %s
command! CDM cd %:h | exec 'cd' fnameescape(fnamemodify(findfile("pom.xml", escape(expand('%:p:h'), ' ') . ";"), ':h'))
nnoremap cdm :CDM<CR>
inoremap <buffer>!! !=

if Installed('lua-async-await', 'nvim-java-refactor', 'nvim-java-core', 'nvim-java-test', 'nvim-java-dap')
    command! JavaCommands call FzfCallCommands('JavaCommands', 'Java')
    nnoremap <buffer><silent><M-M> :JavaCommands<Cr>
endif
