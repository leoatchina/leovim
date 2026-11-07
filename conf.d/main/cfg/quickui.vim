" --------------------------
" vim-quickui
" --------------------------
let g:quickui_border_style = 2
if has('nvim')
    if utils#has_gui()
        let g:quickui_color_scheme = 'gruvbox'
    else
        let g:quickui_color_scheme = 'papercol dark'
    endif
else
    if utils#has_gui()
        let g:quickui_color_scheme = 'borland'
    else
        let g:quickui_color_scheme = 'papercol light'
    endif
endif
" quickui#tools#display_messages and scroll helpers stay bound in plugin/basic.vim
function! quickui#preview_popup_file(filename) abort
    let filename = a:filename
    let fopts = {'cursor':-1, 'number':1, 'persist':0, 'w':80, 'h':64}
    call quickui#preview#open(filename, fopts)
endfunction
command! -nargs=1 -complete=file PreviewPopupFile call quickui#preview_popup_file(<f-args>)
