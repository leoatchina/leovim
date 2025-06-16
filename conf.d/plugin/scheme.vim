syntax on
syntax enable
filetype on
filetype plugin on
set background=dark
function! s:tooglebg()
    if &background == "dark"
        set background=light
    else
        set background=dark
    endif
    call preview#cmdmsg(&background, 1)
endf
command! ToggleBackgroud call s:tooglebg()
nnoremap <M-k>b :ToggleBackgroud<Cr>
function! SetScheme(scheme, ...) abort
    let scheme = a:scheme
    let defaultscheme = get(a:, 1, 'slate')
    try
        if g:has_truecolor
            execute('colorscheme '. scheme)
        else
            execute('colorscheme '. defaultscheme)
        endif
    catch
        colorscheme slate
    endtry
endfunction
" set scheme for different complete_engine
let g:terminal_color_13 = ''
let g:edge_better_performance = 1
let g:sonokai_better_performance = 1
if g:complete_engine == 'mcm'
    call SetScheme('edge', 'one')
elseif g:complete_engine == 'cmp'
    call SetScheme('tokyonight', 'space-vim-dark')
elseif g:complete_engine == 'blink'
    if Require('blink.lua')
        call SetScheme('nightfly', 'codedark')
    else
        call SetScheme('catppuccin-mocha', 'codedark')
    endif
elseif g:complete_engine == 'coc'
    if has('nvim')
        call SetScheme('duskfox', 'hybrid')
    else
        call SetScheme('sonokai', 'sublime')
    endif
else
    colorscheme slate
endif
" --------------------------
" nvim-web-devicons
" --------------------------
if Installed('nvim-web-devicons')
    lua require('nvim-web-devicons').setup({})
endif
