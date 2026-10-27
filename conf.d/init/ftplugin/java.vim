setlocal commentstring=//\ %s
command! CDM cd %:h | exec 'cd' fnameescape(fnamemodify(findfile("pom.xml", utils#escape(utils#expand('%:p:h'), ' ') . ";"), ':h'))
nnoremap <buffer> cdm :CDM<CR>
inoremap <buffer>!! !=
if pack#installed('nvim-java')
    command! JavaCommands call FzfCallCommands('JavaCommands', 'Java')
    nnoremap <buffer><silent><M-M> :JavaCommands<Cr>
    nnoremap <buffer><silent> <leader>A <Cmd>lua vim.lsp.buf.code_action({context = {only = {'source.organizeImports'}, diagnostics = {}}, apply = true})<Cr>
    xnoremap <buffer><silent> <leader>A <Cmd>lua vim.lsp.buf.code_action({context = {only = {'source.organizeImports'}, diagnostics = {}}, apply = true})<Cr>
    nnoremap <buffer><silent> Mev <Cmd>JavaRefactorExtractVariable<Cr>
    nnoremap <buffer><silent> Mec <Cmd>JavaRefactorExtractConstant<Cr>
    nnoremap <buffer><silent> Mtc <Cmd>JavaTestDebugCurrentClass<Cr>
    nnoremap <buffer><silent> Mtm <Cmd>JavaTestDebugCurrentMethod<Cr>
    " Keep Visual mode active: nvim-java code actions read the current selection.
    xnoremap <buffer><silent> Mev <Cmd>JavaRefactorExtractVariable<Cr>
    xnoremap <buffer><silent> Mec <Cmd>JavaRefactorExtractConstant<Cr>
    xnoremap <buffer><silent> Mem <Cmd>JavaRefactorExtractMethod<Cr>
endif
