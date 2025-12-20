
" Skip in VSCode environment
if utils#is_vscode()
    finish
endif
if pack#installed('nvim-treesitter', 'hlargs.nvim')
    if utils#is_win()
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
    if pack#installed_coc()
        nmap <M-s> <Plug>(coc-range-select)
        xmap <M-s> <Plug>(coc-range-select)
        omap <M-s> <Plug>(coc-range-select)
    elseif pack#installed('wildfire.vim')
        let g:wildfire_fuel_map = '<M-s>'
        let g:wildfire_water_map = '<M-S>'
        let g:wildfire_objects = get(g:, "wildfire_objects", split("iw i' i\" i] i) iL ii i}"))
    endif
endif
