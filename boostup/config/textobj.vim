" --------------------------
" nvim-treesitter
" --------------------------
if Installed('nvim-treesitter', 'hlargs.nvim')
    " parser_install_dir
    if WINDOWS()
        let parser_install_dir = $DEP_PATH . '\tree-sitter'
        function! s:cleanup_ts() abort
            exec printf('!del %s\tree-sitter\parser\*.* %s\tree-sitter\parser-info\*.* /a /f /q', $DEP_PATH, $DEP_PATH)
        endfunction
    else
        let parser_install_dir = $DEP_PATH . '/tree-sitter'
        function! s:cleanup_ts() abort
            exec printf('!rm -rf %s/tree-sitter/parser/*.* %s/tree-sitter/parser-info/*.*', $DEP_PATH, $DEP_PATH)
        endfunction
    endif
    silent! call mkdir(parser_install_dir . "/parser", "p")
    command! TSCleanup call s:cleanup_ts()
    exec "set rtp+=" . parser_install_dir
    " map and config
    luafile $LUA_PATH/treesitter.lua
else
    nmap so :call preview#errmsg('Please install treesitter in nvim-0.8+')<Cr>
    xmap so :call preview#errmsg('Please install treesitter in nvim-0.8+')<Cr>
    omap so :call preview#errmsg('Please install treesitter in nvim-0.8+')<Cr>
    nmap <silent>}} ]m
    nmap <silent>{{ [m
    nmap <silent>}] ]M
    nmap <silent>{[ [M
    if InstalledCoc()
        nmap <C-s> <Plug>(coc-range-select)
        xmap <C-s> <Plug>(coc-range-select)
        omap <C-s> <Plug>(coc-range-select)
    endif
endif

