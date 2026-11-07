" --------------------------
" vista
" --------------------------
let g:vista#renderer#ctags = 'kind'
let g:vista_update_on_text_changed = 1
let g:vista_sidebar_position = 'vertical topleft'
let g:vista_sidebar_width = 35
let g:vista_echo_cursor   = 0
let g:vista_stay_on_open  = 0
let g:vista_icon_indent   =  ["╰─▸ ", "├─▸ "]
let g:vista_executive_for = {
            \ 'vimwiki': 'markdown',
            \ 'pandoc': 'markdown',
            \ 'markdown': 'toc',
            \ }
if g:ctags_type != ''
    let g:vista_executive_for.go = 'ctags'
endif
nnoremap <Tab>v :Vista
