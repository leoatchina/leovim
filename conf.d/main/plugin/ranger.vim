" Skip in VSCode environment
if utils#is_vscode()
    finish
endif
" 在没有 treesitter 时的选区与函数跳转兜底
if !pack#installed_treesitter()
    nmap sv :call preview#errmsg('Please install treesitter')<Cr>
    xmap sv :call preview#errmsg('Please install treesitter')<Cr>
    omap sv :call preview#errmsg('Please install treesitter')<Cr>
    nmap <silent>}} ]m
    nmap <silent>{{ [m
    nmap <silent>}] ]M
    nmap <silent>{[ [M

    " wildfire 选区按键：覆盖默认的 <ENTER>，避免破坏 init.vim 的 <Cr> -> <C-i>
    let g:wildfire_fuel_map = '<M-s>'
    let g:wildfire_water_map = '<M-S>'
    let g:wildfire_objects = get(g:, "wildfire_objects", split("iw i' i\" i] i) iL ii i}"))
endif
