" ------------------------------
" Skip in VSCode environment
" ------------------------------
if utils#is_vscode()
    finish
endif
let g:sidebars = {}
" Match a filetype pattern, or an exact buffer name.
function! s:check_buf_ft(name, nr) abort
    return getwinvar(a:nr, '&filetype') =~# a:name || bufname(winbufnr(a:nr)) ==# a:name
endfunction
" --------------------------
" symbol
" --------------------------
let s:use_aerial = has('nvim') && pack#installed('aerial.nvim')
function! s:open_symbols() abort
    if s:use_aerial
        AerialTreeOpen
    else
        Vista
    endif
endfunction
function! s:close_symbols() abort
    if pack#installed('vista.vim')
        silent! Vista!
        if s:use_aerial && exists('#VistaNvimLsp')
            autocmd! VistaNvimLsp
        endif
    endif
    if s:use_aerial
        AerialCloseAll
    endif
endfunction
function! s:check_symbols(nr) abort
    return s:check_buf_ft('vista', a:nr) || (s:use_aerial && s:check_buf_ft('^aerial$', a:nr))
endfunction
function! s:resize_vista(tab, timer) abort
    let tree = {}
    let symbols = {}
    for win in getwininfo()
        if win.tabnr != a:tab
            continue
        endif
        if s:check_buf_ft('^\%(fern\|NvimTree\)$', win.winid)
            let tree = win
        elseif s:check_buf_ft('vista', win.winid)
            let symbols = win
        endif
    endfor
    if !empty(tree) && !empty(symbols) && tree.wincol == symbols.wincol
        let height = max([1, (tree.height + symbols.height) * 4 / 10])
        call win_execute(tree.winid, 'resize ' . height)
    endif
endfunction
augroup LeoVistaLayout
    autocmd!
    autocmd FileType vista* call timer_start(0, function('s:resize_vista', [tabpagenr()]))
augroup END
if pack#installed('vista.vim') && g:ctags_type =~ 'Universal'
    function! s:check_vista_kind(nr) abort
        return s:check_buf_ft('vista', a:nr)
    endfunction
    let g:sidebars.vista_ctags = {
                \ 'position': 'left',
                \ 'check_win': function('s:check_vista_kind'),
                \ 'open': 'Vista ctags',
                \ 'close': 'Vista!!'
                \ }
    nnoremap <silent>t<tab> :call sidebar#toggle('vista_ctags')<CR>
