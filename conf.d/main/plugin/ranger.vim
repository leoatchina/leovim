" Skip in VSCode environment
if utils#is_vscode()
    finish
endif
if pack#installed_treesitter()
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
else
    nmap sv :call preview#errmsg('Please install treesitter')<Cr>
    xmap sv :call preview#errmsg('Please install treesitter')<Cr>
    omap sv :call preview#errmsg('Please install treesitter')<Cr>
    nmap <silent>}} ]m
    nmap <silent>{{ [m
    nmap <silent>}] ]M
    nmap <silent>{[ [M
endif
" wildfire and treesitter are independent plugins; they only exclude each
" other on the M-s/M-S function. treesitter.lua defines its own M-s/M-S
" (incremental_selection); wildfire takes over only when treesitter is absent.
" Its default fuel map is <ENTER> — always override before the plugin loads,
" otherwise it clobbers nnoremap <Cr> <C-i> from init.vim.
if !pack#installed_treesitter()
    let g:wildfire_fuel_map = '<M-s>'
    let g:wildfire_water_map = '<M-S>'
    let g:wildfire_objects = get(g:, "wildfire_objects", split("iw i' i\" i] i) iL ii i}"))
endif
