" Skip in VSCode environment
if utils#is_vscode()
    finish
endif
" --------------------
" J show diag
" --------------------
function! diagnostic#show(diagnostic)
    if a:diagnostic
        if pack#planned('ale')
            ALEDetail
        elseif pack#installed_coc()
            call CocActionAsync('diagnosticInfo')
        elseif pack#installed_lsp()
            lua vim.diagnostic.open_float()
        else
            call preview#errmsg('Please install linter tools!') | sleep 2
        endif
    else
        call preview#errmsg('Please select lines to merge!') | sleep 2
    endif
endfunction
function! s:j(line1, line2, diagnostic) range abort
    let pos = getpos('.')
    if a:line1 != a:line2
        execute a:line1 . "," . a:line2 . "join"
    else
        call diagnostic#show(a:diagnostic)
        call setpos('.', pos)
    endif
endfunction
command! -range MergeLines call s:j(<line1>, <line2>, 0)
command! -range DiagShow call s:j(<line1>, <line2>, 1)
xnoremap <silent>J :MergeLines<Cr>
if !utils#has_map('J', 'n')
    nnoremap <silent>J :DiagShow<Cr>
endif
