if Installed('vim-translator')
    let g:translator_default_engines=['bing', 'haici']
    if g:has_popup_floating
        " show translate in popup or floating windows
        nmap <silent>gw <Plug>TranslateW
        xmap <silent>gw <Plug>TranslateWV
    else
        nmap <silent>gw <Plug>Translate
        xmap <silent>gw <Plug>TranslateV
    endif
endif
if Installed('dash.vim')
    nmap g: :Dash<Space>
    nmap gy <Plug>DashGlobalSearch
    nmap gz <Plug>DashSearch
elseif Installed('zeavim.vim')
    nmap g: :Zeavim<Space>
    nmap gy <Plug>ZVKeyDocset
    nmap gz <Plug>Zeavim
    xmap gz <Plug>ZVVisSelection
endif
" map_K
function! s:k()
    if index(['vim', 'help'], &ft) >= 0
        if InstalledLeaderf()
            execute 'LeaderfHelpCword'
        else
            execute 'h '.expand('<cword>')
        endif
    elseif InstalledCoc() && CocAction('hasProvider', 'hover')
        call CocActionAsync('doHover')
    elseif InstalledNvimLsp()
        lua vim.lsp.buf.hover()
    else
        call feedkeys('K', 'n')
    endif
endfunction
command! K call s:k()
nnoremap <silent>K :K<Cr>
