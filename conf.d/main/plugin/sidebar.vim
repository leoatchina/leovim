" ------------------------------
" Skip in VSCode environment
" ------------------------------
if utils#is_vscode()
    finish
endif
let g:sidebars = {}
function! s:check_buf_ft(name, nr) abort
    return getwinvar(a:nr, '&filetype') ==# a:name || bufname(winbufnr(a:nr)) ==# a:name
endfunction
" --------------------------
" symbol
" --------------------------
if pack#installed('vista.vim') && g:ctags_type =~ 'Universal'
    function! s:check_vista_kind(nr) abort
        return s:check_buf_ft('vista_kind', a:nr)
    endfunction
    let g:sidebars.vista_ctags = {
                \ 'position': 'left',
                \ 'check_win': function('s:check_vista_kind'),
                \ 'open': 'Vista ctags',
                \ 'close': 'Vista!!'
                \ }
    nnoremap <silent>t<tab> :call sidebar#toggle('vista_ctags')<CR>
endif
if pack#installed('vista.vim') && pack#installed('nvim-tree.lua')
    function! s:open_nvimtree_vista() abort
        let code_win = win_getid()
        lua pcall(require, 'cfg.nvimtree')
        lua pcall(function() require('nvim-tree.api').tree.open({ focus = false }) end)
        call win_gotoid(code_win)
        Vista
        call win_gotoid(code_win)
    endfunction
    function! s:close_nvimtree_vista() abort
        silent! Vista!
        lua pcall(function() require('nvim-tree.api').tree.close() end)
    endfunction
    function! s:check_nvimtree_vista(nr) abort
        let ft = getwinvar(a:nr, '&filetype')
        return ft ==# 'NvimTree' || ft =~# '^vista'
    endfunction
    let g:sidebars.symbol_tree = {
                \ 'position': 'left',
                \ 'check_win': function('s:check_nvimtree_vista'),
                \ 'open': function('s:open_nvimtree_vista'),
                \ 'close': function('s:close_nvimtree_vista')
                \ }
    nnoremap <silent><C-t> :call sidebar#toggle('symbol_tree')<CR>
    command! -bar SymbolTreeClose call sidebar#close('symbol_tree')
elseif pack#installed('vista.vim') && pack#planned('vim-fern')
    function! s:open_fern_vista() abort
        let code_win = win_getid()
        let width = get(g:, 'sidebar_width', 40)
        execute printf('Fern . -drawer -stay -width=%d', width)
        call win_gotoid(code_win)
        Vista
        call win_gotoid(code_win)
    endfunction
    function! s:close_fern_vista() abort
        silent! Vista!
        silent! Fern . -drawer -toggle
    endfunction
    function! s:check_fern_vista(nr) abort
        let ft = getwinvar(a:nr, '&filetype')
        return ft =~# '^vista'
    endfunction
    let g:sidebars.symbol_tree = {
                \ 'position': 'left',
                \ 'check_win': function('s:check_fern_vista'),
                \ 'open': function('s:open_fern_vista'),
                \ 'close': function('s:close_fern_vista')
                \ }
    nnoremap <silent><C-t> :call sidebar#toggle('symbol_tree')<CR>
    command! -bar SymbolTreeClose call sidebar#close('symbol_tree')
elseif pack#installed('vista.vim')
    if get(g:, 'ctags_type', '') =~ 'Universal' && g:vista_default_executive != 'ctags'
        function! s:check_vista(nr) abort
            return tolower(getwinvar(a:nr, '&filetype')) =~ 'vista'
        endfunction
        let g:sidebars.vista = {
                    \ 'position': 'left',
                    \ 'check_win': function('s:check_vista'),
                    \ 'open': 'Vista ' . g:vista_default_executive,
                    \ 'close': 'Vista!!'
                    \ }
    else
        function! s:check_vista_all(nr) abort
            return s:check_buf_ft('vista_kind', a:nr) || s:check_buf_ft('vista', a:nr)
        endfunction
        let g:sidebars.vista = {
                    \ 'position': 'left',
                    \ 'check_win': function('s:check_vista_all'),
                    \ 'open': 'Vista ' . g:vista_default_executive,
                    \ 'close': 'Vista!!'
                    \ }
    endif
    nnoremap <silent><C-t> :call sidebar#toggle('vista')<CR>
elseif pack#installed('tagbar')
    let g:tagbar_position = 'leftabove vertical'
    let g:tagbar_sort  = 0
    let g:tagbar_width = 35
    let g:tagbar_autoclose_netrw = 1
    let g:tagbar_type_css = {
                \ 'ctagstype' : 'css',
                \ 'kinds' : [
                    \ 'c:classes',
                    \ 's:selectors',
                    \ 'i:identities'
                    \ ]}
    function! s:check_tags(nr) abort
        return s:check_buf_ft('tagbar', a:nr)
    endfunction
    let g:sidebars.tagbar = {
                \ 'position': 'left',
                \ 'check_win': function('s:check_tags'),
                \ 'open': 'TagbarOpen',
                \ 'close': 'TagbarClose'
                \ }
    nnoremap <silent><C-t> :call sidebar#toggle('tagbar')<CR>
endif
" --------------------------
" tree_browser
" --------------------------
if pack#planned('vim-fern')
    source $CFG_DIR/fern.vim
    let g:tree_browser = 'fern'
    function! s:check_fern_tree_browser(nr) abort
        if s:check_buf_ft('fern', a:nr)
            for w in range(1, winnr('$'))
                if getwinvar(w, '&filetype') =~# '^vista'
                    return 0
                endif
            endfor
            return 1
        endif
        return 0
    endfunction
    let g:sidebars.tree_browser = {
                \ 'position': 'left',
                \ 'check_win': function('s:check_fern_tree_browser'),
                \ 'open': 'FernSideGetRoot',
                \ 'close': 'Fern . -drawer -toggle'
                \ }
else
    let g:tree_browser = 'netrw'
    let g:netrw_nogx = 1
    let g:netrw_altv = 0
    let g:netrw_banner = 0
    let g:netrw_winsize = 16
    let g:netrw_liststyle = 3
    let g:netrw_browse_split = 4
    " functions
    function! s:netrw_close()
        if exists('t:netrw_winnr')
            let netrw_bufnr = bufwinnr(t:netrw_winnr)
            if netrw_bufnr != -1
                exec netrw_bufnr . 'wincmd w'
                close
            endif
            unlet t:netrw_winnr
        endif
    endfunction
    command! NetrwClose call s:netrw_close()
    function! s:netrw_open()
        Vexplore
        let t:netrw_winnr = bufnr("%")
        wincmd p
    endfunction
    command! NetrwOpen call s:netrw_open()
    function! s:check_netrw(nr) abort
        return s:check_buf_ft('netrw', a:nr)
    endfunction
    let g:sidebars.tree_browser = {
                \ 'position': 'left',
                \ 'check_win': function('s:check_netrw'),
                \ 'open': 'NetrwOpen',
                \ 'close': 'NetrwClose'
                \ }
endif
nnoremap <silent><C-b> :call sidebar#toggle('tree_browser')<CR>
