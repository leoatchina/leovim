" ------------------------------
" Skip in VSCode environment
" ------------------------------
if utils#is_vscode()
    finish
endif
" --------------------------
" vim-quickui: settings in cfg/quickui.vim
" --------------------------
if pack#planned('vim-quickui')
    nnoremap <silent><M-k>m :call quickui#tools#display_messages()<Cr>
    nnoremap \o :PreviewPopupFile
    nnoremap <F13> :call quickui#preview#scroll(1)<Cr>
    nnoremap <F14> :call quickui#preview#scroll(-1)<Cr>
    if pack#installed_coc()
        nmap <silent><expr><C-j> coc#float#has_scroll() ? coc#float#scroll(1) : quickui#preview#visible() > 0 ? "\<F13>" : "\%"
        nmap <silent><expr><C-k> coc#float#has_scroll() ? coc#float#scroll(0) : quickui#preview#visible() > 0 ? "\<F14>" : "\g%"
    else
        nmap <silent><expr><C-j> quickui#preview#visible() > 0 ? "\<F13>" : "\%"
        nmap <silent><expr><C-k> quickui#preview#visible() > 0 ? "\<F14>" : "\g%"
    endif
else
    nnoremap \o :PreviewFile
    nnoremap <silent><M-k>m :messages<Cr>
    nmap <C-j> %
    nmap <C-k> g%
endif
xmap <C-j> %
xmap <C-k> g%
" --------------------------------
" funzzy finder
" --------------------------------
if pack#planned_fzf()
    nmap m<tab> <plug>(fzf-maps-n)
    xmap m<tab> <plug>(fzf-maps-x)
    omap m<tab> <plug>(fzf-maps-o)
    command! FzfRunCommands call FzfCallCommands('FzfRunCommands', 'Fzf', ['FzfAg', 'FzfRG'])
endif
if pack#planned_leaderf()
    nnoremap <leader>F :Leaderf
    nnoremap <silent><leader>L :Leaderf --recall<Cr>
    nnoremap <silent><leader>; :Leaderf --next<Cr>
    nnoremap <silent><leader>, :Leaderf --previous<Cr>
    nnoremap <silent><M-k><M-l> :LeaderfSelf<Cr>
endif
" --------------------------------
" commands && highlights
" --------------------------------
if pack#installed_snacks()
    nnoremap <silent><M-k><M-f> <Cmd>lua Snacks.picker.commands()<Cr>
    nnoremap <silent><M-k>h <Cmd>lua Snacks.picker.highlights()<Cr>
elseif pack#installed_fuzzbox()
    nnoremap <silent><M-k><M-f> :FuzzyCommands<Cr>
    nnoremap <silent><M-k>h :FuzzyHighlights<Cr>
elseif pack#planned_fzf()
    nnoremap <silent><M-k><M-f> :FzfRunCommands<Cr>
    nnoremap <silent><M-k>h :FzfHighlight<Cr>
endif
" --------------------------------
" common maps
" --------------------------------
if pack#installed_snacks()
    nnoremap <silent><M-k>t <Cmd>lua Snacks.picker.colorschemes()<Cr>
    nnoremap <silent><M-k>f :filetype<Space>
    nnoremap <silent><M-k><M-k> <Cmd>lua Snacks.picker.commands()<Cr>
elseif pack#installed_leaderf()
    nnoremap <silent><M-k>t :LeaderfColorscheme<Cr>
    nnoremap <silent><M-k>f :LeaderfFiletype<Cr>
    nnoremap <silent><M-k><M-k> :LeaderfCommand<Cr>
elseif pack#installed_fzf()
    nnoremap <silent><M-k>t :FzfColors<Cr>
    nnoremap <silent><M-k>f :FzfFiletypes<Cr>
    nnoremap <silent><M-k><M-k> :FzfCommands<Cr>
else
    nnoremap <M-k>t :colorscheme<Space>
    nnoremap <M-k>f :filetype<Space>
    nnoremap <M-k><M-k> :command<Space>
endif
if pack#installed_snacks()
    nnoremap <silent><M-h><M-h> <Cmd>lua Snacks.picker.help()<Cr>
elseif pack#installed_leaderf()
    nnoremap <silent><M-h><M-h> :LeaderfHelp<Cr>
elseif pack#installed_fzf() && executable('perl')
    nnoremap <silent><M-h><M-h> :FzfHelptags<Cr>
else
    nnoremap <M-h><M-h> :h<Space>
endif
" ---------------------------------
" query
" ---------------------------------
if pack#planned('vim-translator')
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
if pack#planned('dash.vim')
    nmap q: :Dash<Space>
    nmap q? <Plug>DashGlobalSearch
    nmap q/ <Plug>DashSearch
elseif pack#planned('zeavim.vim')
    nmap q: :Zeavim<Space>
    nmap q? <Plug>ZVKeyDocset
    nmap q/ <Plug>Zeavim
    xmap q/ <Plug>ZVVisSelection
endif
" map_K
function! s:k()
    if index(['vim', 'help'], &ft) >= 0
        if pack#planned_leaderf()
            execute 'LeaderfHelpCword'
        else
            execute 'h '.utils#expand('<cword>')
        endif
    elseif pack#installed_coc() && CocAction('hasProvider', 'hover')
        call CocActionAsync('doHover')
    else
        call feedkeys('K', 'n')
    endif
endfunction
command! K call s:k()
nnoremap <silent>K :K<Cr>
" --------------------------
" helpful
" --------------------------
if pack#installed('helpful.vim')
    au FileType vim,lua,help nnoremap <M-M> :HelpfulVersion<Space>
endif
