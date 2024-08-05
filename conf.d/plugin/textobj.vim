if Installed('nvim-treesitter', 'hlargs.nvim')
    " parser_install_dir
    if WINDOWS()
        function! s:cleanup_ts() abort
            let dir = $HOME . '\.leovim.d\pack\add\opt\nvim-treesitter'
            exec printf('!del %s\parser\*.* %s\parser-info\*.* /a /f /q', dir, dir)
        endfunction
    else
        function! s:cleanup_ts() abort
            let dir = $HOME . '/.leovim.d/pack/add/opt/nvim-treesitter'
            exec printf('!rm -rf %s/parser/*.* %s/parser-info/*.*', dir, dir)
        endfunction
    endif
    command! TSCleanup call s:cleanup_ts()
    lua require("treesitter")
else
    nmap sv :call preview#errmsg('Please install treesitter in nvim-0.8+')<Cr>
    xmap sv :call preview#errmsg('Please install treesitter in nvim-0.8+')<Cr>
    omap sv :call preview#errmsg('Please install treesitter in nvim-0.8+')<Cr>
    nmap <silent>}} ]m
    nmap <silent>{{ [m
    nmap <silent>}] ]M
    nmap <silent>{[ [M
    if PlannedCoc()
        nmap <M-s> <Plug>(coc-range-select)
        xmap <M-s> <Plug>(coc-range-select)
        omap <M-s> <Plug>(coc-range-select)
    endif
endif
