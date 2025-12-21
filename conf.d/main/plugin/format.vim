" Skip in VSCode environment
if utils#is_vscode()
    finish
endif
try
    set nrformats+=unsigned
catch /.*/
    " pass
endtry
" ----------------------------
" neoformat
" ----------------------------
if pack#planned('neoformat')
    " NOTE:  the two functions below is copied from neoformat.vim
    function! s:autoload_func_exists(func_name) abort
        try
            call eval(a:func_name . '()')
        catch /^Vim\%((\a\+)\)\=:E/
            return 0
        endtry
        return 1
    endfunction
    command! -bang -range ChooseFormatPrg call utils#choose_formatprg(<bang>0)
    nnoremap <silent>+ :ChooseFormatPrg<Cr>
    xnoremap <silent>+ :ChooseFormatPrg!<Cr>
else
    nnoremap <silent>+ :call utils#format()<Cr>
endif
" ----------------------------
" table_mode
" ----------------------------
if pack#planned("vim-table-mode")
    let g:table_mode_map_prefix      = '<M-t>'
    let g:table_mode_tableize_d_map  = '<M-T>'
    let g:table_mode_corner          = '|'
    let g:table_mode_corner_corner   = '+'
    let g:table_mode_header_fillchar = '='
    nmap <M-t><M-t> <Plug>(table-mode-tableize)
    function! s:isAtStartOfLine(mapping)
        let text_before_cursor = getline('.')[0 : col('.')-1]
        let mapping_pattern = '\V' . utils#escape(a:mapping, '\')
        let comment_pattern = '\V' . utils#escape(substitute(&l:commentstring, '%s.*$', '', ''), '\')
        return (text_before_cursor =~? '^' . ('\v(' . comment_pattern . '\v)?') . '\s*\v' . mapping_pattern . '\v$')
    endfunction
    inoreabbrev <expr> <bar><bar>
                \ <SID>isAtStartOfLine('\|\|') ?
                \ '<c-o>:TableModeEnable<cr><bar><space><bar><left><left>' : '<bar><bar>'
    inoreabbrev <expr> __
                \ <SID>isAtStartOfLine('__') ?
                \ '<c-o>:silent! TableModeDisable<cr>' : '__'
endif
