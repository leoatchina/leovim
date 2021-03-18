if Installed('vim-sidebar-manager')
    let g:sidebars = {}
    " =====================
    " symbol_tool
    " =====================
    if g:symbol_tool =~ 'tagbar'
        let g:sidebars.tagbar = {
                    \ 'position': 'left',
                    \ 'check_win': {nr -> bufname(winbufnr(nr)) =~ 'tagbar'},
                    \ 'open': 'TagbarOpen',
                    \ 'close': 'TagbarClose'
                    \ }
        nnoremap <silent> <leader>t :call sidebar#toggle('tagbar')<CR>
    endif
    if g:symbol_tool =~ 'vista'
        if get(g:, 'ctags_version', '') =~ 'json'
            let g:sidebars.vista_ctags = {
                        \ 'position': 'left',
                        \ 'check_win': {nr -> getwinvar(nr, '&filetype') =~ 'vista'},
                        \ 'open': 'Vista ctags',
                        \ 'close': 'Vista!'
                        \ }
            nnoremap <silent> <leader>t :call sidebar#toggle('vista_ctags')<CR>
        endif
        if get(g:, 'complete_engine', '') == 'coc' || get(g:, 'complete_engine', '') == 'vim-lsp'
            let g:sidebars.vista = {
                        \ 'position': 'left',
                        \ 'check_win': {nr -> getwinvar(nr, '&filetype') =~ 'vista'},
                        \ 'open': 'Vista',
                        \ 'close': 'Vista!'
                        \ }
            if execute(":map <leader>t") =~ 'Nop'
                nnoremap <silent> <leader>t :call sidebar#toggle('vista')<CR>
            else
                nnoremap <silent> <leader>T :call sidebar#toggle('vista')<CR>
            endif
        endif
    endif
    " =====================
    " tree_browser
    " =====================
    if get(g:, 'tree_browser', '') == 'coc'
        function! CocBrowser(type) abort
            if a:type == 1
                exec("CocCommand explorer --no-toggle --width 30")
            else
                exec("CocCommand explorer --toggle")
            endif
        endfunction
        command! CocBrowserOpen  call CocBrowser(1)
        command! CocBrowserClose call CocBrowser(0)
        let g:sidebars.tree_browser = {
                    \ 'position': 'left',
                    \ 'check_win': {nr -> getwinvar(nr, '&filetype') =~ "coc\-explorer"},
                    \ 'open': 'CocBrowserOpen',
                    \ 'close': 'CocBrowserClose'
                    \ }
    elseif get(g:, 'tree_browser', '') == 'fern'
        let g:sidebars.tree_browser = {
                    \ 'position': 'left',
                    \ 'check_win': {nr -> getwinvar(nr, '&filetype') =~ 'fern'},
                    \ 'open': 'Fern . -drawer -stay -toggle',
                    \ 'close': 'Fern .  -drawer -stay -toggle'
                    \ }
    else
        " netrw on left
        let g:netrw_altv = 0
        let g:sidebars.tree_browser = {
                    \ 'position': 'left',
                    \ 'check_win': {nr -> getwinvar(nr, '&filetype') =~ 'netrw'},
                    \ 'open': 'OpenNetrw',
                    \ 'close': 'CloseNetrw'
                    \ }
    endif
    nnoremap <silent> <leader>n :call sidebar#toggle('tree_browser')<CR>
    " ====================="
    " right side undo
    " ====================="
    if &rtp =~ 'mundo'
        let g:sidebars.undo_tool = {
                    \ 'position': 'right',
                    \ 'check_win': {nr -> bufname(winbufnr(nr)) =~ '_Mundo_'},
                    \ 'open': 'MundoShow',
                    \ 'close': 'MundoHide'
                    \ }
    elseif &rtp =~ 'undotree'
        let g:sidebars.undo_tool = {
                    \ 'position': 'right',
                    \ 'check_win': {nr -> getwinvar(nr, '&filetype') =~ 'undotree'},
                    \ 'open': 'UndotreeShow',
                    \ 'close': 'UndotreeHide'
                    \ }
    endif
    if has_key(g:sidebars, 'undo_tool')
    	nnoremap <silent> <leader>u :call sidebar#toggle('undo_tool')<CR>
    endif
    " =====================
    " downside
    " =====================
    autocmd FileType qf call s:setup_quickfix_window()
    function! s:setup_quickfix_window()
        setlocal wrap foldcolumn=0 colorcolumn= signcolumn=no cursorline
        nnoremap <silent> <buffer> <M-q> <C-w>q
    endfunction
    let g:sidebars.quickfix = {
                \ 'position': 'bottom',
                \ 'check_win': {nr -> getwinvar(nr, '&filetype') ==# 'qf' && !getwininfo(win_getid(nr))[0]['loclist']},
                \ 'open': 'OpenQuickfix',
                \ 'close': 'ToggleQuickfix'
                \ }
    nnoremap <silent> q<C-m> :<C-u>call sidebar#toggle('quickfix')<CR>
    nnoremap <silent> q<Tab> :<C-u>AsyncStop!<CR>:call sidebar#toggle('quickfix')<CR>
    if g:has_terminal == 1
        tnoremap <silent> <M-/> <C-\><C-n>:call sidebar#toggle('quickfix')<CR>
    elseif g:has_terminal == 2
        tnoremap <silent> <M-/> <C-_>:call sidebar#toggle('quickfix')<CR>
    endif
    if get(g:, 'terminal_plus', '') =~ 'help'
        if g:has_lambda == 2
            let g:sidebars.terminal = {
                        \ 'position': 'bottom',
                        \ 'get_win': {-> exists('t:__terminal_bid__') ? bufwinnr(t:__terminal_bid__) : 0},
                        \ 'open': 'call TerminalOpen()',
                        \ 'close': 'call TerminalClose()'
                        \ }
            nnoremap <silent> <M--> :call sidebar#toggle('terminal')<CR>
            if has('nvim')
                tnoremap <silent> <M--> <C-\><C-n>:call sidebar#toggle('terminal')<CR>
            else
                tnoremap <silent> <M--> <C-_>:call sidebar#toggle('terminal')<CR>
            endif
        else
            nnoremap <M--> :call TerminalToggle()<Cr>
            tnoremap <M--> <C-\><C-n>:call TerminalToggle()<Cr>
        endif
    endif
    let g:startify_session_before_save = ['call sidebar#close_all()']
else
    " symbol_tool
    if g:symbol_tool =~ 'vista'
        nnoremap <leader>T :Vista!!<Cr>
        let g:vista_sidebar_position = 'vertical topleft'
        if get(g:, 'ctags_version', '') =~ 'json'
            nnoremap <silent> <leader>t :Vista ctags<CR>
        endif
    elseif g:symbol_tool =~ 'tagbar'
        let g:tagbar_left = 1
        nnoremap <leader>t :TagbarToggle<Cr>
    endif
endif
" AUTOClose is initied in init.vim
aug AUTOClose
    au WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), "&filetype") == "vista" |q|endif
    au WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), "&filetype") == "coc-explorer"|q|endif
    au WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), "&filetype") == "rbrowser"|q|endif
    au WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), "&filetype") == "defx"|q|endif
    au WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), "&filetype") == "fern"|q|endif
    au WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), "&buftype")  == "tagbar"|q|endif
aug END
