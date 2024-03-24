setlocal commentstring=//\ %s
command! CDM cd %:h | exec 'cd' fnameescape(fnamemodify(findfile("pom.xml", escape(expand('%:p:h'), ' ') . ";"), ':h'))
nnoremap cdm :CDM<CR>
inoremap <buffer>!! !=
