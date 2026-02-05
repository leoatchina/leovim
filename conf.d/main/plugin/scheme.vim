" Skip in VSCode environment
if utils#is_vscode()
    finish
endif
syntax on
syntax enable
filetype on
filetype plugin on
set background=dark
function! s:toggle_bg()
    if &background == "dark"
        set background=light
    else
        set background=dark
    endif
    call preview#cmdmsg(&background, 1)
endf
command! ToggleBackgroud call s:toggle_bg()
nnoremap <M-k>b :ToggleBackgroud<Cr>
function! scheme#set(scheme, ...) abort
    let scheme = a:scheme
    let defaultscheme = get(a:, 1, 'slate')
    if g:has_truecolor
        call utils#execute('colorscheme '. scheme)
    else
        call utils#execute('colorscheme '. defaultscheme)
    endif
endfunction
" set scheme for different complete_engine
let g:terminal_color_13 = ''
let g:edge_better_performance = 1
let g:gruvbox_better_performance = 1
let g:sonokai_better_performance = 1
if g:complete_engine == 'mcm'
    call scheme#set('moonfly', 'codedark')
elseif g:complete_engine == 'builtin'
    call scheme#set('terafox', 'wombat')
elseif g:complete_engine == 'cmp'
    call scheme#set('tokyonight', 'space-vim-dark')
elseif g:complete_engine == 'blink'
    if pack#get('blink.lua') || pack#get('blink') && !executable('cargo')
        call scheme#set('nightfox', 'hybrid')
    else
        call scheme#set('duskfox', 'hybrid')
    endif
elseif g:complete_engine == 'coc'
    if has('nvim')
        call scheme#set('catppuccin', 'one')
    else
        call scheme#set('onedark', 'one')
    endif
else
    call scheme#set('sonokai', 'sublime')
endif
" --------------------------
" nvim-web-devicons
" --------------------------
if pack#installed('nvim-web-devicons')
    lua require('nvim-web-devicons').setup({})
endif
