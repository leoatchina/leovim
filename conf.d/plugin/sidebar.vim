PlugAddOpt 'vim-sidebar-manager'
let g:sidebars = {}
function! s:check_buf_ft(name, nr) abort
    return getwinvar(a:nr, '&filetype') ==# a:name || bufname(winbufnr(a:nr)) ==# a:name
endfunction
" --------------------------
" symbol
" --------------------------
if Installed('vista.vim')
    let g:vista#renderer#ctags = 'kind'
    let g:vista_update_on_text_changed = 1
    let g:vista_sidebar_position = 'vertical topleft'
    let g:vista_sidebar_width = 35
    let g:vista_echo_cursor   = 0
    let g:vista_stay_on_open  = 0
    let g:vista_icon_indent   = ["╰─▸ ", "├─▸ "]
    let g:vista_executive_for = {
                \ 'vimwiki': 'markdown',
                \ 'pandoc': 'markdown',
                \ 'markdown': 'toc',
                \ }
    if g:ctags_type != ''
        let g:vista_executive_for.go = 'ctags'
    endif
    if get(g:, 'ctags_type', '') =~ 'Universal' && g:vista_default_executive != 'ctags'
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
elseif Installed('tagbar')
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
if v:version >= 801 || has('nvim')
    source $CFG_DIR/fern.vim
    let g:tree_browser = 'fern'
    let g:sidebars.tree_browser = {
                \ 'position': 'left',
                \ 'check_win': function('s:check_buf_ft', ["fern"]),
                \ 'open': 'FernGetRoot',
                \ 'close': 'Fern . -drawer -toggle'
                \ }
" elseif Installed('coc.nvim')
"     let g:tree_browser = 'coc-explore'
"     function s:coc_explorer_open() abort
"         CocCommand explorer
"         sleep 100m
"         wincmd w
"     endfunction
"     command! CocExplorerOpen call s:coc_explorer_open()
"     function! s:check_coc_explorer(nr)
"         return s:check_buf_ft('coc-explorer', a:nr)
"     endfunction
"     let g:sidebars.tree_browser = {
"                 \ 'position': 'left',
"                 \ 'check_win': function('s:check_coc_explorer'),
"                 \ 'open': 'CocExplorerOpen',
"                 \ 'close': 'CocCommand explorer'
"                 \ }
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
