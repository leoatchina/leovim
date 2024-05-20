if Installed('nvim-treesitter', 'hlargs.nvim')
    " parser_install_dir
    if WINDOWS()
        let parser_install_dir = $DEPLOY_DIR . '\tree-sitter'
        function! s:cleanup_ts() abort
            exec printf('!del %s\tree-sitter\parser\*.* %s\tree-sitter\parser-info\*.* /a /f /q', $DEPLOY_DIR, $DEPLOY_DIR)
        endfunction
    else
        let parser_install_dir = $DEPLOY_DIR . '/tree-sitter'
        function! s:cleanup_ts() abort
            exec printf('!rm -rf %s/tree-sitter/parser/*.* %s/tree-sitter/parser-info/*.*', $DEPLOY_DIR, $DEPLOY_DIR)
        endfunction
    endif
    silent! call mkdir(parser_install_dir . "/parser", "p")
    command! TSCleanup call s:cleanup_ts()
    exec "set rtp+=" . parser_install_dir
    " map and config
    luafile $LUA_DIR/treesitter.lua
else
    nmap sv :call preview#errmsg('Please install treesitter in nvim-0.8+')<Cr>
    xmap sv :call preview#errmsg('Please install treesitter in nvim-0.8+')<Cr>
    omap sv :call preview#errmsg('Please install treesitter in nvim-0.8+')<Cr>
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
