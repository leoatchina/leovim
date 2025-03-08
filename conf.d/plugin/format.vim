try
    set nrformats+=unsigned
catch /.*/
    " pass
endtry
" --------------------------
" easyalign
" --------------------------
let g:easy_align_delimiters = {}
let g:easy_align_delimiters['#'] = {'pattern': '#', 'ignore_groups': ['String']}
let g:easy_align_delimiters['*'] = {'pattern': '*', 'ignore_groups': ['String']}
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
xmap g, ga*,
xmap g= ga*=
xmap g: ga*:
xmap g<Space> ga*<Space>
PlugAddOpt 'vim-easy-align'
" ----------------------------
" neoformat
" ----------------------------
function! BuiltInFormat(visual)
    let col = col('.')
    let line = line('.')
    if a:visual
        silent! normal gv=
    else
        silent! normal ggVG=
    endif
    call cursor(line, col)
    call preview#cmdmsg("Using vim's builtin formatprg.", 1)
endfunction
if Planned('neoformat')
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
            call BuiltInFormat(visual)
        else
            if !visual
                let formatprgs = ['builtin'] + formatprgs
            endif
            let formatprg = ChooseOne(formatprgs, "Choose a formatprg")
            if formatprg == 'builtin'
                call BuiltInFormat(visual)
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
    nnoremap = :ChooseFormatPrg<Cr>
    xnoremap M :ChooseFormatPrg!<Cr>
else
    nnoremap <silent>= :call BuiltInFormat()<Cr>
endif
" ----------------------------
" table_mode
" ----------------------------
if Planned("vim-table-mode")
    let g:table_mode_map_prefix      = '<M-t>'
    let g:table_mode_tableize_d_map  = '<M-T>'
    let g:table_mode_corner          = '|'
    let g:table_mode_corner_corner   = '+'
    let g:table_mode_header_fillchar = '='
    nmap <M-t><M-t> <Plug>(table-mode-tableize)
    function! s:isAtStartOfLine(mapping)
        let text_before_cursor = getline('.')[0 : col('.')-1]
        let mapping_pattern = '\V' . escape(a:mapping, '\')
        let comment_pattern = '\V' . escape(substitute(&l:commentstring, '%s.*$', '', ''), '\')
        return (text_before_cursor =~? '^' . ('\v(' . comment_pattern . '\v)?') . '\s*\v' . mapping_pattern . '\v$')
    endfunction
    inoreabbrev <expr> <bar><bar>
                \ <SID>isAtStartOfLine('\|\|') ?
                \ '<c-o>:TableModeEnable<cr><bar><space><bar><left><left>' : '<bar><bar>'
    inoreabbrev <expr> __
                \ <SID>isAtStartOfLine('__') ?
                \ '<c-o>:silent! TableModeDisable<cr>' : '__'
endif
