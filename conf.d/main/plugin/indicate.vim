" Skip in VSCode environment
if utils#is_vscode()
    finish
endif
" --------------------
" indentline
" --------------------
filetype plugin indent on
if pack#installed('indent-blankline.nvim')
    lua require("cfg/ibl")
elseif pack#planned('indentline')
    let g:vim_json_conceal = 0
    let g:indentLine_enabled = 0
    let g:markdown_syntax_conceal = 0
    let g:indentLine_char_list = ['|', '¦', '┆', '┊']
    nnoremap <silent><leader>I :IndentLinesToggle<Cr>
endif
" --------------------
" WhichKey
" --------------------
set timeout
set ttimeout
set ttimeoutlen=60
set timeoutlen=300
set updatetime=200
if get(g:, 'leovim_whichkey', 1)
    nnoremap [ :WhichKey '['<Cr>
    nnoremap ] :WhichKey ']'<Cr>
    " basic keys
    nnoremap <Tab> :WhichKey '<Tab>'<Cr>
    nnoremap <Space> :WhichKey ' '<Cr>
    nnoremap q :WhichKey 'q'<Cr>
    nnoremap , :WhichKey ','<Cr>
    nnoremap ; :WhichKey ';'<Cr>
    nnoremap \ :WhichKey '\'<Cr>
    nnoremap yu :WhichKey 'yu'<Cr>
    xnoremap <Space> :WhichKeyVisual ' '<Cr>
    xnoremap , :WhichKeyVisual ','<Cr>
    xnoremap ; :WhichKeyVisual ';'<Cr>
    xnoremap \ :WhichKeyVisual '\'<Cr>
    " gmzs whichkey
    nnoremap g<Space> :WhichKey 'g'<Cr>
    nnoremap m<Space> :WhichKey 'm'<Cr>
    nnoremap s<Space> :WhichKey 's'<Cr>
    nnoremap S<Space> :WhichKey 'S'<Cr>
    nnoremap z<Space> :WhichKey 'z'<Cr>
    nnoremap Z<Space> :WhichKey 'Z'<Cr>
    " C- keys
    nnoremap <C-\> :WhichKey "\<C-Bslash\>"<Cr>
    nnoremap <C-f> :WhichKey "\<C-f\>"<Cr>
    xnoremap <C-f> :WhichKeyVisual "\<C-f\>"<Cr>
    " M- keys
    nnoremap <M-g> :WhichKey "\<M-g\>"<Cr>
    nnoremap <M-h> :WhichKey "\<M-h\>"<Cr>
    nnoremap <M-j> :WhichKey "\<M-j\>"<Cr>
    nnoremap <M-k> :WhichKey "\<M-k\>"<Cr>
    nnoremap <M-l> :WhichKey "\<M-l\>"<Cr>
    nnoremap <M-y> :WhichKey "\<M-y\>"<Cr>
    inoremap <M-y> <C-o>:WhichKey "\<M-y\>"<Cr>
    if pack#planned("vim-table-mode")
        nnoremap <M-t> :WhichKey       "\<M-t\>"<Cr>
        xnoremap <M-t> :WhichKeyVisual "\<M-t\>"<Cr>
    endif
    if pack#installed('vim-floaterm-enhance')
        nnoremap <M-a> :WhichKey       "\<M-a\>"<Cr>
        xnoremap <M-a> :WhichKeyVisual "\<M-a\>"<Cr>
        nnoremap <M-i> :WhichKey       "\<M-i\>"<Cr>
        xnoremap <M-i> :WhichKeyVisual "\<M-i\>"<Cr>
    endif
    if get(g:, 'debug_tool', '') != ''
        nnoremap <M-e> :WhichKey "\<M-e\>"<Cr>
        nnoremap <M-m> :WhichKey "\<M-m\>"<Cr>
    endif
    if pack#planned('vim-fugitive')
        au FileType fugitive nnoremap <buffer>g :WhichKey "g"<Cr>
        au FileType fugitive nnoremap <buffer>c :WhichKey "c"<Cr>
        au FileType fugitive nnoremap <buffer>d :WhichKey "d"<Cr>
        au FileType fugitive nnoremap <buffer>r :WhichKey "r"<Cr>
    endif
endif
" --------------------------
" show impport config
" --------------------------
function! s:getVimVersion()
    let l:result=[]
    if has('nvim')
        if utils#has_gui()
            call add(l:result, 'gnvim-')
        else
            call add(l:result, 'nvim-')
        endif
        let v = api_info().version
        call add(l:result, printf('%d.%d.%d', v.major, v.minor, v.patch))
    else
        if utils#has_gui()
            call add(l:result, 'gvim-')
        else
            call add(l:result, 'vim-')
        endif
        redir => l:msg | silent! execute ':version' | redir END
        call add(l:result, matchstr(l:msg, 'VIM - Vi IMproved\s\zs\d.\d\ze'))
        call add(l:result, '.')
        call add(l:result, matchstr(l:msg, '\v\zs\d{1,5}\ze\n'))
    endif
    return join(l:result, "")
endfunction
function! s:version()
    let params_dict = {
                \ 'version':         s:getVimVersion(),
                \ 'python_version':  g:python_version,
                \ 'tree_browser':    g:tree_browser,
                \ 'colors_name':     g:colors_name,
                \ 'complete_engine': g:complete_engine
                \ }
    if get(g:, 'ai_complete_engine', '') != ''
        let params_dict['ai_complete_engine'] = g:ai_complete_engine
    endif
    if get(g:, 'python3_host_prog', '') != ''
        let params_dict['python3_host_prog'] = g:python3_host_prog
    endif
    if get(g:, 'python_prog', '') != ''
        let params_dict['python_prog'] = g:python_prog
    endif
    if get(g:, 'search_tool', '') != ''
        let params_dict['search_tool'] = g:search_tool
    endif
    if get(g:, 'debug_tool', '') != ''
        let params_dict['debug_tool'] = g:debug_tool
    endif
    if get(g:, 'symbol_tool', '') != ''
        let params_dict['symbol_tool'] = g:symbol_tool
    endif
    if get(g:, 'lint_tool', '') != ''
        let params_dict['lint_tool'] = g:lint_tool
    endif
    if get(g:, 'input_method', '') != ''
        let params_dict['input_method'] = g:input_method
    endif
    if has('nvim') && exists('$TERM') && $TERM != ''
        let params_dict['term'] = $TERM
    elseif !has('nvim') && exists('&term') && &term != ''
        let params_dict['term'] = &term
    endif
    echom string(params_dict)
endfunction
command! Version call s:version()
nnoremap <M-k>v :Version<Cr>
nnoremap <M-k>V :version<Cr>