endif
if (pack#installed('vista.vim') || s:use_aerial) && pack#installed('nvim-tree.lua')
    function! s:open_nvimtree_vista() abort
        let code_win = win_getid()
        lua pcall(require, 'cfg.nvimtree')
        lua pcall(function() require('nvim-tree.api').tree.open({ focus = false }) end)
        call win_gotoid(code_win)
        call s:open_symbols()
        call win_gotoid(code_win)
    endfunction
    function! s:close_nvimtree_vista() abort
        call s:close_symbols()
        lua pcall(function() require('nvim-tree.api').tree.close() end)
    endfunction
    function! s:check_nvimtree_vista(nr) abort
        return s:check_buf_ft('^NvimTree$', a:nr) || s:check_symbols(a:nr)
    endfunction
    let g:sidebars.symbol_tree = {
                \ 'position': 'left',
                \ 'check_win': function('s:check_nvimtree_vista'),
                \ 'open': function('s:open_nvimtree_vista'),
                \ 'close': function('s:close_nvimtree_vista')
                \ }
    nnoremap <silent><C-t> :call sidebar#toggle('symbol_tree')<CR>
    command! -bar SymbolTreeClose call sidebar#close('symbol_tree')
elseif (pack#installed('vista.vim') || s:use_aerial) && pack#planned('vim-fern')
    function! s:open_fern_vista() abort
        let code_win = win_getid()
        let width = get(g:, 'sidebar_width', 40)
        execute printf('Fern . -drawer -stay -width=%d', width)
        call win_gotoid(code_win)
        call s:open_symbols()
        call win_gotoid(code_win)
    endfunction
    function! s:close_fern_vista() abort
        call s:close_symbols()
        silent! Fern . -drawer -toggle
    endfunction
    function! s:check_fern_vista(nr) abort
        return s:check_symbols(a:nr)
    endfunction
    let g:sidebars.symbol_tree = {
                \ 'position': 'left',
                \ 'check_win': function('s:check_fern_vista'),
                \ 'open': function('s:open_fern_vista'),
                \ 'close': function('s:close_fern_vista')
                \ }
    nnoremap <silent><C-t> :call sidebar#toggle('symbol_tree')<CR>
    command! -bar SymbolTreeClose call sidebar#close('symbol_tree')
elseif s:use_aerial
    let g:sidebars.symbol_tree = {
                \ 'position': 'left',
                \ 'check_win': function('s:check_symbols'),
                \ 'open': function('s:open_symbols'),
                \ 'close': function('s:close_symbols')
                \ }
    nnoremap <silent><C-t> :call sidebar#toggle('symbol_tree')<CR>
    command! -bar SymbolTreeClose call sidebar#close('symbol_tree')
elseif pack#installed('vista.vim')
    if get(g:, 'ctags_type', '') =~ 'Universal' && g:vista_default_executive != 'ctags'
        function! s:check_vista(nr) abort
            return s:check_buf_ft('\cvista', a:nr)
        endfunction
        let g:sidebars.vista = {
                    \ 'position': 'left',
                    \ 'check_win': function('s:check_vista'),
                    \ 'open': 'Vista ' . g:vista_default_executive,
                    \ 'close': 'Vista!!'
                    \ }
    else
        function! s:check_vista_all(nr) abort
            return s:check_buf_ft('vista', a:nr)
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
    let g:tagbar_autofocus = 0
    let g:tagbar_type_css = {
                \ 'ctagstype' : 'css',
                \ 'kinds' : [
                    \ 'c:classes',
                    \ 's:selectors',
                    \ 'i:identities'
                    \ ]}
    function! s:tagbar_tree_win() abort
        let ft = pack#planned('vim-fern') ? 'fern' : 'netrw'
        for nr in range(1, winnr('$'))
            if s:check_buf_ft(ft, nr)
                return win_getid(nr)
            endif
        endfor
        return 0
    endfunction
    function! s:open_tagbar_tree() abort
        let code = win_getid()
        let position = g:tagbar_position
        try
            if pack#planned('vim-fern')
                execute printf('Fern . -drawer -stay -width=%d', get(g:, 'sidebar_width', 40))
            else
                NetrwOpen
            endif
            let tree = s:tagbar_tree_win()
            call win_gotoid(code)
            if tree
                let g:tagbar_position = win_id2win(tree) . 'wincmd w | belowright '
            endif
            TagbarOpen
            if tree && win_gotoid(tree)
                let symbol = 0
                for nr in range(1, winnr('$'))
                    if s:check_buf_ft('tagbar', nr)
                        let symbol = nr
                        break
                    endif
                endfor
                if symbol
                    execute 'resize ' . max([1, (winheight(0) + winheight(symbol)) * 4 / 10])
                endif
            endif
        finally
            let g:tagbar_position = position
            call win_gotoid(code)
        endtry
    endfunction
    function! s:close_tagbar_tree() abort
        let code = win_getid()
        TagbarClose
        let tree = s:tagbar_tree_win()
        if tree && win_gotoid(tree)
            close
        endif
        call win_gotoid(code)
    endfunction
    function! s:check_tagbar_tree(nr) abort
        return s:check_buf_ft('tagbar', a:nr)
                    \ || win_getid(a:nr) == s:tagbar_tree_win()
    endfunction
    let g:sidebars.symbol_tree = {
                \ 'position': 'left',
                \ 'check_win': function('s:check_tagbar_tree'),
                \ 'open': function('s:open_tagbar_tree'),
                \ 'close': function('s:close_tagbar_tree')
                \ }
    nnoremap <silent><C-t> :call sidebar#toggle('symbol_tree')<CR>
    command! -bar SymbolTreeClose call sidebar#close('symbol_tree')
endif
" --------------------------
" tree_browser
" --------------------------
if pack#planned('vim-fern')
    let g:tree_browser = 'fern'
    function! s:check_fern_tree_browser(nr) abort
        if s:check_buf_ft('fern', a:nr)
            for w in range(1, winnr('$'))
                if s:check_buf_ft('vista\|^aerial$\|^tagbar$', w)
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
        for nr in range(1, winnr('$'))
            if s:check_buf_ft('tagbar', nr)
                return 0
            endif
        endfor
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
