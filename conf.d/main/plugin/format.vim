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
    function! ChooseFormatPrg(visual) abort
        let filetype = &ft
        let visual = a:visual
        if &formatprg != '' && neoformat#utils#var('neoformat_try_formatprg')
            call neoformat#utils#log('adding formatprg to enabled formatters')
            let formatprgs = [split(&formatprg)[0]]
        else
            let formatprgs = []
        endif
        if exists('b:neoformat_enabled_' . filetype)
            let formatprgs = formatprgs + b:neoformat_enabled_{filetype}
        elseif exists('g:neoformat_enabled_' . filetype)
            let formatprgs = formatprgs + g:neoformat_enabled_{filetype}
        elseif s:autoload_func_exists('neoformat#formatters#' . filetype . '#enabled')
            let formatprgs = formatprgs + neoformat#formatters#{filetype}#enabled()
        endif
        if empty(formatprgs)
            call utils#format(visual)
        else
            if !visual
                let formatprgs = ['builtin'] + formatprgs
            endif
            let formatprg = ChooseOne(formatprgs, "Choose a formatprg")
            if formatprg == 'builtin'
                call utils#format(visual)
            else
                if visual
                    let start = line("'<")
                    let end = line("'>")
                    exec start . "," . end . 'Neoformat ' . formatprg
                else
                    exec "Neoformat " . formatprg
                endif
            endif
        endif
    endfunction
    command! -bang -range ChooseFormatPrg call ChooseFormatPrg(<bang>0)
    nnoremap + :ChooseFormatPrg<Cr>
    xnoremap + :ChooseFormatPrg!<Cr>
else
    nnoremap <silent>= :call BuiltInFormat()<Cr>
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
