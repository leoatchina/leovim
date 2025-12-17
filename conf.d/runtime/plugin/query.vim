" Skip in VSCode environment
if utils#is_vscode()
    finish
endif
if plug#planned('vim-translator')
    let g:translator_default_engines=['bing', 'haici']
    if g:has_popup_floating
        " show translate in popup or floating windows
        nmap <silent>q\ <Plug>TranslateW
        xmap <silent>q\ <Plug>TranslateWV
    else
        nmap <silent>q\ <Plug>Translate
        xmap <silent>q\ <Plug>TranslateV
    endif
endif
if plug#planned('dash.vim')
    nmap q: :Dash<Space>
    nmap q? <Plug>DashGlobalSearch
    nmap q/ <Plug>DashSearch
elseif plug#planned('zeavim.vim')
    nmap q: :Zeavim<Space>
    nmap q? <Plug>ZVKeyDocset
    nmap q/ <Plug>Zeavim
    xmap q/ <Plug>ZVVisSelection
endif
" map_K
function! s:k()
    if index(['vim', 'help'], &ft) >= 0
        if plug#planned_leaderf()
            execute 'LeaderfHelpCword'
        else
            execute 'h '.utils#expand('<cword>')
        endif
    elseif plug#installed_coc() && CocAction('hasProvider', 'hover')
        call CocActionAsync('doHover')
    else
        call feedkeys('K', 'n')
    endif
endfunction
command! K call s:k()
nnoremap <silent>K :K<Cr>
