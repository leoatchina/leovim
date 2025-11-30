if Planned('vim-translator')
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
if Planned('dash.vim')
    nmap q: :Dash<Space>
    nmap q? <Plug>DashGlobalSearch
    nmap q/ <Plug>DashSearch
elseif Planned('zeavim.vim')
    nmap q: :Zeavim<Space>
    nmap q? <Plug>ZVKeyDocset
    nmap q/ <Plug>Zeavim
    xmap q/ <Plug>ZVVisSelection
endif
" map_K
function! s:k()
    if index(['vim', 'help'], &ft) >= 0
        if PlannedLeaderf()
            execute 'LeaderfHelpCword'
        else
            execute 'h '.expand('<cword>')
        endif
    elseif InstalledCoc() && CocAction('hasProvider', 'hover')
        call CocActionAsync('doHover')
    else
        call feedkeys('K', 'n')
    endif
endfunction
command! K call s:k()
nnoremap <silent>K :K<Cr>
