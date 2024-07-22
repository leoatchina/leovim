PlugAddOpt 'vim-sidebar-manager'
let g:sidebars = {}
function! s:check_buf_ft(name, nr) abort
    return getwinvar(a:nr, '&filetype') ==# tolower(a:name) || bufname(winbufnr(a:nr)) ==# tolower(a:name)
endfunction
" --------------------------
" symbol
" --------------------------
if Installed('vista.vim')
    if get(g:, 'ctags_type', '') =~ 'Universal' && g:vista_default_executive != 'ctags'
        function! s:check_vista(nr) abort
            return s:check_buf_ft('vista', a:nr)
        endfunction
        function! s:check_vista_kind(nr) abort
            return s:check_buf_ft('vista_kind', a:nr)
        endfunction
        let g:sidebars.vistactags = {
                    \ 'position': 'left',
                    \ 'check_win': function('s:check_vista_kind'),
                    \ 'open': 'Vista ctags',
                    \ 'close': 'Vista!!'
                    \ }
        nnoremap <silent>t<tab> :call sidebar#toggle('vistactags')<CR>
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
elseif Installed('tagbar')
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
if Installed('fern.vim')
    source $CFG_DIR/fern.vim
    let g:tree_browser = 'fern'
    let g:sidebars.tree_browser = {
                \ 'position': 'left',
                \ 'check_win': function('s:check_buf_ft', ["fern"]),
                \ 'open': 'Fern . -drawer -stay -toggle',
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
    PlugAddOpt 'vim-vinegar'
    " functions
    function! NetrwClose()
        if exists('t:netrw_winnr')
            let netrw_bufnr = bufwinnr(t:netrw_winnr)
            if netrw_bufnr != -1
                exec netrw_bufnr . 'wincmd w'
                close
            endif
            unlet t:netrw_winnr
        endif
    endfunction
    command! NetrwClose call NetrwClose()
    function! NetrwOpen()
        Vexplore
        let t:netrw_winnr = bufnr("%")
        wincmd p
    endfunction
    command! NetrwOpen call NetrwOpen()
    function! NetrwToggle()
        if exists("t:netrw_winnr")
            NetrwClose
        else
            NetrwOpen
        endif
    endfunction
    command! NetrwToggle call NetrwToggle()
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
